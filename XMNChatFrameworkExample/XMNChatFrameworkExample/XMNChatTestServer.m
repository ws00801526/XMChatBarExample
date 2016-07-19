//
//  XMNChatTestServer.m
//  XMNChatFrameworkExample
//
//  Created by XMFraker on 16/6/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatTestServer.h"

#import <XMNChat/XMNChatServer.h>

@implementation XMNChatTestServer
@synthesize delegate = _delegate;

- (void)sendMessage:(XMNChatBaseMessage *)aMessage {
    
    NSLog(@"do send message to your server here");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        aMessage.state = XMNMessageStateFailed;
        aMessage.substate = XMNMessageSubStateSendContentFaield;
    });
}

@end
