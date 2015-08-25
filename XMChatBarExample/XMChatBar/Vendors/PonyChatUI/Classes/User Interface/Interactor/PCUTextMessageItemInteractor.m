//
//  PCUTextMessageItemInteractor.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUTextMessageItemInteractor.h"
#import "PCUTextMessageEntity.h"

@implementation PCUTextMessageItemInteractor

- (instancetype)initWithMessageItem:(PCUMessageEntity *)messageItem {
    self = [super initWithMessageItem:messageItem];
    if (self) {
        _messageText = [(PCUTextMessageEntity *)messageItem messageText];
    }
    return self;
}

@end
