//
//  XMNChatServerProtocol.h
//  XMNChatFrameworkDemo
//  提供服务器协议
//  自定义的发送接收服务器 需要实现XMNChatServer协议
//  提供两种回调方式,block或者delegate
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChatMessage.h"
#import "XMNChatConfiguration.h"

@protocol XMNChatServerDelegate;
@protocol XMNChatServer <NSObject>

/** 使用代理进行回调 */
@property (weak, nonatomic, nullable)   id<XMNChatServerDelegate> delegate;

@required

/**
 *  需要实现此方法,进行服务器交互,将消息发送到服务器
 *
 *  @param aMessage 发送的消息
 *  回到通过 delegate 或者设置sendMessageBlock实现
 */
- (void)sendMessage:(XMNChatBaseMessage  * _Nonnull)aMessage;

@end

/** 提供delegate方式进行回调 */
@protocol XMNChatServerDelegate <NSObject>

@optional
/**
 *  服务器发送消息的回调
 *
 *  @param aServer   发送的chatServer实例
 *  @param aMessage  被发送的消息
 *  @param aProgress 发送进度
 */
- (void)chatServer:(id<XMNChatServer> _Nonnull)aServer
       sendMessage:(XMNChatBaseMessage  * _Nonnull)aMessage
      withProgress:(CGFloat)aProgress;

/**
 *  服务器接收消息的回调
 *
 *  @param aServer   接收的chatServer实例
 *  @param aMessage  接收的消息
 *  @param aProgress 进度
 */
- (void)chatServer:(id<XMNChatServer> _Nonnull)aServer
    receiveMessage:(XMNChatBaseMessage  * _Nonnull)aMessage
      withProgress:(CGFloat)aProgress;

@end