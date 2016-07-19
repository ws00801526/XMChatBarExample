//
//  XMNAudioFile.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>

@interface XMNAudioFilePreprofessor : NSObject

- (NSData *)handleData:(NSData *)data
                offset:(NSUInteger)offset;

@end

/**
 *  AudioFile协议
 */
@protocol XMNAudioFile <NSObject>

@required

- (NSURL *)audioFileURL;

@optional

- (NSString *)audioFileHost;
- (XMNAudioFilePreprofessor *)audioFilePreprocessor;

/** 帮助确定文件类型 */
- (AudioFileTypeID)fileTypeID;

@end