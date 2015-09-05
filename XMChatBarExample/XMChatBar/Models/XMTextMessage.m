//
//  XMTextMessage.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMTextMessage.h"

@implementation XMTextMessage

- (instancetype)init{
    if ([super init]) {
        self.messageType = XMMessageTypeText;
    }
    return self;
}

@end
