//
//  XMNChatController.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatController.h"

#import "XMNChatOwnCell.h"
#import "XMNChatOtherCell.h"

#import "XMNChatBar.h"
#import "XMNChatExpressionView.h"
#import "XMNChatOtherView.h"

#import "XMNPhotoPicker.h"
#import "XMNPhotoBrowser.h"
#import "YYWebImage.h"
#import "XMNChatViewModel.h"

#import "XMNChatController_Private.h"
#import "XMNChatController+XMNVoice.h"
#import "XMNChatController+XMNChatCellDelegate.h"
#import "XMNChatController+XMNGestureAction.h"

@implementation XMNChatController

#pragma mark - Life Cycle

- (instancetype)initWithChatMode:(XMNChatMode)aChatMode {
    
    if (self = [super init]) {
        
        _chatVM = [[XMNChatViewModel alloc] initWithChatMode:aChatMode];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self setupVoiceUI];
    [self setupConstraints];
    [self setupMenuItems];
    [self setupGestures];
    
    /** 首次出现让tableView滚动到底部 */
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOtherItemAction:) name:kXMNChatOtherItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleExpressionChanged:) name:kXMNChatExpressionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageClicked:) name:kXMNChatMessageClickedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMNChatExpressionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMNChatMessageClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMNChatOtherItemNotification object:nil];
}

- (void)dealloc {
    
    /** 移除所有memory缓存 */
    [self clean];
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
    XMNLog(@"%@  dealloc",NSStringFromClass([self class]));
}


#pragma mark - Methods

/**
 *  初始化界面
 */
- (void)setupUI {
    
    //隐藏系统自带tabBar
    self.hidesBottomBarWhenPushed = YES;
    //设置背景色
    self.view.backgroundColor = self.tableView.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    
    //添加chatBar
    XMNChatBar *chatBar = [[XMNChatBar alloc] init];
    [self.view addSubview:self.chatBar = chatBar];
    self.chatBar.textView.delegate = self;
    self.chatBar.delegate = self;
    
    //添加表情输入框
    self.faceView = [[XMNChatExpressionView alloc] init];
    
    //添加其他选择框
    self.otherView = [[XMNChatOtherView alloc] init];
    
    //添加tableView
    [self.view addSubview:self.tableView];
}

/**
 *  初始化chatBar,faceView,otherView的自动布局约束
 */
