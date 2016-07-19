//
//  XMNAudioPlayitem.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <AudioToolbox/AudioToolbox.h>

@class XMNAudioFilePreprofessor;
@class XMNAudioFileProvider;
@protocol XMNAudioFile;

@interface XMNAudioPlaybackItem : NSObject

+ (instancetype)playbackItemWithFileProvider:(XMNAudioFileProvider *)fileProvider;
- (instancetype)initWithFileProvider:(XMNAudioFileProvider *)fileProvider;

@property (nonatomic, readonly) XMNAudioFileProvider *fileProvider;
@property (nonatomic, readonly) XMNAudioFilePreprofessor *filePreprocessor;
@property (nonatomic, readonly) id <XMNAudioFile> audioFile;

@property (nonatomic, readonly) NSURL *cachedURL;
@property (nonatomic, readonly) NSData *mappedData;

@property (nonatomic, readonly) AudioFileID fileID;
@property (nonatomic, readonly) AudioFileTypeID fileTypeID;
@property (nonatomic, readonly) AudioStreamBasicDescription fileFormat;
@property (nonatomic, readonly) NSUInteger bitRate;
@property (nonatomic, readonly) NSUInteger dataOffset;
@property (nonatomic, readonly) NSUInteger estimatedDuration;

@property (nonatomic, readonly, getter=isOpened) BOOL opened;

/**
 *  打开音频文件,使用AudioFile打开
 *  先尝试使用XMNAudioFile中提供的AudioFileTypeID打开
 *  打开失败则获取AudioFile中的所有fileTypeIDs,循环尝试打开文件
 *  @return 是否打开成功
 */
- (BOOL)open;

/**
 *  关闭已经打开的AudioFile
 */
- (void)close;

@end
