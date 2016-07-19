//
//  XMNAudioPlayer.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioPlayer.h"
#import "XMNAudioDecoder.h"
#import "XMNAudioFileProvider.h"
#import "XMNAudioPlaybackItem.h"
#import "XMNAudioRunLoop.h"

#import "XMNAudioPlayer_XMNPrivate.h"

NSString *const kXMNAudioPlayerErrorDomain = @"com.XMFraker.XMNAudio.XMNAudioPlayer.kXMNAudioPlayerErrorDomain";

@interface XMNAudioPlayer ()
{
@private
    id <XMNAudioFile> _audioFile;
    
    XMNAudioPlayerStatus _status;
    NSError *_error;
    
    NSTimeInterval _duration;
    NSInteger _timingOffset;
    
    XMNAudioFileProvider *_fileProvider;
    XMNAudioPlaybackItem *_playbackItem;
    XMNAudioDecoder *_decoder;
    
    double _bufferingRatio;
#if TARGET_OS_IPHONE
    BOOL _pausedByInterruption;
#endif /* TARGET_OS_IPHONE */
}

@end

@implementation XMNAudioPlayer
@synthesize status = _status;
@synthesize error = _error;

@synthesize duration = _duration;
@synthesize timingOffset = _timingOffset;

@synthesize decoder = _decoder;
@synthesize fileProvider = _fileProvider;
@synthesize playbackItem = _playbackItem;

@synthesize bufferingRatio = _bufferingRatio;

#if TARGET_OS_IPHONE
@synthesize pausedByInterruption = _pausedByInterruption;
#endif /* TARGET_OS_IPHONE */


#pragma mark - Life Cycle

+ (instancetype)playerWithAudioFile:(id<XMNAudioFile>)audioFile {
    
    return [[[self class] alloc] initWithAudioFile:audioFile];
}

- (instancetype)initWithAudioFile:(id<XMNAudioFile>)audioFile {
    
    if (self = [super init]) {
        
        _audioFile = audioFile;
        _status = XMNAudioPlayerStatusIdle;
        
        _fileProvider = [XMNAudioFileProvider fileProviderWithAudioFile:_audioFile];
        if (_fileProvider == nil) {
            return nil;
        }
        _bufferingRatio = (double)[_fileProvider receivedLength] / [_fileProvider expectedLength];
    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
}

#pragma mark - Methods

- (void)play {
    
    @synchronized(self) {
        if (_status != XMNAudioPlayerStatusPaused &&
            _status != XMNAudioPlayerStatusIdle &&
            _status != XMNAudioPlayerStatusFinished) {
            return;
        }
        
        if ([[XMNAudioRunLoop sharedLoop] currentPlayer] != self) {
            [[XMNAudioRunLoop sharedLoop] pause];
            [[XMNAudioRunLoop sharedLoop] setCurrentPlayer:self];
        }
        
        [[XMNAudioRunLoop sharedLoop] play];
    }
}

- (void)pause {
    
    @synchronized(self) {
        if (_status == XMNAudioPlayerStatusPaused ||
            _status == XMNAudioPlayerStatusIdle ||
            _status == XMNAudioPlayerStatusFinished) {
            return;
        }
        
        if ([[XMNAudioRunLoop sharedLoop] currentPlayer] != self) {
            return;
        }
        
        [[XMNAudioRunLoop sharedLoop] pause];
    }
}

- (void)stop {
    
    @synchronized(self) {
        if (_status == XMNAudioPlayerStatusIdle) {
            return;
        }
        
        if ([[XMNAudioRunLoop sharedLoop] currentPlayer] != self) {
            return;
        }
        [[XMNAudioRunLoop sharedLoop] stop];
        [[XMNAudioRunLoop sharedLoop] setCurrentPlayer:nil];
    }
}

#pragma mark - Setters


- (void)setCurrentTime:(NSTimeInterval)currentTime {
    
    if ([[XMNAudioRunLoop sharedLoop] currentPlayer] != self) {
        return;
    }
    [[XMNAudioRunLoop sharedLoop] setCurrentTime:currentTime];
}

- (void)setVolume:(double)volume {
    
    [[self class] setVolume:volume];
}

- (void)setAnalyzers:(NSArray *)analyzers {
    
    [[self class] setAnalyzers:analyzers];
}

#pragma mark - Getters

- (NSURL *)url {
    
    return [_audioFile audioFileURL];
}

- (id <XMNAudioFile>)audioFile {
    
    return _audioFile;
}


- (NSTimeInterval)currentTime {
    
    if ([[XMNAudioRunLoop sharedLoop] currentPlayer] != self) {
        return 0.0;
    }
    return [[XMNAudioRunLoop sharedLoop] currentTime];
}



- (double)volume {
    
    return [[self class] volume];
}

- (NSArray *)analyzers {
    
    return [[self class] analyzers];
}



- (NSString *)cachedPath {
    
    return [_fileProvider cachedPath];
}

- (NSURL *)cachedURL {
    
    return [_fileProvider cachedURL];
}

- (NSString *)sha256 {
    
    return [_fileProvider sha256];
}

- (NSUInteger)expectedLength {
    
    return [_fileProvider expectedLength];
}

- (NSUInteger)receivedLength {
    
    return [_fileProvider receivedLength];
}

- (NSUInteger)downloadSpeed {
    
    return [_fileProvider downloadSpeed];
}

#pragma mark - Class Methods

+ (double)volume {
    
    return [[XMNAudioRunLoop sharedLoop] volume];
}

+ (void)setVolume:(double)volume {
    
    [[XMNAudioRunLoop sharedLoop] setVolume:volume];
}

+ (NSArray *)analyzers {
    
    return [[XMNAudioRunLoop sharedLoop] analyzers];
}

+ (void)setAnalyzers:(NSArray *)analyzers {
    
    [[XMNAudioRunLoop sharedLoop] setAnalyzers:analyzers];
}

+ (void)setHintWithAudioFile:(id <XMNAudioFile>)audioFile {
    
    [XMNAudioFileProvider setHintWithAudioFile:audioFile];
}
@end
