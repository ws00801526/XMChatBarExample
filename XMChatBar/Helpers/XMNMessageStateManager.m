//
//  XMNMessageStateManager.m
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNMessageStateManager.h"

@interface XMNMessageStateManager ()

@property (nonatomic, strong) NSMutableDictionary *messageReadStateDict;
@property (nonatomic, strong) NSMutableDictionary *messageSendStateDict;

@end

@implementation XMNMessageStateManager

+ (instancetype)shareManager {
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if ([super init]) {
        _messageReadStateDict = [NSMutableDictionary dictionary];
        _messageSendStateDict = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - Public Methods

- (XMNMessageSendState)messageSendStateForIndex:(NSUInteger)index {
    if (_messageSendStateDict[@(index)]) {
        return [_messageSendStateDict[@(index)] integerValue];
    }
    return XMNMessageSendSuccess;
}

- (XMNMessageReadState)messageReadStateForIndex:(NSUInteger)index {
    if (_messageReadStateDict[@(index)]) {
        return [_messageReadStateDict[@(index)] integerValue];
    }
    return XMNMessageReaded;
}

- (void)setMessageSendState:(XMNMessageSendState)messageSendState forIndex:(NSUInteger)index {
    _messageSendStateDict[@(index)] = @(messageSendState);
}

- (void)setMessageReadState:(XMNMessageReadState)messageReadState forIndex:(NSUInteger)index {
    _messageReadStateDict[@(index)] = @(messageReadState);
}


- (void)cleanState {
    
    [_messageSendStateDict removeAllObjects];
    [_messageReadStateDict removeAllObjects];
    
}

@end
