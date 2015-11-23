//
//  XMNChatServerExample.m
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatServerExample.h"

@interface XMNChatServerExample ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation XMNChatServerExample
@synthesize delegate = _delegate;

- (instancetype)init {
    if ([super init]) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self recieveMessage];
            });
        });
        dispatch_source_set_cancel_handler(_timer, ^{
            NSLog(@"cancel");
            _timer = nil;
        });
        dispatch_resume(_timer);
    }
    return self;
}

- (void)cancelTimer {
    dispatch_source_cancel(_timer);
}

- (void)sendMessage:(NSDictionary *)message withProgressBlock:(XMNChatServerProgressBlock)progressBlock completeBlock:(XMNChatServerCompleteBlock)completeBlock {
    //1.先进度33%
    progressBlock ? progressBlock(.3) : nil;
    //2.延迟1s后进度66%
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        progressBlock ? progressBlock(.7) : nil;
    });
    //3.延迟3s模拟发送消息完毕
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completeBlock ? completeBlock(XMNMessageSendSuccess) : nil;
    });
}

- (void)recieveMessage {
    XMNMessageType messageType = random() % 5 + 1;
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    switch (messageType) {
        case XMNMessageTypeText:
            messageDict[kXMNMessageConfigurationTextKey] = @"test recieve text";
            break;
        case XMNMessageTypeImage:
            messageDict[kXMNMessageConfigurationImageKey]= [UIImage imageNamed:@"test_send"];
        case XMNMessageTypeSystem:
            messageDict[kXMNMessageConfigurationTextKey] = @"2015-11-22";
            NSLog(@"systemCell");
        default:
            break;
    }
    messageDict[kXMNMessageConfigurationTypeKey] = @(messageType);
    messageDict[kXMNMessageConfigurationOwnerKey] = @(messageType == XMNMessageTypeSystem ? XMNMessageOwnerSystem : XMNMessageOwnerOther);
    messageDict[kXMNMessageConfigurationGroupKey] = @(XMNMessageChatSingle);
    [self.delegate recieveMessage:messageDict];
}

@end
