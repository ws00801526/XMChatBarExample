//
//  XMNAudioDecoder.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudioTypes.h>

/** 解码器解码结果 */
typedef NS_ENUM(NSUInteger, XMNAudioDecoderStatus) {
    /** 解码成功 */
    XMNAudioDecoderSucceeded = 0,
    /** 解码失败 */
    XMNAudioDecoderFailed,
    /** 解码结束 */
    XMNAudioDecoderEndEncountered,
    /** 正在解码中 */
    XMNAudioDecoderWaiting
};

@class XMNAudioLPCM;
@class XMNAudioPlaybackItem;
@interface XMNAudioDecoder : NSObject
{
    /** amr文件 */
    FILE *_file;
    
    void *_destate;
    
    //帧头标识和帧大小
    unsigned char _stdFrameHeader;
    int _stdFrameSize;
}
@property (nonatomic, readonly) XMNAudioPlaybackItem *playbackItem;
@property (nonatomic, readonly) XMNAudioLPCM *lpcm;

@property (nonatomic, assign, readonly) AudioStreamBasicDescription outputFormat;


+ (AudioStreamBasicDescription)defaultOutputFormat;
+ (AudioStreamBasicDescription)defaultAMROutputFormat;

+ (instancetype)decoderWithPlaybackItem:(XMNAudioPlaybackItem *)playbackItem
                             bufferSize:(NSUInteger)bufferSize;

- (instancetype)initWithPlaybackItem:(XMNAudioPlaybackItem *)playbackItem
                          bufferSize:(NSUInteger)bufferSize;

- (BOOL)setup;
- (void)tearDown;

- (XMNAudioDecoderStatus)decodeOnce;
- (void)seekToTime:(NSUInteger)milliseconds;

@end
