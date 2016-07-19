//
//  XMNChatController+XMNVoice.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <XMNChat/XMNChat.h>

@interface XMNChatController (XMNVoice)

- (void)setupVoiceUI;

- (void)playVoiceMessage:(XMNChatVoiceMessage *)aMessage;
- (void)stopPlaying;

- (void)clean;

@end
