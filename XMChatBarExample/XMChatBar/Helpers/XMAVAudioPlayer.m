//
//  XMAVAudioPlayer.m
//  XMChatBarExample
//
//  Created by shscce on 15/8/17.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMAVAudioPlayer.h"

@interface XMAVAudioPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic ,strong)  AVAudioPlayer *player; /**< 音频播放 */

@end

@implementation XMAVAudioPlayer

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static XMAVAudioPlayer *shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


#pragma mark - Public Methods

-(void)playSongWithUrl:(NSString *)songUrl
{
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        [self.delegate audioPlayerBeginLoadVoice];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playSoundWithData:data];
        });
    });
    
}

-(void)playSongWithData:(NSData *)songData
{
    [self setupPlaySound];
    [self playSoundWithData:songData];
}

-(void)playSoundWithData:(NSData *)soundData{
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    _player.delegate = self;
    [_player play];
    [self.delegate audioPlayerBeginPlay];
 
}

-(void)setupPlaySound{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

    [self.delegate audioPlayerDidFinishPlay];
    [self stopSound];
    
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
        _player = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [self.delegate audioPlayerDidFinishPlay];
}

@end
