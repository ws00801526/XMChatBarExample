//
//  ChatListController.m
//  SpotGoods
//
//  Created by shscce on 15/8/14.
//  Copyright (c) 2015年 shscce. All rights reserved.
//

#import "ChatListController.h"
#import "ChatViewController.h"

#import "ChatListCell.h"

#import "Masonry.h"
#import "ConvertToCommonEmoticonsHelper.h"

#import "UIViewController+BarItem.h"
#import "EMConversation+Sub.h"
#import "UIViewController+Alert.h"
#import "UIImageView+WebCache.h"

@interface ChatListController ()<UITableViewDelegate,UITableViewDataSource,EMChatManagerDelegate,ChatViewControllerDelegate>

@property (strong, nonatomic) UserModel *chatUserModel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *networkStateView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLeftItemWithImageName:@"nav_back_black" action:@selector(viewBack)];
    self.dataArray = [NSMutableArray array];
    
    self.view.backgroundColor = RGBA(234, 234, 234, 1.0f);
    self.navigationItem.title = @"我的聊天";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.view addSubview:self.tableView];
    
    [self.view updateConstraintsIfNeeded];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    [self removeEmptyConversationsFromDB];
    [self loadChatDatas];
}


- (void)updateViewConstraints{
    [super updateViewConstraints];
    
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChatListCell"];
    }
    EMConversation *conversation = self.dataArray[indexPath.row];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:conversation.ext[@"thumb"]] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
    cell.titleLabel.text = conversation.ext[@"nickName"];
    cell.lastMessageLabel.text = [conversation lastMessage];
    cell.timeLabel.text = [conversation lastMessageTime];
    cell.unReadCount = [conversation unreadMessagesCount];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak __typeof(&*self) wself = self;
    [UserModel getUserInfoWithID:[self.dataArray[indexPath.row] chatter] completeBlock:^(NSUInteger statusCode, NSString *msg, NSDictionary *info) {
        NSError *error;
        wself.chatUserModel = [UserModel objectWithKeyValues:info[@"content"] error:&error];
        if (!error) {
            ChatViewController *chatC = [[ChatViewController alloc] initWithChatter:[self.dataArray[indexPath.row] chatter] conversationType:eConversationTypeChat];
            chatC.delelgate = self;
            [self.navigationController pushViewController:chatC animated:YES];
        }else{
            [self showMessageNotification:@"用户不存在"];
        }
    }];
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = self.dataArray[indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - ChatViewControllerDelegate

- (NSString *)nickNameWithChatter:(NSString *)chatter{
    if (self.chatUserModel.nickName && ![self.chatUserModel.nickName isEqualToString:@"未设置"]) {
        return self.chatUserModel.nickName;
    }
    return @"陌生人";
}

- (NSString *)avatarWithChatter:(NSString *)chatter{
    return self.chatUserModel.thumb ? self.chatUserModel.thumb : @"";
}


#pragma mark - EMChatManagerDelegate

- (void)willReceiveOfflineMessages{
    NSLog(@"begin receive new messages");
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self.dataArray removeAllObjects];
    [self loadChatDatas];
}

- (void)didFinishedReceiveOfflineMessages{
    NSLog(@"end receive messages");
}

-(void)didUnreadMessagesCountChanged
{
    NSLog(@"未读消息数量改变");
    [self.dataArray removeAllObjects];
    [self loadChatDatas];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    NSLog(@"更新群组列表");
    [self.dataArray removeAllObjects];
    [self loadChatDatas];
}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState{
    if (connectionState == eEMConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    }else if (connectionState == eEMConnectionConnected){
        self.tableView.tableHeaderView = nil;
    }
}


#pragma mark - Private Methods

- (void)viewBack{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

- (void)loadChatDatas{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    [self.dataArray addObjectsFromArray:sorte];
    [self.dataArray enumerateObjectsUsingBlock:^(EMConversation *obj, NSUInteger idx, BOOL *stop) {
        [UserModel getUserInfoWithID:[obj chatter] completeBlock:^(NSUInteger statusCode, NSString *msg, NSDictionary *info) {
            NSError *error;
            UserModel *userModel = [UserModel objectWithKeyValues:info[@"content"] error:&error];
            if (!error) {
                if (userModel.nickName && ![userModel.nickName isEqualToString:@"未设置"]) {
                    obj.ext = @{@"nickName":userModel.nickName,@"thumb":userModel.thumb};
                }else{
                    obj.ext = @{@"nickName":@"陌生人",@"thumb":userModel.thumb ? userModel.thumb : @""};
                }
            }
        }];
    }];
    
    [self removeEmptyConversationsFromDB];
    [self.tableView reloadData];
}

-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:SGNOTICATION_NETWORK_STATE_KEY object:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SGNOTICATION_NETWORK_STATE_KEY object:nil];
}

#pragma mark - Getters

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (UIView *)networkStateView{
    if (!_networkStateView) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _networkStateView.backgroundColor = [UIColor orangeColor];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageSendFail"]];
        [_networkStateView addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = kDarkBlackTextColor;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"世界上最遥远的距离就是没网.检查设置";
        [_networkStateView addSubview:label];
        
        UIImageView *arrwoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_center_arrow_right"]];
        [_networkStateView addSubview:arrwoImageView];
        
        [iconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_networkStateView.left).with.offset(4);
            make.centerY.equalTo(_networkStateView.centerY);
        }];
        
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconImageView.right).with.offset(4);
            make.centerY.equalTo(_networkStateView.centerY);
        }];
        
        [arrwoImageView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_networkStateView.right).with.offset(-8);
            make.centerY.equalTo(_networkStateView.centerY);
        }];
        
    }
    return _networkStateView;
}


@end
