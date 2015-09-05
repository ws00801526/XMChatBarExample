//
//  XMAVAudioPlayer.h
//  XMChatBarExample
//
//  Created by shscce on 15/8/17.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol XMAVAudioPlayerDelegate <NSObject>

- (void)audioPlayerBeginLoadVoice;
- (void)audioPlayerBeginPlay;
- (void)audioPlayerDidFinishPlay;

@end

@interface XMAVAudioPlayer : NSObject
@property (nonatomic, assign)id <XMAVAudioPlayerDelegate>delegate;
+ (XMAVAudioPlayer *)sharedInstance;

- (void)playSongWithUrl:(NSString *)songUrl;
- (void)playSongWithData:(NSData *)songData;

- (void)stopSound;
@end
