//
//  XMNAudioRender.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolBox/AudioToolBox.h>

@interface XMNAudioRender : NSObject

@property (nonatomic, readonly) NSUInteger currentTime;
@property (nonatomic, readonly, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isInterrupted) BOOL interrupted;
@property (nonatomic, assign) double volume;

@property (nonatomic, copy) NSArray *analyzers;


+ (instancetype)rendererWithBufferTime:(NSUInteger)bufferTime;
- (instancetype)initWithBufferTime:(NSUInteger)bufferTime;

- (BOOL)setupWithAudioStreamDescription:(AudioStreamBasicDescription)description;

- (void)tearDown;

- (void)renderBytes:(const void *)bytes length:(NSUInteger)length;
- (void)stop;
- (void)flush;
- (void)flushShouldResetTiming:(BOOL)shouldResetTiming;

@end
