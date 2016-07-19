//
//  XMNAudioPlayitem.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioPlaybackItem.h"
#import "XMNAudioFileProvider.h"

@interface XMNAudioPlaybackItem ()
{
@private
    XMNAudioFileProvider *_fileProvider;
    AudioFileID _fileID;
    AudioStreamBasicDescription _fileFormat;
    NSUInteger _bitRate;
    NSUInteger _dataOffset;
    NSUInteger _estimatedDuration;
    XMNAudioFilePreprofessor *_filePreprofessor;
}
@end

#pragma mark - AudioFileOpen 回调

static OSStatus audio_file_read(void *inClientData,
                                SInt64 inPosition,
                                UInt32 requestCount,
                                void *buffer,
                                UInt32 *actualCount)
{
    __unsafe_unretained XMNAudioPlaybackItem *item = (__bridge XMNAudioPlaybackItem *)inClientData;
    if (inPosition + requestCount > [[item mappedData] length]) {
        if (inPosition >= [[item mappedData] length]) {
            *actualCount = 0;
        }
        else {
            *actualCount = (UInt32)((SInt64)[[item mappedData] length] - inPosition);
        }
    }
    else {
        *actualCount = requestCount;
    }
    
    if (*actualCount == 0) {
        return noErr;
    }
    
    if ([item filePreprocessor] == nil) {
        memcpy(buffer, (uint8_t *)[[item mappedData] bytes] + inPosition, *actualCount);
    } else {
        NSData *input = [NSData dataWithBytesNoCopy:(uint8_t *)[[item mappedData] bytes] + inPosition
                                             length:*actualCount
                                       freeWhenDone:NO];
        NSData *output = [[item filePreprocessor] handleData:input offset:(NSUInteger)inPosition];
        memcpy(buffer, [output bytes], [output length]);
    }
    
    return noErr;
}

static SInt64 audio_file_get_size(void *inClientData) {
    
    __unsafe_unretained XMNAudioPlaybackItem *item = (__bridge XMNAudioPlaybackItem *)inClientData;
    return (SInt64)[[item mappedData] length];
}

@implementation XMNAudioPlaybackItem
@synthesize fileProvider = _fileProvider;
@synthesize fileID = _fileID;
@synthesize fileFormat = _fileFormat;
@synthesize bitRate = _bitRate;
@synthesize dataOffset = _dataOffset;
@synthesize estimatedDuration = _estimatedDuration;
@synthesize filePreprocessor = _filePreprofessor;

#pragma mark - Life Cycle

+ (instancetype)playbackItemWithFileProvider:(XMNAudioFileProvider *)fileProvider {
    
    return [[[self class] alloc] initWithFileProvider:fileProvider];
}

- (instancetype)initWithFileProvider:(XMNAudioFileProvider *)fileProvider {
    
    if (self = [super init]) {
        
        _fileProvider = fileProvider;
        
        if ([fileProvider.audioFile respondsToSelector:@selector(audioFilePreprocessor)]) {
            _filePreprofessor = [fileProvider.audioFile audioFilePreprocessor];
        }
    }
    return self;
}

- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self close];
}


#pragma mark - Methods

/// ========================================
/// @name   Public Methods
/// ========================================

- (BOOL)open {
    
    if ([self isOpened]) {
        return YES;
    }
    
    AudioFileTypeID fileTypeID = 0;
    if ([self.audioFile respondsToSelector:@selector(fileTypeID)]) {
        fileTypeID = [self.audioFile fileTypeID];
    }
    
    if (![self openWithFileTypeHint:fileTypeID] && ![self openWithFallbacks]) {
        _fileID = NULL;
        return NO;
    }
    
    /** 获取音频文件相关信息 AudioStreamBasicDescription bitRate SampleRate,duration等 */
    if (![self fetchFileFormat] || ![self fetchFileProperties]) {
        AudioFileClose(_fileID);
        _fileID = NULL;
        return NO;
    }
    return YES;
}


- (void)close {
    
    if (![self isOpened]) {
        return;
    }
    AudioFileClose(_fileID);
    _fileID = NULL;
}

/// ========================================
/// @name   Private Methods
/// ========================================

/**
 *  指定fileTypeHint提示 打开音频文件
 *
 *  @param fileTypeHint 参考AudioFileTypeID 帮助AudioFile解码音频
 *
 *  @return 是否成功打开音频文件
 */
- (BOOL)openWithFileTypeHint:(AudioFileTypeID)fileTypeHint
{
    OSStatus status;
    status = AudioFileOpenWithCallbacks((__bridge void *)self,
                                        audio_file_read,
                                        NULL,
                                        audio_file_get_size,
                                        NULL,
                                        fileTypeHint,
                                        &_fileID);
    
    return status == noErr;
}

/**
 *  获取音频文件的fileTypeIDs 再尝试打开音频文件
 *
 *  @return 是否打开成功
 */
- (BOOL)openWithFallbacks {
    
    NSArray *fallbackTypeIDs = [self fetchFileTypeIDs];
    for (NSNumber *typeIDNumber in fallbackTypeIDs) {
        AudioFileTypeID typeID = (AudioFileTypeID)[typeIDNumber unsignedLongValue];
        if ([self openWithFileTypeHint:typeID]) {
            return YES;
        }
    }
    return NO;
}

/**
 *  获取音频文件的fileTypeIDs
 *
 *  @return 获取的fileTypeIDs数组
 */
