//
//  XMNAudioRunLoop.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioRunLoop.h"
#import "XMNAudioPlayer.h"
#import "XMNAudioFileProvider.h"
#import "XMNAudioPlaybackItem.h"
#import "XMNAudioLPCM.h"
#import "XMNAudioDecoder.h"
#import "XMNAudioRender.h"

#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <pthread.h>
#include <sched.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIDevice.h>

#import "XMNAudioPlayer_XMNPrivate.h"

NSString *const kXMNAudioPlayerVolumeKey = @"com.XMFraker.XMNAudio.XMNAudioPlayer.XMNAudioPlayerVolume";
/** 每个缓冲区缓冲的时间,单位ms*/
const NSUInteger kXMNAudioPlayerBufferTime = 200;

typedef NS_ENUM(uint64_t, event_type) {
    event_play,
    event_pause,
    event_stop,
    event_seek,
    event_player_changed,
    event_provider_events,
    event_finalizing,
#if TARGET_OS_IPHONE
    event_interruption_begin,
    event_interruption_end,
    event_old_device_unavailable,
#endif /* TARGET_OS_IPHONE */
    
    event_first = event_play,
#if TARGET_OS_IPHONE
    event_last = event_old_device_unavailable,
#else /* TARGET_OS_IPHONE */
    event_last = event_finalizing,
#endif /* TARGET_OS_IPHONE */
    
    event_timeout
};

@interface XMNAudioRunLoop ()
{
@private
    XMNAudioRender *_renderer;
    XMNAudioPlayer *_currentPlayer;
    
    XMNAudioFileProviderEventBlock _fileProviderEventBlock;
    
    int _kq;
    void *_lastKQUserData;
    pthread_mutex_t _mutex;
    pthread_t _thread;
}

@property (nonatomic, assign, readonly) NSUInteger decoderBufferSize;


@end

@implementation XMNAudioRunLoop
@synthesize currentPlayer = _currentPlayer;
@dynamic analyzers;

#pragma mark - Life Cycle

+ (instancetype)sharedLoop {
    
    static XMNAudioRunLoop *sharedLoop = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoop = [[XMNAudioRunLoop alloc] init];
    });
    
    return sharedLoop;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _kq = kqueue();
        pthread_mutex_init(&_mutex, NULL);
        
#if TARGET_OS_IPHONE
        [self setupAudioSession];
#endif /* TARGET_OS_IPHONE */
        
        _renderer = [XMNAudioRender rendererWithBufferTime:kXMNAudioPlayerBufferTime];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kXMNAudioPlayerVolumeKey] != nil) {
            [self setVolume:[[NSUserDefaults standardUserDefaults] doubleForKey:kXMNAudioPlayerVolumeKey]];
        }
        else {
            [self setVolume:1.0];
        }
        
        [self setupFileProviderEventBlock];
        [self enableEvents];
        [self setupThread];
    }
    
    return self;
}

- (void)dealloc {
    
    
    [_renderer tearDown];
    
    [self sendEvent:event_finalizing];
    pthread_join(_thread, NULL);
    
    close(_kq);
    pthread_mutex_destroy(&_mutex);
    
    /** 移除通知 */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
}

#pragma mark - Methods


/// ========================================
/// @name   Public Methods
/// ========================================

- (void)play {
    
    [self sendEvent:event_play];
}

- (void)pause {
    
    [self sendEvent:event_pause];
}

- (void)stop {
    
    [self sendEvent:event_stop];
}

/**
 *  消息转发,让_renderer处理setAnalyers,analyzers
 *
 *  @param aSelector 被转发的消息SEL
 *
 *  @return 处理转发消息的对象
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if (aSelector == @selector(analyzers) ||
        aSelector == @selector(setAnalyzers:)) {
        return _renderer;
    }
    return [super forwardingTargetForSelector:aSelector];
}


/// ========================================
/// @name   Private Methods
/// ========================================


/**
 *  初始化播放循环线程
 */
