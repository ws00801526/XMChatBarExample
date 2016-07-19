//
//  XMNAudioEncoder.h
//  XMNAudioRecorder
//
//  Created by XMFraker on 16/6/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolBox/AudioToolbox.h>

#if __has_include(<lame/lame.h>)
    #import <lame/lame.h>
    #define kXMNAudioEncoderMP3Enable
#endif

#if __has_include("interf_enc.h")
    #import "interf_enc.h"
    #define kXMNAudioEncoderAMREnable
#endif

/** 录音文件转换方式 */
typedef NS_ENUM(NSUInteger, XMNAudioEncoderType) {
    /** 录音格式为caf */
    XMNAudioEncoderTypeCAF = 0,
    /** 录音格式为amr */
    XMNAudioEncoderTypeAMR,
    /** 录音格式为MP3*/
    XMNAudioEncoderTypeMP3,
    /** 其他的录音文件格式 */
    XMNAudioEncoderTypeOTHER,
};

@class XMNAudioRecorder;
/** 录音文件转码器,将录音好的录音格式转化成对应的录音格式 */
@protocol XMNAudioEncoder <NSObject>

@optional

- (AudioStreamBasicDescription)customAudioFomatForRecorder:(XMNAudioRecorder * _Nonnull)recorder;

@required

- (BOOL)recorder:(XMNAudioRecorder * _Nonnull)recorder
createFileAtPath:(NSString * _Nonnull)filePath;

- (BOOL)recorder:(XMNAudioRecorder * _Nonnull)recorder
   writeFileData:(NSData * _Nonnull)data
   inputQueueRef:(AudioQueueRef _Nonnull)inputQueueRef
  inputTimeStamp:(const AudioTimeStamp * _Nonnull)inputTimeStamp
    inputPackets:(UInt32)inputPackets
inputPacketsDesc:(const AudioStreamPacketDescription * _Nonnull)inputPacketsDesc;

- (BOOL)recorder:(XMNAudioRecorder * _Nonnull)recorder
completedRecordWithError:(NSError * _Nullable)error;

@end

#ifdef kXMNAudioEncoderMP3Enable
@interface XMNAudioRecorderMP3Encoder : NSObject <XMNAudioEncoder>

@end
#endif

#ifdef kXMNAudioEncoderAMREnable
@interface XMNAudioRecorderAMREncoder : NSObject <XMNAudioEncoder>

@end
#endif

@interface XMNAudioRecorderCAFEncoder : NSObject <XMNAudioEncoder>

@end



