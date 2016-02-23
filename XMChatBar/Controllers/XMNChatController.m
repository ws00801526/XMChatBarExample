//
//  XMNChatController.m
//  XMChatBarExample
//
//  Created by shscce on 15/11/20.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatController.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UITableView+XMNCellRegister.h"
#import "XMNChatMessageCell+XMNCellIdentifier.h"

#define kSelfName @"XMFraker"
#define kSelfThumb @"http://img1.touxiang.cn/uploads/20131114/14-065809_117.jpg"

@interface XMNChatController () <XMChatBarDelegate,XMNAVAudioPlayerDelegate,XMNChatMessageCellDelegate,XMNChatViewModelDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) XMChatBar *chatBar;

@property (assign, nonatomic) XMNMessageChat messageChatType;
@property (nonatomic, strong) XMNChatViewModel *chatViewModel;

@end

@implementation XMNChatController


#pragma mark - Life Cycle

- (instancetype)initWithChatType:(XMNMessageChat)messageChatType{
    if ([super init]) {
        _messageChatType = messageChatType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [XMNAVAudioPlayer sharePlayer].delegate = self;
    self.chatViewModel = [[XMNChatViewModel alloc] initWithParentVC:self];
    self.chatViewModel.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234/255.0f blue:234/255.f alpha:1.0f];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatBar];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [[XMNAVAudioPlayer sharePlayer] stopAudioPlayer];
    [XMNAVAudioPlayer sharePlayer].index = NSUIntegerMax;
    [XMNAVAudioPlayer sharePlayer].URLString = nil;
    
}

#pragma mark - XMChatBarDelegate

- (void)chatBar:(XMChatBar *)chatBar sendMessage:(NSString *)message{
    
    NSMutableDictionary *textMessageDict = [NSMutableDictionary dictionary];
    textMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeText);
    textMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
    textMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
    textMessageDict[kXMNMessageConfigurationTextKey] = message;
    textMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
    textMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
    [self addMessage:textMessageDict];
    
}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds{
    
    NSMutableDictionary *voiceMessageDict = [NSMutableDictionary dictionary];
    voiceMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeVoice);
    voiceMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
    voiceMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
    voiceMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
    voiceMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
    voiceMessageDict[kXMNMessageConfigurationVoiceKey] = voiceFileName;
    voiceMessageDict[kXMNMessageConfigurationVoiceSecondsKey] = @(seconds);
    [self addMessage:voiceMessageDict];
    
}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    
    NSMutableDictionary *imageMessageDict = [NSMutableDictionary dictionary];
    imageMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeImage);
    imageMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
    imageMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
    imageMessageDict[kXMNMessageConfigurationImageKey] = [pictures firstObject];
    imageMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
    imageMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
    [self addMessage:imageMessageDict];
    
}

- (void)chatBar:(XMChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText{
    NSMutableDictionary *locationMessageDict = [NSMutableDictionary dictionary];
    locationMessageDict[kXMNMessageConfigurationTypeKey] = @(XMNMessageTypeLocation);
    locationMessageDict[kXMNMessageConfigurationOwnerKey] = @(XMNMessageOwnerSelf);
    locationMessageDict[kXMNMessageConfigurationGroupKey] = @(self.messageChatType);
    locationMessageDict[kXMNMessageConfigurationNicknameKey] = kSelfName;
    locationMessageDict[kXMNMessageConfigurationAvatarKey] = kSelfThumb;
    locationMessageDict[kXMNMessageConfigurationLocationKey]=locationText;
    [self addMessage:locationMessageDict];
    
}

- (void)chatBarFrameDidChange:(XMChatBar *)chatBar frame:(CGRect)frame{
    if (frame.origin.y == self.tableView.frame.size.height) {
        return;
    }
    [UIView animateWithDuration:.3f animations:^{
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, frame.origin.y)];
    } completion:nil];
}



#pragma mark - XMNChatMessageCellDelegate

- (void)messageCellTappedHead:(XMNChatMessageCell *)messageCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    NSLog(@"tapHead :%@",indexPath);
}

- (void)messageCellTappedBlank:(XMNChatMessageCell *)messageCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    NSLog(@"tapBlank :%@",indexPath);
    [self.chatBar endInputing];
}

- (void)messageCellTappedMessage:(XMNChatMessageCell *)messageCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    NSLog(@"tapMessage :%@",indexPath);
    switch (messageCell.messageType) {
        case XMNMessageTypeVoice:
        {
            NSString *voiceFileName = [self.chatViewModel messageAtIndex:indexPath.row][kXMNMessageConfigurationVoiceKey];
            [[XMNAVAudioPlayer sharePlayer] playAudioWithURLString:voiceFileName atIndex:indexPath.row];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)messageCell:(XMNChatMessageCell *)messageCell withActionType:(XMNChatMessageCellMenuActionType)actionType {
    NSString *action = actionType ==XMNChatMessageCellMenuActionTypeRelay ? @"转发" : @"复制";
    NSLog(@"messageCell :%@ willDoAction :%@",messageCell,action);
}

#pragma mark - XMNChatViewModelDelegate

- (NSString *)chatterNickname {
    return self.chatterName;
}

- (NSString *)chatterHeadAvator {
    return self.chatterThumb;
}

- (void)messageReadStateChanged:(XMNMessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XMNChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell]) {
        return;
    }
    messageCell.messageReadState = readState;
}

- (void)messageSendStateChanged:(XMNMessageSendState)sendState withProgress:(CGFloat)progress forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XMNChatMessageCell *messageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![self.tableView.visibleCells containsObject:messageCell]) {
        return;
    }
    if (messageCell.messageType == XMNMessageTypeImage) {
        [(XMNChatImageMessageCell *)messageCell setUploadProgress:progress];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        messageCell.messageSendState = sendState;
    });
}

- (void)reloadAfterReceiveMessage:(NSDictionary *)message {
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatViewModel.messageCount - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - XMNAVAudioPlayerDelegate

- (void)audioPlayerStateDidChanged:(XMNVoiceMessageState)audioPlayerState forIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XMNChatVoiceMessageCell *voiceMessageCell = [self.tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [voiceMessageCell setVoiceMessageState:audioPlayerState];
    });
}

#pragma mark - Private Methods

- (void)addMessage:(NSDictionary *)message {
    [self.chatViewModel addMessage:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatViewModel.messageCount - 1 inSection:0];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self.chatViewModel sendMessage:message];
}

#pragma mark - Getters

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kMinHeight) style:UITableViewStylePlain];
        
        _tableView.estimatedRowHeight = 66;
        _tableView.delegate = self.chatViewModel;
        _tableView.dataSource = self.chatViewModel;
        
        [_tableView registerXMNChatMessageCellClass];
        
        _tableView.backgroundColor = self.view.backgroundColor;
        
        _tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}


- (XMChatBar *)chatBar {
    if (!_chatBar) {
        _chatBar = [[XMChatBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kMinHeight - (self.navigationController.navigationBar.isTranslucent ? 0 : 64), self.view.frame.size.width, kMinHeight)];
        [_chatBar setSuperViewHeight:[UIScreen mainScreen].bounds.size.height - (self.navigationController.navigationBar.isTranslucent ? 0 : 64)];
        _chatBar.delegate = self;
    }
    return _chatBar;
}

@end
