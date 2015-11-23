//
//  XMNChatViewModel.h
//  XMNChatExample
//
//  Created by shscce on 15/11/18.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChatServer.h"

@protocol XMNChatViewModelDelegate <NSObject>

@optional
- (void)reloadAfterReceiveMessage:(NSDictionary *)message;
- (void)messageSendStateChanged:(XMNMessageSendState)sendState  withProgress:(CGFloat)progress forIndex:(NSUInteger)index;
- (void)messageReadStateChanged:(XMNMessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index;


@end

@protocol XMNChatMessageCellDelegate;
@interface XMNChatViewModel : NSObject <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign, readonly) NSUInteger messageCount;

@property (nonatomic, weak) id<XMNChatViewModelDelegate> delegate;

- (instancetype)initWithParentVC:(UIViewController<XMNChatMessageCellDelegate> *)parentVC;

/**
 *  添加一条消息到XMNChatViewModel,并不会出发发送消息到服务器的方法
 */
- (void)addMessage:(NSDictionary *)message;

/**
 *  发送一条消息,消息已经通过addMessage添加到XMNChatViewModel数组中了,次方法主要为了XMNChatServer发送消息过程
 */
- (void)sendMessage:(NSDictionary *)message;


- (void)removeMessageAtIndex:(NSUInteger)index;

- (NSDictionary *)messageAtIndex:(NSUInteger)index;

@end
