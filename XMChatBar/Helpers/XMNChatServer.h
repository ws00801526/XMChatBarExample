//
//  XMNChatServer.h
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//
//  定义了一个聊天服务器,接受消息,发送消息
//  接受消息提供delegate给XMNChatViewModel
//  发送消息提供ProgressBlock,CompleteBlock回调

#import <UIKit/UIKit.h>

#import "XMNChatUntiles.h"

typedef void(^XMNChatServerProgressBlock)(CGFloat progress);
typedef void(^XMNChatServerCompleteBlock)(XMNMessageSendState sendState);

@protocol XMNChatServerDelegate <NSObject>

- (void)recieveMessage:(NSDictionary *)message;

@end

@protocol XMNChatServer <NSObject>

@property (nonatomic, weak) id<XMNChatServerDelegate> delegate;

- (void)sendMessage:(NSDictionary *)message withProgressBlock:(XMNChatServerProgressBlock)progressBlock completeBlock:(XMNChatServerCompleteBlock)completeBlock;

@end
