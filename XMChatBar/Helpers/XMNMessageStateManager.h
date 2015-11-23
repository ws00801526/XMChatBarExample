//
//  XMNMessageStateManager.h
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMNChatUntiles.h"

@interface XMNMessageStateManager : NSObject

+ (instancetype)shareManager;


#pragma mark - Public Methods

- (XMNMessageSendState)messageSendStateForIndex:(NSUInteger)index;
- (XMNMessageReadState)messageReadStateForIndex:(NSUInteger)index;

- (void)setMessageSendState:(XMNMessageSendState)messageSendState forIndex:(NSUInteger)index;
- (void)setMessageReadState:(XMNMessageReadState)messageReadState forIndex:(NSUInteger)index;

- (void)cleanState;

@end

