//
//  PCUCore.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUCore.h"

@implementation PCUCore

- (PCUMessageManager *)messageManager {
    if (_messageManager == nil) {
        _messageManager = [[PCUMessageManager alloc] init];
    }
    return _messageManager;
}

- (PCUWireframe *)wireframe {
    if (_wireframe == nil) {
        _wireframe = [[PCUWireframe alloc] init];
    }
    return _wireframe;
}

@end
