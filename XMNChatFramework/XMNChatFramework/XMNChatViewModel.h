//
//  XMNChatViewModel.h
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMNChatServer.h"

@class XMNChatViewModel;
@class XMNChatController;
@class XMNChatBaseMessage;
@protocol XMNChatViewModelDelegate <NSObject>

- (void)chatViewModel:(XMNChatViewModel * _Nonnull)aChatVM
   didUpdateIndexPath:(NSIndexPath * _Nullable)aIndexPath;

@end

@interface XMNChatViewModel : NSObject <UITableViewDataSource>


@property (weak, nonatomic, nullable)   XMNChatController *chatController;

/**
 *  chatVM的会话类型
 */
@property (nonatomic, assign, readonly) XMNChatMode chatMode;

/**
 *  chatVM中负责与服务器进行交互的实例
 */
@property (nonatomic, strong, nullable)   id<XMNChatServer> chatServer;

/**
 *  存储所有信息的数组
 */
@property (nonatomic, strong, readonly, nonnull) NSMutableArray<XMNChatBaseMessage *> *messages;


/**
 *  @brief 接收消息的block
 */
@property (copy, nonatomic, nullable)   void(^receiveMessageBlock)(XMNChatBaseMessage * _Nonnull message, CGFloat progress);

/**
 *  @brief 发送消息的回调block
 *  功能 与delegate 中sendMessage回调相同
 */
@property (copy, nonatomic, nullable)   void(^sendMessageBlock)(XMNChatBaseMessage * _Nonnull message, CGFloat progress);

/**
 *  初始化方法
 *
 *  @param aChatMode 会话类型
 *
 *  @return XMNChatViewModel 实例
 */
- (_Nullable instancetype)initWithChatMode:(XMNChatMode)aChatMode;


/**
 *  @brief 需要实现此方法,进行服务器交互,将消息发送到服务器
 *
 *  @param aMessage 需要发送的消息
 */
- (void)sendMessage:(id _Nonnull)aMessage;

/**
 *  @brief 根据消息类型,过滤已有的消息
 *
 *  @param aType 需要的消息类型
 *
 *  @return 过滤好的消息数组
 */
- (NSArray<XMNChatBaseMessage *> * _Nonnull)filterMessageWithType:(XMNMessageType)aType;

@end
