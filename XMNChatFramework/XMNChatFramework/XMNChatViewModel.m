//
//  XMNChatViewModel.m
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatViewModel.h"
#import "XMNChatMessage.h"

#import "XMNChatOwnCell.h"
#import "XMNChatOtherCell.h"
#import "XMNChatSystemCell.h"

#import "XMNChatController.h"

@interface XMNChatViewModel () <UITableViewDataSource,XMNChatServerDelegate>

@property (nonatomic, strong) NSMutableArray<XMNChatBaseMessage *> *messages;
@property (nonatomic, assign) XMNChatMode chatMode;

@end

@implementation XMNChatViewModel

- (instancetype)initWithChatMode:(XMNChatMode)aChatMode {
    
    if (self = [super init]) {
        
        _chatMode = aChatMode;
        _messages = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Methods

/**
 *  需要实现此方法,进行服务器交互,将消息发送到服务器
 *
 *  @param aMessage 发送的消息
 */
- (void)sendMessage:(id _Nonnull)aMessage {
    
    if (aMessage) {
        [self.messages addObject:aMessage];
        
        /** 如果服务器存在 则通过向服务器发送消息 */
        if (self.chatServer) {
            [self.chatServer sendMessage:aMessage];
        }
    }
}

- (NSArray *)filterMessageWithType:(XMNMessageType)aType {
    
    return [self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type == %d",(int)aType]]];
}

#pragma mark - XMNChatServerDelegate

- (void)chatServer:(id<XMNChatServer>)aServer
       sendMessage:(XMNChatBaseMessage *)aMessage
      withProgress:(CGFloat)aProgress {
    
    XMNLog(@"chatServer send message:%@\nit will call chatVM block",aMessage);
    self.sendMessageBlock ? self.sendMessageBlock(aMessage, aProgress) : nil;
}

- (void)chatServer:(id<XMNChatServer>)aServer
    receiveMessage:(XMNChatBaseMessage *)aMessage
      withProgress:(CGFloat)aProgress {
    
    XMNLog(@"chatServer recieve message:%@\nit will call chatVM block",aMessage);
    
    [self.messages addObject:aMessage];
    self.receiveMessageBlock ? self.receiveMessageBlock(aMessage, aProgress) : nil;
}

#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    XMNChatBaseMessage *message = self.messages[indexPath.row];
    if (message.owner == XMNMessageOwnerOther) {
        XMNChatOtherCell *otherCell = [tableView dequeueReusableCellWithIdentifier:self.chatMode == XMNChatSingle ? kXMNChatOtherSingleCellIdentifier : kXMNChatOtherGroupCellIdentifier];
        [otherCell configCellWithMessage:message];
        otherCell.delegate = (id<XMNChatCellDelegate>)self.chatController;
        return otherCell;
    }else if (message.owner == XMNMessageOwnerSelf) {
        XMNChatOwnCell *ownCell = [tableView dequeueReusableCellWithIdentifier:self.chatMode == XMNChatSingle ? kXMNChatOwnSingleCellIdentifier : kXMNChatOwnGroupCellIdentifier];
        [ownCell configCellWithMessage:message];
        ownCell.delegate = (id<XMNChatCellDelegate>)self.chatController;
        return ownCell;
    }else {
        
        XMNChatSystemCell *systemCell = [tableView dequeueReusableCellWithIdentifier:kXMNChatSystemCellIdentifier];
        [systemCell configCellWithMessage:message];
        return systemCell;
    }
}

@end