- (void)setupThread {
    
    pthread_attr_t attr;
    struct sched_param sched_param;
    int sched_policy = SCHED_FIFO;
    
    pthread_attr_init(&attr);
    pthread_attr_setschedpolicy(&attr, sched_policy);
    sched_param.sched_priority = sched_get_priority_max(sched_policy);
    pthread_attr_setschedparam(&attr, &sched_param);
    
    pthread_create(&_thread, &attr, event_loop_main, (__bridge void *)self);
    
    pthread_attr_destroy(&attr);
}

/**
 *  初始化fileProvider回到哦block
 */
- (void)setupFileProviderEventBlock {
    
    __unsafe_unretained XMNAudioRunLoop *eventLoop = self;
    _fileProviderEventBlock = ^{
        [eventLoop sendEvent:event_provider_events];
    };
}


/**
 *  初始化音频播放的AudioSession
 */
- (void)setupAudioSession {
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    /** 创建播放器通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSensorStateChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSessionRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}


/**
 *  处理播放器 播放,解码循环事件
 *
 *  @param player 播放器实例
 */
- (void)handlePlayer:(XMNAudioPlayer *)player
{
    if (player == nil) {
        return;
    }
    
    if ([player status] != XMNAudioPlayerStatusPlaying) {
        return;
    }
    
    if ([[player fileProvider] isFailed]) {
        [player setError:[NSError errorWithDomain:kXMNAudioPlayerErrorDomain
                                               code:XMNAudioPlayerNetworkError
                                           userInfo:nil]];
        [player setStatus:XMNAudioPlayerStatusError];
        return;
    }
    
    if (![[player fileProvider] isReady]) {
        [player setStatus:XMNAudioPlayerStatusBuffering];
        return;
    }
   
    /** 配置playerItem */
    if ([player playbackItem] == nil) {
        [player setPlaybackItem:[XMNAudioPlaybackItem playbackItemWithFileProvider:[player fileProvider]]];
        if (![[player playbackItem] open]) {
            [player setError:[NSError errorWithDomain:kXMNAudioPlayerErrorDomain
                                                   code:XMNAudioPlayerDecodingError
                                               userInfo:nil]];
            [player setStatus:XMNAudioPlayerStatusError];
            return;
        }
        [player setDuration:(NSTimeInterval)[[player playbackItem] estimatedDuration] / 1000.0];
    }
    
    if ([player decoder] == nil) {
        [player setDecoder:[XMNAudioDecoder decoderWithPlaybackItem:[player playbackItem]
                                                           bufferSize:self.decoderBufferSize]];
        if (![[player decoder] setup] || ![_renderer setupWithAudioStreamDescription:self.currentPlayer.decoder.outputFormat]) {
            [player setError:[NSError errorWithDomain:kXMNAudioPlayerErrorDomain
                                                   code:XMNAudioPlayerDecodingError
                                               userInfo:nil]];
            [player setStatus:XMNAudioPlayerStatusError];
            return;
        }
    }
    
    switch ([[player decoder] decodeOnce]) {
        case XMNAudioDecoderSucceeded:
            break;
            
        case XMNAudioDecoderFailed:
            [player setError:[NSError errorWithDomain:kXMNAudioPlayerErrorDomain
                                                   code:XMNAudioPlayerDecodingError
                                               userInfo:nil]];
            [player setStatus:XMNAudioPlayerStatusError];
            return;
            
        case XMNAudioDecoderEndEncountered:
            [_renderer stop];
            [player setDecoder:nil];
            [player setPlaybackItem:nil];
            [player setStatus:XMNAudioPlayerStatusFinished];
            return;
            
        case XMNAudioDecoderWaiting:
            [player setStatus:XMNAudioPlayerStatusBuffering];
            return;
    }
    
    void *bytes = NULL;
    NSUInteger length = 0;
    [[[player decoder] lpcm] readBytes:&bytes length:&length];
    if (bytes != NULL) {
        [_renderer renderBytes:bytes length:length];
        free(bytes);
    }
}

#pragma mark - Event Methods


/**
 *  开启event事件监听
 */
- (void)enableEvents {
    
    for (uint64_t event = event_first; event <= event_last; ++event) {
        struct kevent kev;
        EV_SET(&kev, event, EVFILT_USER, EV_ADD | EV_ENABLE | EV_CLEAR, 0, 0, NULL);
        kevent(_kq, &kev, 1, NULL, 0, NULL);
    }
}

/**
 *  发送一个event事件
 *
 *  @param event event事件类型
 */
- (void)sendEvent:(event_type)event {
    
    [self sendEvent:event userData:NULL];
}

/**
 *  发送一个event事件,带有输入参数
 *
 *  @param event    event事件类型
 *  @param userData 输入的参数
 */
- (void)sendEvent:(event_type)event userData:(void *)userData {
    
    struct kevent kev;
    EV_SET(&kev, event, EVFILT_USER, 0, NOTE_TRIGGER, 0, userData);
    kevent(_kq, &kev, 1, NULL, 0, NULL);
}

- (event_type)waitForEvent {
    
    return [self waitForEventWithTimeout:NSUIntegerMax];
}

- (event_type)waitForEventWithTimeout:(NSUInteger)timeout {
    
    struct timespec _ts;
    struct timespec *ts = NULL;
    if (timeout != NSUIntegerMax) {
        ts = &_ts;
        
        ts->tv_sec = timeout / 1000;
        ts->tv_nsec = (timeout % 1000) * 1000;
    }
    
    while (1) {
        struct kevent kev;
        int n = kevent(_kq, NULL, 0, &kev, 1, ts);
        if (n > 0) {
            if (kev.filter == EVFILT_USER &&
                kev.ident >= event_first &&
                kev.ident <= event_last) {
                _lastKQUserData = kev.udata;
                return kev.ident;
            }
        }
        else {
            break;
        }
    }
    return event_timeout;
}

/**
 *  线程的主循环函数
 *
 *  @param info info指针
 */
static void *event_loop_main(void *info) {
    
    pthread_setname_np("com.XMFraker.XMNAudio.XMNAudioPlayer.event-loop");
    
    __unsafe_unretained XMNAudioRunLoop *eventLoop = (__bridge XMNAudioRunLoop *)info;
    @autoreleasepool {
        [eventLoop eventLoop];
    }
    return NULL;
}

/**
 *  线程的循环方法
 */
- (void)eventLoop {
    
    XMNAudioPlayer *player = nil;
    
    while (1) {
        @autoreleasepool {
            if (player != nil) {
                switch ([player status]) {
                    case XMNAudioPlayerStatusPaused:
                    case XMNAudioPlayerStatusIdle:
                    case XMNAudioPlayerStatusFinished:
                    case XMNAudioPlayerStatusBuffering:
                    case XMNAudioPlayerStatusError:
                        if (![self handleEvent:[self waitForEvent]
                                   withPlayer:&player]) {
                            return;
                        }
                        break;
                        
                    default:
                        break;
                }
            } else {
                if (![self handleEvent:[self waitForEvent]
                           withPlayer:&player]) {
                    return;
                }
            }
            
            if (![self handleEvent:[self waitForEventWithTimeout:0]
                       withPlayer:&player]) {
                return;
            }
            
            if (player != nil) {
                [self handlePlayer:player];
            }
        }
    }
}

/**
 *  处理线程的event事件
 *
 *  @param event    中断的event事件类型
 *  @param player   中断输入的player
 *
 *  @return 是否处理成功
 */
- (BOOL)handleEvent:(event_type)event withPlayer:(XMNAudioPlayer **)player {
    if (event == event_play) {
        if (*player != nil &&
            ([*player status] == XMNAudioPlayerStatusPaused ||
             [*player status] == XMNAudioPlayerStatusIdle ||
             [*player status] == XMNAudioPlayerStatusFinished)) {
                
                if ([_renderer isInterrupted]) {
#if TARGET_OS_IPHONE
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wdeprecated"
                    const OSStatus status = AudioSessionSetActive(TRUE);
# pragma clang diagnostic pop
                    if (status == noErr) {
#endif /* TARGET_OS_IPHONE */
                        [*player setStatus:XMNAudioPlayerStatusPlaying];
                        [_renderer setInterrupted:NO];
#if TARGET_OS_IPHONE
                    }
#endif /* TARGET_OS_IPHONE */
                }
                else {
                    [*player setStatus:XMNAudioPlayerStatusPlaying];
                }
            }
    }
    else if (event == event_pause) {
        if (*player != nil &&
            ([*player status] != XMNAudioPlayerStatusPaused &&
             [*player status] != XMNAudioPlayerStatusIdle &&
             [*player status] != XMNAudioPlayerStatusFinished)) {
                [_renderer stop];
                [*player setStatus:XMNAudioPlayerStatusPaused];
            }
    }
    else if (event == event_stop) {
        if (*player != nil &&
            [*player status] != XMNAudioPlayerStatusIdle) {
            if ([*player status] != XMNAudioPlayerStatusPaused) {
                [_renderer stop];
            }
            [_renderer flush];
            [*player setDecoder:nil];
            [*player setPlaybackItem:nil];
            [*player setStatus:XMNAudioPlayerStatusIdle];
        }
    }
    else if (event == event_seek) {
        if (*player != nil &&
            [*player decoder] != nil) {
            NSUInteger milliseconds = MIN((NSUInteger)(uintptr_t)_lastKQUserData,
                                          [[*player playbackItem] estimatedDuration]);
            [*player setTimingOffset:(NSInteger)milliseconds - (NSInteger)[_renderer currentTime]];
            [[*player decoder] seekToTime:milliseconds];
            [_renderer flushShouldResetTiming:NO];
        }
    }
    else if (event == event_player_changed) {
        [_renderer stop];
        [_renderer flush];
        
        [[*player fileProvider] setEventBlock:NULL];
        *player = _currentPlayer;
        [[*player fileProvider] setEventBlock:_fileProviderEventBlock];
    }
    else if (event == event_provider_events) {
        if (*player != nil &&
            [*player status] == XMNAudioPlayerStatusBuffering) {
            [*player setStatus:XMNAudioPlayerStatusPlaying];
        }
        
        [*player setBufferingRatio:(double)[[*player fileProvider] receivedLength] / [[*player fileProvider] expectedLength]];
    }
    else if (event == event_finalizing) {
        return NO;
    }
#if TARGET_OS_IPHONE
    else if (event == event_interruption_begin) {
        if (*player != nil &&
            ([*player status] != XMNAudioPlayerStatusPaused &&
             [*player status] != XMNAudioPlayerStatusIdle &&
             [*player status] != XMNAudioPlayerStatusFinished)) {
                [self performSelector:@selector(pause) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
                [*player setPausedByInterruption:YES];
            }
    }
    else if (event == event_interruption_end) {
        const AudioSessionInterruptionType interruptionType = (AudioSessionInterruptionType)(uintptr_t)_lastKQUserData;
        NSAssert(interruptionType == kAudioSessionInterruptionType_ShouldResume ||
                 interruptionType == kAudioSessionInterruptionType_ShouldNotResume,
                 @"invalid interruption type");
        
        if (interruptionType == kAudioSessionInterruptionType_ShouldResume) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            OSStatus status;
            status = AudioSessionSetActive(TRUE);
            NSAssert(status == noErr, @"failed to activate audio session");
#pragma clang diagnostic pop
            if (status == noErr) {
                [_renderer setInterrupted:NO];
                
                if (*player != nil &&
                    [*player status] == XMNAudioPlayerStatusPaused &&
                    [*player isPausedByInterruption]) {
                    [*player setPausedByInterruption:NO];
                    [self performSelector:@selector(play) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
                }
            }
        }
    }
    else if (event == event_old_device_unavailable) {
        if (*player != nil) {
            if ([*player status] != XMNAudioPlayerStatusPaused &&
                [*player status] != XMNAudioPlayerStatusIdle &&
                [*player status] != XMNAudioPlayerStatusFinished) {
                [self performSelector:@selector(pause)
                             onThread:[NSThread mainThread]
                           withObject:nil
                        waitUntilDone:NO];
            }
            
            [*player setPausedByInterruption:NO];
        }
    }
#endif /* TARGET_OS_IPHONE */
    else if (event == event_timeout) {
    }
    
    return YES;
}

#pragma mark - AVAudioSession Notification Methods

- (void)handleSensorStateChange:(NSNotification *)notification {
    
    if ([self isUseOutputExceptBuiltInPort]) {
        
        /** 使用耳机时 不监听 */
        return;
    }
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        if ([[UIDevice currentDevice] proximityState] == YES) {
//            XMNLog(@"使用听筒");
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }else {
//            XMNLog(@"正在使用扬声器播放");
            /** 使用扬声器播放 */
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
}

- (void)handleSessionRouteChange:(NSNotification *)notification {
    
    
    AVAudioSessionRouteChangeReason reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            /** 如果新设备可用,使用新设备播放音频 */
            if ([self isUseOutputExceptBuiltInPort]) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            }else {
                /** 继续使用旧设备播放音频 */
            }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            /** 旧设备不可用 */
            if (![self isUseOutputExceptBuiltInPort]) {
                [self handleSensorStateChange:notification];
            }
            break;
        default:
            break;
    }
    /** 没有可用的播放设备,发送无可播放设备事件 */
    [self sendEvent:event_old_device_unavailable];
}

- (void)handleSessionInterruption:(NSNotification *)notification {
    
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType)
    {
//        XMNLog(@"begin interruption");
        [_renderer setInterrupted:YES];
        [_renderer stop];
        [self sendEvent:event_interruption_begin];
    } else if (AVAudioSessionInterruptionTypeEnded == interruptionType) {
//        XMNLog(@"end interruption");
        
        AudioSessionInterruptionType interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
        if (interruptionType == kAudioSessionInterruptionType_ShouldResume) {
            [self sendEvent:event_interruption_end
                   userData:(void *)(uintptr_t)interruptionType];
        }
    }
}

