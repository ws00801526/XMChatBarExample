//
//  XMNAudioRunLoop.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMNAudioPlayer;
@interface XMNAudioRunLoop : NSObject

@property (nonatomic, strong) XMNAudioPlayer *currentPlayer;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) double volume;

@property (nonatomic, copy) NSArray *analyzers;


+ (instancetype)sharedLoop;

- (void)play;
- (void)pause;
- (void)stop;

@end