- (NSArray *)fetchFileTypeIDs {
    
    NSMutableArray *fallbackTypeIDs = [NSMutableArray array];
    NSMutableSet *fallbackTypeIDSet = [NSMutableSet set];
    
    struct {
        CFStringRef specifier;
        AudioFilePropertyID propertyID;
    } properties[] = {
        { (__bridge CFStringRef)[_fileProvider mimeType], kAudioFileGlobalInfo_TypesForMIMEType },
        { (__bridge CFStringRef)[_fileProvider fileExtension], kAudioFileGlobalInfo_TypesForExtension }
    };
    
    const size_t numberOfProperties = sizeof(properties) / sizeof(properties[0]);
    
    for (size_t i = 0; i < numberOfProperties; ++i) {
        if (properties[i].specifier == NULL) {
            continue;
        }
        
        UInt32 outSize = 0;
        OSStatus status;
        
        status = AudioFileGetGlobalInfoSize(properties[i].propertyID,
                                            sizeof(properties[i].specifier),
                                            &properties[i].specifier,
                                            &outSize);
        if (status != noErr) {
            continue;
        }
        
        size_t count = outSize / sizeof(AudioFileTypeID);
        AudioFileTypeID *buffer = (AudioFileTypeID *)malloc(outSize);
        if (buffer == NULL) {
            continue;
        }
        
        status = AudioFileGetGlobalInfo(properties[i].propertyID,
                                        sizeof(properties[i].specifier),
                                        &properties[i].specifier,
                                        &outSize,
                                        buffer);
        if (status != noErr) {
            free(buffer);
            continue;
        }
        
        for (size_t j = 0; j < count; ++j) {
            NSNumber *tid = [NSNumber numberWithUnsignedLong:buffer[j]];
            if ([fallbackTypeIDSet containsObject:tid]) {
                continue;
            }
            
            [fallbackTypeIDs addObject:tid];
            [fallbackTypeIDSet addObject:tid];
        }
        
        free(buffer);
    }
    
    return fallbackTypeIDs;
}

- (BOOL)fetchFileFormat {
 
    UInt32 size;
    OSStatus status;
    
    status = AudioFileGetPropertyInfo(_fileID, kAudioFilePropertyFormatList, &size, NULL);
    if (status != noErr) {
        return NO;
    }
    
    UInt32 numFormats = size / sizeof(AudioFormatListItem);
    AudioFormatListItem *formatList = (AudioFormatListItem *)malloc(size);
    
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyFormatList, &size, formatList);
    if (status != noErr) {
        free(formatList);
        return NO;
    }
    
    if (numFormats == 1) {
        _fileFormat = formatList[0].mASBD;
    }
    else {
        status = AudioFormatGetPropertyInfo(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size);
        if (status != noErr) {
            free(formatList);
            return NO;
        }
        
        UInt32 numDecoders = size / sizeof(OSType);
        OSType *decoderIDS = (OSType *)malloc(size);
        
        status = AudioFormatGetProperty(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size, decoderIDS);
        if (status != noErr) {
            free(formatList);
            free(decoderIDS);
            return NO;
        }
        
        UInt32 i;
        for (i = 0; i < numFormats; ++i) {
            OSType decoderID = formatList[i].mASBD.mFormatID;
            
            BOOL found = NO;
            for (UInt32 j = 0; j < numDecoders; ++j) {
                if (decoderID == decoderIDS[j]) {
                    found = YES;
                    break;
                }
            }
            
            if (found) {
                break;
            }
        }
        
        free(decoderIDS);
        
        if (i >= numFormats) {
            free(formatList);
            return NO;
        }
        
        _fileFormat = formatList[i].mASBD;
    }
    
    free(formatList);
    return YES;
}

- (BOOL)fetchFileProperties {
    
    UInt32 size;
    OSStatus status;
    
    UInt32 bitRate = 0;
    size = sizeof(bitRate);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyBitRate, &size, &bitRate);
    if (status != noErr) {
        return NO;
    }
    _bitRate = bitRate;
    
    SInt64 dataOffset = 0;
    size = sizeof(dataOffset);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyDataOffset, &size, &dataOffset);
    if (status != noErr) {
        return NO;
    }
    _dataOffset = (NSUInteger)dataOffset;
    
    Float64 estimatedDuration = 0.0;
    size = sizeof(estimatedDuration);
    status = AudioFileGetProperty(_fileID, kAudioFilePropertyEstimatedDuration, &size, &estimatedDuration);
    if (status != noErr) {
        return NO;
    }
    _estimatedDuration = estimatedDuration * 1000.0;
    
    return YES;
}

#pragma mark - Getters

- (XMNAudioFilePreprofessor *)filePreprocessor {
    
    if (![self.audioFile respondsToSelector:@selector(audioFilePreprocessor)]) {
        return nil;
    }
    return [self.audioFile audioFilePreprocessor];
}

- (id <XMNAudioFile>)audioFile {
    
    return [_fileProvider audioFile];
}

- (NSURL *)cachedURL {
    
    return [_fileProvider cachedURL];
}

- (NSData *)mappedData {
    
    return [_fileProvider mappedData];
}

- (BOOL)isOpened {
    
    return _fileID != NULL;
}

- (AudioFileTypeID)fileTypeID {
    
    AudioFileTypeID fileTypeID = 0;
    if ([self.audioFile respondsToSelector:@selector(fileTypeID)]) {
        fileTypeID = [self.audioFile fileTypeID];
    }
    return fileTypeID;
}

@end
