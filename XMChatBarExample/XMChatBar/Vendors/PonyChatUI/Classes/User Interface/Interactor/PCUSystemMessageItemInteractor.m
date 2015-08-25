//
//  PCUSystemMessageItemInteractor.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUSystemMessageItemInteractor.h"
#import "PCUSystemMessageEntity.h"

@implementation PCUSystemMessageItemInteractor

- (instancetype)initWithMessageItem:(PCUMessageEntity *)messageItem {
    self = [super initWithMessageItem:messageItem];
    if (self) {
        _messageText = [(PCUSystemMessageEntity *)messageItem messageText];
    }
    return self;
}

@end
