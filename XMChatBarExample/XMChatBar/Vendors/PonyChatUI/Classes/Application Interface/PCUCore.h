//
//  PCUCore.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUMessageManager.h"
#import "PCUWireframe.h"

@class PCUImageMessageEntity, PCUVoiceMessageEntity;

@protocol PCUVoiceStatus <NSObject>

@required
- (BOOL)isPlaying;
- (void)setPlay;
- (void)setPause;

@end

@protocol PCUDelegate <NSObject>

@optional
- (void)PCUImageMessageItemTapped:(PCUImageMessageEntity *)messageItem;
- (void)PCUVoiceMessageItemTapped:(PCUVoiceMessageEntity *)messageItem
                      voiceStatus:(id<PCUVoiceStatus>)voiceStatus;

@end

@interface PCUCore : NSObject

@property (nonatomic, strong) PCUMessageManager *messageManager;

@property (nonatomic, strong) PCUWireframe *wireframe;

@end
