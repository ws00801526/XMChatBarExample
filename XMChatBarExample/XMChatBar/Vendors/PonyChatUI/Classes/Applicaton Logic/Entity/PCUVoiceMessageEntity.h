//
//  PCUVoiceMessageEntity.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PonyChatUI.h"

@interface PCUVoiceMessageEntity : PCUMessageEntity

@property (nonatomic, copy) NSString *voiceURLString;

@property (strong, nonatomic) NSData *voiceData;

@property (nonatomic, assign) double voiceDuration;

@end
