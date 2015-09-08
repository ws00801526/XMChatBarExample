//
//  XMSystemMessage.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMSystemMessage.h"

@implementation XMSystemMessage

- (instancetype)init{
    if ([super init]) {
        self.messageType = XMMessageTypeSystem;
    }
    return self;
}

@end