- (void)setupConstraints {
    
    self.chatBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    {   //setup chatBar constraint
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_chatBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_chatBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        
        NSLayoutConstraint *chatBarBConstraint = [NSLayoutConstraint constraintWithItem:self.chatBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self.view addConstraint:self.chatBarBConstraint = chatBarBConstraint];
        
        NSLayoutConstraint *chatBarHConstraint = [NSLayoutConstraint constraintWithItem:self.chatBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:kXMNChatBarHeight];
        [self.view addConstraint:self.chatBarHConstraint = chatBarHConstraint];
    }
    {//setup tableView constraints
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:64.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.chatBar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
}

- (void)sendMessage:(XMNChatBaseMessage *)aMessage {

    [self.chatVM sendMessage:aMessage];
    [self.tableView reloadData];
    [self scrollBottom:NO];
}

- (void)scrollBottom:(BOOL)animated {
    
    if (self.chatVM.messages.count >= 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, self.chatVM.messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


#pragma mark - 通知相关事件处理

/**
 *  处理键盘frame改变通知
 *
 *  @param aNotification
 */
- (void)handleKeyboard:(NSNotification *)aNotification {
    
    CGRect keyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.chatBarBConstraint.constant = -([UIScreen mainScreen].bounds.size.height - keyboardFrame.origin.y);
    
    /** 增加监听键盘大小变化通知,并且让tableView 滚动到最底部 */
    [self.view layoutIfNeeded];
    [self scrollBottom:NO];
}

- (void)handleOtherItemAction:(NSNotification *)notification {
    
    NSLog(@"notification ");
    
    /** 需要更改下XMNPhotoPicker的位置 */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [XMNPhotoPickerOption setResourceBundle:kXMNChatBundle];
    });
    
    XMNPhotoPickerController *pickerC = [[XMNPhotoPickerController alloc] initWithMaxCount:9 delegate:nil];
    __weak typeof(*&self) wSelf = self;
    [pickerC setDidFinishPickingPhotosBlock:^(NSArray<UIImage *> * _Nullable images, NSArray<XMNAssetModel *> * _Nullable assets) {
        
        __strong typeof(*&wSelf) self = wSelf;
        
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            XMNChatImageMessage *message = [[XMNChatImageMessage alloc] initWithContent:[images firstObject]
                                                                                  state:XMNMessageStateSending
                                                                                  owner:XMNMessageOwnerSelf];
            [self sendMessage:message];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    [self presentViewController:pickerC animated:YES completion:nil];
    
}

- (void)handleExpressionChanged:(NSNotification *)aNotification {
    
    NSDictionary *info = (NSDictionary *)aNotification.object;
    XMNChatExpressionType type = [info[@"type"] integerValue];
    
    switch (type) {
        case XMNChatExpressionGIF:
            
            break;
        case XMNChatExpressionDelete:
        {
            [self.chatBar.textView deleteBackward];
        }
            break;
        case XMNChatExpressionQQEmotion:
            [self.chatBar.textView insertText:info[kXMNChatExpressionNotificationDataKey]];
            [self.chatBar.textView scrollRangeToVisible:NSMakeRange(self.chatBar.textView.text.length - 1, 1)];
            break;
        case XMNChatExpressionSend:
            [self textView:self.chatBar.textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"\n"];
            break;
    }
}

- (void)handleMessageClicked:(NSNotification *)aNotification {
    
    XMNLog(@" you  clicked message :%@",aNotification.userInfo);
}

#pragma mark - XMNChatBarDelegate

- (void)chatBarShowingViewDidChanged:(XMNChatBarShowingView)viewType {
    
    self.showingViewType = viewType;
    
    if (viewType == XMNChatShowingNoneView || viewType == XMNChatShowingVoiceView) {
        [self.chatBar.textView endEditing:YES];
        [self.chatBar.textView resignFirstResponder];
        self.chatBarBConstraint.constant =.0f;
        self.chatBarHConstraint.constant = kXMNChatBarHeight;
    }
    
    if (viewType == XMNChatShowingFaceView) {
        
        self.chatBar.textView.inputView = self.faceView;
        self.chatBar.textView.extraAccessoryViewHeight = kXMNChatViewHeight;
        [self.chatBar.textView reloadInputViews];
        [self.chatBar.textView becomeFirstResponder];
    }
    
    if (viewType == XMNChatShowingOtherView) {

        self.chatBar.textView.inputView = self.otherView;
        self.chatBar.textView.extraAccessoryViewHeight = kXMNChatViewHeight;
        [self.chatBar.textView reloadInputViews];
        [self.chatBar.textView becomeFirstResponder];
    }
    
    if (viewType == XMNChatShowingKeyboard) {
        
        CGSize sizeThatShouldFitTheContent = [self.chatBar.textView sizeThatFits:self.chatBar.textView.frame.size];
        CGFloat constant = MAX(44.f, MIN(sizeThatShouldFitTheContent.height + 8 + 8,kXMNChatBarMaxHeight));
        //每次textView的文本改变后 修改chatBar的高度
        self.chatBarHConstraint.constant = constant;
        self.chatBar.textView.scrollEnabled = self.chatBarHConstraint.constant >= kXMNChatBarMaxHeight;
    
        [self.chatBar.textView setSelectedRange:NSMakeRange(self.chatBar.textView.text.length - 1, 0)];
        self.chatBar.textView.inputView = nil;
        [self.chatBar.textView reloadInputViews];
        [self.chatBar.textView becomeFirstResponder];
    }    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.showingViewType != XMNChatShowingNoneView && scrollView != self.chatBar.textView) {
        XMNLog(@"can end editing");
        [self chatBarShowingViewDidChanged:XMNChatShowingNoneView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // TODO: 增加上拉显示键盘的效果
    //    if (scrollView.contentOffset.y + scrollView.bounds.size.height + 64 - scrollView.contentSize.height >= 0) {
    //        if (self.showingViewType == XMNChatShowingNoneView) {
    //            NSLog(@"over bottom 2");
    //            [self.chatBar.textView becomeFirstResponder];
    //            [self.chatBar layoutIfNeeded];
    //        }
    //    }
}


#pragma mark - YYTextViewDelegate

- (void)textViewDidChange:(YYTextView *)textView {
    
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
    CGFloat constant = MAX(44.f, MIN(sizeThatShouldFitTheContent.height + 8 + 8,kXMNChatBarMaxHeight));
    //每次textView的文本改变后 修改chatBar的高度
    self.chatBarHConstraint.constant = constant;
    textView.scrollEnabled = self.chatBarHConstraint.constant >= kXMNChatBarMaxHeight;
    
    /** 解决chatBar高度变化后,tableView高度修改 */
    [self.view layoutIfNeeded];
}

- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView {
    
    self.showingViewType = XMNChatShowingKeyboard;
    //添加文本输入区域
    textView.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);

    //修复了textView默认了contentInset.top = 64的问题
    textView.contentInset = UIEdgeInsetsMake( 2, 0, 4, 0);
    
    //解决textView大小不定时 contentOffset不正确的bug
    //固定了textView后可以设置滚动YES
    CGSize sizeThatShouldFitTheContent = [textView sizeThatFits:textView.frame.size];
    //每次textView的文本改变后 修改chatBar的高度
    CGFloat chatBarHeight = MAX(44.f, MIN(sizeThatShouldFitTheContent.height + 8 + 8,kXMNChatBarMaxHeight));
    
    textView.scrollEnabled = chatBarHeight>=kXMNChatBarMaxHeight;
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //实现textView.delegate  实现回车发送,return键发送功能
    if ([@"\n" isEqualToString:text]) {
        
        self.chatBarHConstraint.constant = 44.f;
        NSString *messageContent;
        if (textView.text.length > 0) {
            messageContent = textView.text;
        }

        [textView setAttributedText:nil];
        [self.chatBar setNeedsLayout];
        if (messageContent) {
            XMNChatTextMessage *textMessage = [[XMNChatTextMessage alloc] initWithContent:messageContent state:XMNMessageStateSending owner:XMNMessageOwnerSelf];
            [self sendMessage:textMessage];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    
    /** 用户不在输入文字时, 重置按钮状态 */
    if (self.showingViewType == XMNChatShowingNoneView) {
        [self.chatBar resetButtonState];
    }
}

#pragma mark - Setters

/**
 *  重写chatVM的setter方法,保证self.tableView.dataSource = chatVM
 *
 *  @param chatVM 实例
 */
- (void)setChatVM:(XMNChatViewModel<UITableViewDataSource> *)chatVM {
    
    _chatVM = chatVM;
    _chatVM.chatController = self;
    self.tableView.dataSource = chatVM;
}

#pragma mark - Getters

- (XMNChatMode)chatMode {
    
    return self.chatVM.chatMode;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = (id<UITableViewDataSource>)self.chatVM;

        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerNib:[UINib nibWithNibName:@"XMNChatSystemCell" bundle:kXMNChatBundle] forCellReuseIdentifier:kXMNChatSystemCellIdentifier];

        [_tableView registerNib:[UINib nibWithNibName:@"XMNChatOwnCell" bundle:kXMNChatBundle] forCellReuseIdentifier:self.chatMode == XMNChatSingle ? kXMNChatOwnSingleCellIdentifier : kXMNChatOwnGroupCellIdentifier];
        
        [_tableView registerNib:[UINib nibWithNibName:@"XMNChatOtherCell" bundle:kXMNChatBundle] forCellReuseIdentifier:self.chatMode == XMNChatSingle ? kXMNChatOtherSingleCellIdentifier : kXMNChatOtherGroupCellIdentifier];
        
        _tableView.estimatedRowHeight = 250.f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

@end
