//
//  PCUVoiceMessageItemInteractor.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUMessageItemInteractor.h"

@interface PCUVoiceMessageItemInteractor : PCUMessageItemInteractor

@property (nonatomic, copy) NSString *voiceURLString;

@property (nonatomic, assign) double voiceDuration;

@end
