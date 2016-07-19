//
//  XMNAudioPlayer.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMNAudioFile.h"

@class XMNAudioDecoder;
FOUNDATION_EXPORT NSString *const kXMNAudioPlayerErrorDomain;

typedef NS_ENUM(NSUInteger, XMNAudioPlayerStatus) {
    XMNAudioPlayerStatusPlaying,
    XMNAudioPlayerStatusPaused,
    XMNAudioPlayerStatusIdle,
    XMNAudioPlayerStatusFinished,
    XMNAudioPlayerStatusBuffering,
    XMNAudioPlayerStatusError
};

typedef NS_ENUM(NSInteger, XMNAudioPlayerErrorCode) {
    XMNAudioPlayerUnknownError = 0,
    XMNAudioPlayerNetworkError,
    XMNAudioPlayerDecodingError
};

@interface XMNAudioPlayer : NSObject

@property (assign, readonly) XMNAudioPlayerStatus status;
@property (strong, readonly) NSError *error;

@property (nonatomic, readonly) XMNAudioDecoder *decoder;

@property (nonatomic, readonly) id <XMNAudioFile> audioFile;
@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) double volume;

@property (nonatomic, copy) NSArray *analyzers;

@property (nonatomic, readonly) NSString *cachedPath;
@property (nonatomic, readonly) NSURL *cachedURL;

@property (nonatomic, readonly) NSString *sha256;

@property (nonatomic, readonly) NSUInteger expectedLength;
@property (nonatomic, readonly) NSUInteger receivedLength;
@property (nonatomic, readonly) NSUInteger downloadSpeed;

@property (nonatomic, assign, readonly) double bufferingRatio;

+ (instancetype)playerWithAudioFile:(id <XMNAudioFile>)audioFile;
- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile;

+ (double)volume;
+ (void)setVolume:(double)volume;

+ (NSArray *)analyzers;
+ (void)setAnalyzers:(NSArray *)analyzers;

+ (void)setHintWithAudioFile:(id <XMNAudioFile>)audioFile;

- (void)play;
- (void)pause;
- (void)stop;

@end