/** 是否使用 非系统的输出设备
 *  例如 使用耳机
 *  除了手机听筒,扬声器 意外的其他方式
 **/
- (BOOL)isUseOutputExceptBuiltInPort
{
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    if (outputs.count<=0) {
        return NO;
    }
    
    for (AVAudioSessionPortDescription *port in outputs) {
        //如果不是两个内建里的一个
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]||[port.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            continue;
        }
        return YES;
    }
    return NO;
}

- (void)startProximityMonitering {
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([self isUseOutputExceptBuiltInPort]) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else{
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
//    XMNLog(@"开启距离监听");
}

- (void)stopProximityMonitering {
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
//    XMNLog(@"关闭距离监听");
}

#pragma mark - Setters

- (void)setVolume:(double)volume {
    
    [_renderer setVolume:volume];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    
    NSUInteger milliseconds = (NSUInteger)lrint(currentTime * 1000.0);
    [self sendEvent:event_seek userData:(void *)(uintptr_t)milliseconds];
}

- (void)setCurrentPlayer:(XMNAudioPlayer *)currentPlayer {
    
    if (_currentPlayer != currentPlayer) {
        _currentPlayer = currentPlayer;
        [self sendEvent:event_player_changed];
    }
}

#pragma mark - Getters

- (double)volume {
    
    return [_renderer volume];
}

- (NSTimeInterval)currentTime {
    
    return (NSTimeInterval)((NSUInteger)[[self currentPlayer] timingOffset] + [_renderer currentTime]) / 1000.0;
}

#pragma mark - Class Methods

- (NSUInteger)decoderBufferSize {
    
    AudioStreamBasicDescription format;
    if (self.currentPlayer && self.currentPlayer.decoder) {
        format = [[self.currentPlayer decoder] outputFormat];
    }else {
        format = [XMNAudioDecoder defaultOutputFormat];
    }
    return kXMNAudioPlayerBufferTime * format.mSampleRate * format.mChannelsPerFrame * format.mBitsPerChannel / 8 / 1000;
}

@end
