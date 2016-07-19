//
//  XMNAudioPlayer_XMNPrivate.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioPlayer.h"

@class XMNAudioFileProvider;
@class XMNAudioPlaybackItem;
@class XMNAudioDecoder;

@interface XMNAudioPlayer ()

@property (assign) XMNAudioPlayerStatus status;
@property (strong) NSError *error;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger timingOffset;

@property (nonatomic, readonly) XMNAudioFileProvider *fileProvider;
@property (nonatomic, strong) XMNAudioPlaybackItem *playbackItem;
@property (nonatomic, strong) XMNAudioDecoder *decoder;

@property (nonatomic, assign) double bufferingRatio;

#if TARGET_OS_IPHONE
@property (nonatomic, assign, getter=isPausedByInterruption) BOOL pausedByInterruption;
#endif /* TARGET_OS_IPHONE */
@end
