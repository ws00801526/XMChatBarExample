//
//  XMNAudioFileProvider.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMNAudioFile.h"

typedef void (^XMNAudioFileProviderEventBlock)(void);

@interface XMNAudioFileProvider : NSObject

+ (instancetype)fileProviderWithAudioFile:(id <XMNAudioFile>)audioFile;
+ (void)setHintWithAudioFile:(id <XMNAudioFile>)audioFile;

@property (nonatomic, readonly) id <XMNAudioFile> audioFile;
@property (nonatomic, copy) XMNAudioFileProviderEventBlock eventBlock;

/** 缓存路径,文件路径 */
@property (nonatomic, readonly) NSString *cachedPath;
/** 缓存路径,文件路径 */
@property (nonatomic, readonly) NSURL    *cachedURL;

/** 文件的mimetype, */
@property (nonatomic, readonly) NSString *mimeType;
/** 文件拓展名 */
@property (nonatomic, readonly) NSString *fileExtension;
/** 文件的sha256 */
@property (nonatomic, readonly) NSString *sha256;

@property (nonatomic, readonly) NSData *mappedData;

/** 已经播放的data长度 */
@property (nonatomic, readonly) NSUInteger expectedLength;
/** 已经接受的文件长度 */
@property (nonatomic, readonly) NSUInteger receivedLength;
/** 文件下载速度 */
@property (nonatomic, readonly) NSUInteger downloadSpeed;

/** 是否成功 */
@property (nonatomic, readonly, getter=isFailed) BOOL failed;
/** 是否已经准备好播放 */
@property (nonatomic, readonly, getter=isReady) BOOL ready;
/** 是否文件是否加载完毕 */
@property (nonatomic, readonly, getter=isFinished) BOOL finished;

@end

