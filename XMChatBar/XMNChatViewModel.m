//
//  XMNChatViewModel.m
//  XMNChatExample
//
//  Created by shscce on 15/11/18.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatViewModel.h"

#import "XMNChatTextMessageCell.h"
#import "XMNChatImageMessageCell.h"
#import "XMNChatVoiceMessageCell.h"
#import "XMNChatSystemMessageCell.h"
#import "XMNChatLocationMessageCell.h"

#import "XMNAVAudioPlayer.h"
#import "XMNChatServerExample.h"
#import "XMNMessageStateManager.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "XMNChatMessageCell+XMNCellIdentifier.h"

@interface XMNChatViewModel () <XMNChatServerDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) UIViewController<XMNChatMessageCellDelegate> *parentVC;
@property (nonatomic, strong) id<XMNChatServer> chatServer;

@end

@implementation XMNChatViewModel

- (instancetype)initWithParentVC:(UIViewController<XMNChatMessageCellDelegate> *)parentVC {
    if ([super init]) {
        _dataArray = [NSMutableArray array];
        _parentVC = parentVC;
        _chatServer = [[XMNChatServerExample alloc] init];
        _chatServer.delegate = self;
    }
    return self;
}

- (void)dealloc {
    
    [[XMNMessageStateManager shareManager] cleanState];
    [(XMNChatServerExample *)self.chatServer cancelTimer];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = self.dataArray[indexPath.row];
    NSString *identifier = [XMNChatMessageCell cellIdentifierForMessageConfiguration:@{kXMNMessageConfigurationGroupKey:message[kXMNMessageConfigurationGroupKey],kXMNMessageConfigurationOwnerKey:message[kXMNMessageConfigurationOwnerKey],kXMNMessageConfigurationTypeKey:message[kXMNMessageConfigurationTypeKey]}];
    
    XMNChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [messageCell configureCellWithData:message];
    messageCell.messageReadState = [[XMNMessageStateManager shareManager] messageReadStateForIndex:indexPath.row];
    messageCell.messageSendState = [[XMNMessageStateManager shareManager] messageSendStateForIndex:indexPath.row];
    messageCell.delegate = self.parentVC;
    
    return messageCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *message = self.dataArray[indexPath.row];
    NSString *identifier = [XMNChatMessageCell cellIdentifierForMessageConfiguration:@{kXMNMessageConfigurationGroupKey:message[kXMNMessageConfigurationGroupKey],kXMNMessageConfigurationOwnerKey:message[kXMNMessageConfigurationOwnerKey],kXMNMessageConfigurationTypeKey:message[kXMNMessageConfigurationTypeKey]}];

    return [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(XMNChatMessageCell *cell) {
        [cell configureCellWithData:message];
    }];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //设置正确的voiceMessageCell播放状态
    NSDictionary *message = self.dataArray[indexPath.row];
    if ([message[kXMNMessageConfigurationTypeKey] integerValue] == XMNMessageTypeVoice) {
        if (indexPath.row == [[XMNAVAudioPlayer sharePlayer] index]) {
            [(XMNChatVoiceMessageCell *)cell setVoiceMessageState:[[XMNAVAudioPlayer sharePlayer] audioPlayerState]];
        }
    }
    
}

#pragma mark - XMNChatServerDelegate

- (void)recieveMessage:(NSDictionary *)message {
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:message];
    [self addMessage:messageDict];
    [self.delegate reloadAfterReceiveMessage:messageDict];
}

#pragma mark - Public Methods

- (void)addMessage:(NSDictionary *)message {
    [self.dataArray addObject:message];
}

- (void)sendMessage:(NSDictionary *)message{
    
    __weak __typeof(&*self) wself = self;
    [[XMNMessageStateManager shareManager] setMessageSendState:XMNMessageSendStateSending forIndex:[self.dataArray indexOfObject:message]];
    [self.delegate messageSendStateChanged:XMNMessageSendStateSending withProgress:0.0f forIndex:[self.dataArray indexOfObject:message]];
    [self.chatServer sendMessage:message withProgressBlock:^(CGFloat progress) {
        __strong __typeof(wself)self = wself;
        [self.delegate messageSendStateChanged:XMNMessageSendStateSending withProgress:progress forIndex:[self.dataArray indexOfObject:message]];
    } completeBlock:^(XMNMessageSendState sendState) {
        __strong __typeof(wself)self = wself;
        [[XMNMessageStateManager shareManager] setMessageSendState:sendState forIndex:[self.dataArray indexOfObject:message]];
        [self.delegate messageSendStateChanged:sendState withProgress:1.0f forIndex:[self.dataArray indexOfObject:message]];
    }];
}

- (void)removeMessageAtIndex:(NSUInteger)index {
    if (index < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:index];
    }
}

- (NSDictionary *)messageAtIndex:(NSUInteger)index {
    if (index < self.dataArray.count) {
        return self.dataArray[index];
    }
    return nil;
}


#pragma mark - Setters

- (void)setChatServer:(id<XMNChatServer>)chatServer {
    if (_chatServer == chatServer) {
        return;
    }
    _chatServer = chatServer;

}

#pragma mark - Getters

- (NSUInteger)messageCount {
    return self.dataArray.count;
}

@end
