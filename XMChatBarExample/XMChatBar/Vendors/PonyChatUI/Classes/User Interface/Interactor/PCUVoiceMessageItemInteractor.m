//
//  PCUVoiceMessageItemInteractor.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUVoiceMessageItemInteractor.h"
#import "PCUVoiceMessageEntity.h"

@implementation PCUVoiceMessageItemInteractor

- (instancetype)initWithMessageItem:(PCUMessageEntity *)messageItem {
    self = [super initWithMessageItem:messageItem];
    if (self) {
        _voiceURLString = [(PCUVoiceMessageEntity *)messageItem voiceURLString];
        _voiceDuration = [(PCUVoiceMessageEntity *)messageItem voiceDuration];
    }
    return self;
}

@end
