
//  XMNAudioFileProvider.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioFileProvider.h"
#import "XMNHTTPRequest.h"

#include <CommonCrypto/CommonDigest.h>
#include <AudioToolbox/AudioToolbox.h>

#if TARGET_OS_IPHONE
#include <MobileCoreServices/MobileCoreServices.h>
#else /* TARGET_OS_IPHONE */
#include <CoreServices/CoreServices.h>
#endif /* TARGET_OS_IPHONE */

static id <XMNAudioFile> gHintFile = nil;
static XMNAudioFileProvider *gHintProvider = nil;
static BOOL gLastProviderIsFinished = NO;

@interface XMNAudioFileProvider()
{
@protected
    id <XMNAudioFile> _audioFile;
    XMNAudioFileProviderEventBlock _eventBlock;
    NSString *_cachedPath;
    NSURL *_cachedURL;
    NSString *_mimeType;
    NSString *_fileExtension;
    NSString *_sha256;
    NSData *_mappedData;
    NSUInteger _expectedLength;
    NSUInteger _receivedLength;
    BOOL _failed;
}
@end


@interface XMNAudioLocalFileProvider : XMNAudioFileProvider

- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile
                        cachePath:(NSString *)cachePath;
@end

@interface XMNAudioRemoteFileProvider : XMNAudioFileProvider
{
@private
    XMNHTTPRequest *_request;
    NSURL *_audioFileURL;
    NSString *_audioFileHost;
    
    CC_SHA256_CTX *_sha256Ctx;
    
    AudioFileStreamID _audioFileStreamID;
    BOOL _requiresCompleteFile;
    BOOL _readyToProducePackets;
    BOOL _requestCompleted;
}

+ (NSString *)cachedPathForAudioFileURL:(NSURL *)audioFileURL;

@end


#pragma mark - Abstract Class XMNAudioFileProvider

@implementation XMNAudioFileProvider
@synthesize audioFile = _audioFile;
@synthesize eventBlock = _eventBlock;
@synthesize cachedPath = _cachedPath;
@synthesize cachedURL = _cachedURL;
@synthesize mimeType = _mimeType;
@synthesize fileExtension = _fileExtension;
@synthesize sha256 = _sha256;
@synthesize mappedData = _mappedData;
@synthesize expectedLength = _expectedLength;
@synthesize receivedLength = _receivedLength;
@synthesize failed = _failed;

#pragma mark - XMNAudioFileProvider Life Cycle

+ (instancetype)fileProviderWithAudioFile:(id<XMNAudioFile>)audioFile {
    
    /** 如果全局已经生成了provider 则返回 不用再次创建 */
    if ((audioFile == gHintFile ||
         [audioFile isEqual:gHintFile]) &&
        gHintProvider != nil) {
        
        XMNAudioFileProvider *provider = gHintProvider;
        gHintFile = nil;
        gHintProvider = nil;
        gLastProviderIsFinished = [provider isFinished];
        return provider;
    }
    
    gHintFile = nil;
    gHintProvider = nil;
    gLastProviderIsFinished = NO;
    
    return [self _fileProviderWithAudioFile:audioFile];
}

+ (instancetype)_fileProviderWithAudioFile:(id <XMNAudioFile>)audioFile
{
    if (audioFile == nil) {
        return nil;
    }
    
    NSURL *audioFileURL = [audioFile audioFileURL];
    if (audioFileURL == nil) {
        return nil;
    }
    
    if ([audioFileURL isFileURL]) {
        /** 文件是一个本地文件 */
        return [[XMNAudioLocalFileProvider alloc] initWithAudioFile:audioFile];
    }
#if TARGET_OS_IPHONE
    else if ([[audioFileURL scheme] isEqualToString:@"ipod-library"]) {
        //        return [[_DOUAudioMediaLibraryFileProvider alloc] _initWithAudioFile:audioFile];
    }
#endif /* TARGET_OS_IPHONE */
    else {
        
        NSString *cachePath = [XMNAudioRemoteFileProvider cachedPathForAudioFileURL:[audioFile audioFileURL]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            
            return [[XMNAudioLocalFileProvider alloc] initWithAudioFile:audioFile
                                                              cachePath:cachePath];
        }
        
        return [[XMNAudioRemoteFileProvider alloc] initWithAudioFile:audioFile];
    }
    return nil;
}

+ (void)setHintWithAudioFile:(id<XMNAudioFile>)audioFile {
    
    if (audioFile == gHintFile ||
        [audioFile isEqual:gHintFile]) {
        return;
    }
    
    if (audioFile == nil) {
        return;
    }
    
    NSURL *audioFileURL = [audioFile audioFileURL];
    if (audioFileURL == nil ||
#if TARGET_OS_IPHONE
        [[audioFileURL scheme] isEqualToString:@"ipod-library"] ||
#endif /* TARGET_OS_IPHONE */
        [audioFileURL isFileURL]) {
        return;
    }
    
    gHintFile = audioFile;
    
    if (gLastProviderIsFinished) {
        gHintProvider = [self _fileProviderWithAudioFile:gHintFile];
    }
}

- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile {
    
    if (self = [super init]) {
        
        _audioFile = audioFile;
    }
    return self;
}

#pragma mark - XMNAudioFileProvider Getters

- (NSUInteger)downloadSpeed {
    
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (BOOL)isReady {
    
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isFinished {
    
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

@end

#pragma mark - Implementation of XMNAudioLocalFileProvider 

@implementation XMNAudioLocalFileProvider


#pragma mark - XMNAudioLocalFileProvider Life Cycle
    
- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile {
    
    return [[[self class] alloc] initWithAudioFile:audioFile
                                         cachePath:[[audioFile audioFileURL] path]];
}

- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile
                        cachePath:(NSString *)cachePath {
    
    if (self = [super initWithAudioFile:audioFile]) {
        
        _cachedURL = [audioFile audioFileURL];
        _cachedPath = cachePath;
        
        BOOL isDirectory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cachedPath
                                                  isDirectory:&isDirectory] ||
            isDirectory) {
            return nil;
        }
        
        _mappedData = [NSData dataWithContentsOfFile:_cachedPath];
        _expectedLength = [_mappedData length];
        _receivedLength = [_mappedData length];
    }
    return self;
}



#pragma mark - XMNAudioLocalFileProvider Getters

- (NSString *)mimeType {
    
    if (_mimeType == nil &&
        [self fileExtension] != nil) {
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self fileExtension], NULL);
        if (uti != NULL) {
            _mimeType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType));
            CFRelease(uti);
        }
    }
    return _mimeType;
}

- (NSString *)fileExtension {
    
    if (_fileExtension == nil) {
        _fileExtension = [[[self audioFile] audioFileURL] pathExtension];
    }
    return _fileExtension;
}

- (NSString *)sha256 {
    
    if (_sha256 == nil &&
        [self mappedData] != nil) {
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256([[self mappedData] bytes], (CC_LONG)[[self mappedData] length], hash);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
            [result appendFormat:@"%02x", hash[i]];
        }
        _sha256 = [result copy];
    }
    return _sha256;
}

- (NSUInteger)downloadSpeed {
    
    return _receivedLength;
}

- (BOOL)isReady {
    
    /** 本地文件 可以直接播放 */
    return YES;
}

- (BOOL)isFinished {
    
    /** 本地文件 可以直接播放 */
    return YES;
}

@end


#pragma mark - Implementation of XMNAudioRemoteFileProvider

@implementation XMNAudioRemoteFileProvider
@synthesize finished = _requestCompleted;

- (instancetype)initWithAudioFile:(id <XMNAudioFile>)audioFile {
    
    if (self = [super initWithAudioFile:audioFile]) {
        
        _audioFileURL = [audioFile audioFileURL];
        if ([audioFile respondsToSelector:@selector(audioFileHost)]) {
            _audioFileHost = [audioFile audioFileHost];
        }
        _sha256Ctx = (CC_SHA256_CTX *)malloc(sizeof(CC_SHA256_CTX));
        CC_SHA256_Init(_sha256Ctx);
        
        AudioFileTypeID fileTypeID = 0;
        if ([self.audioFile respondsToSelector:@selector(fileTypeID)]) {
            fileTypeID = [self.audioFile fileTypeID];
        }
        [self openAudioFileStreamWithFileTypeID:fileTypeID];
        [self createRequest];
        [_request start];

    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    
    @synchronized (_request) {
        [_request setCompletedBlock:nil];
        [_request setDidReceiveDataBlock:nil];
        [_request setDidReceiveResponseBlock:nil];
        [_request setProgressBlock:nil];
        [_request cancel];
    }
    
    if (_sha256Ctx != NULL) {
        free(_sha256Ctx);
    }
    
    [self closeAudioFileStream];
    
//    [[NSFileManager defaultManager] removeItemAtPath:_cachedPath error:NULL];
}


#pragma mark - XMNAudioRemoteFileProvider Methods

#pragma mark - Request Methods

- (void)createRequest {
    
    _request = [[XMNHTTPRequest alloc] initWithURL:_audioFileURL];
    if (_audioFileHost != nil) {
        [_request setHost:_audioFileHost];
    }

    __weak typeof(*&self) wSelf = self;
    [_request setCompletedBlock:^(NSError *error){
        
        __strong typeof(*&wSelf) self = wSelf;
        [self handleRequestCompletedWithError:error];
    }];
    
    [_request setProgressBlock:^(double downloadProgress) {

        __strong typeof(*&wSelf) self = wSelf;
        [self handleRequestProgressChanged:downloadProgress];
    }];
    
    [_request setDidReceiveResponseBlock:^{
        
        __strong typeof(*&wSelf) self = wSelf;
        [self handleRequestReceivedResponse];
    }];
    
    [_request setDidReceiveDataBlock:^(NSData *data) {
        
        __strong typeof(*&wSelf) self = wSelf;
        [self handleRequestReceivedData:data];
    }];
}

- (void)callEventBlock {
    
    _eventBlock ? _eventBlock() : nil;
}

- (void)handleRequestCompletedWithError:(NSError *)error {
    
    if (error || [_request isFailed] ||
        !([_request statusCode] >= 200 && [_request statusCode] < 300)) {
        _failed = YES;
    } else {
        _requestCompleted = YES;
        [_mappedData writeToFile:_cachedPath atomically:YES];
    }
    
    if (!_failed &&
        _sha256Ctx != NULL) {
        unsigned char hash[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256_Final(hash, _sha256Ctx);
        
        NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
        for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
            [result appendFormat:@"%02x", hash[i]];
        }
        
        _sha256 = [result copy];
    }
    
    if (gHintFile != nil &&
        gHintProvider == nil) {
        gHintProvider = [[[self class] alloc] initWithAudioFile:gHintFile];
    }
    [self callEventBlock];
}

- (void)handleRequestReceivedResponse {
    
    _expectedLength = [_request responseContentLength];
    
    _cachedPath = [[self class] cachedPathForAudioFileURL:_audioFileURL];
    _cachedURL = [NSURL fileURLWithPath:_cachedPath];
    
    [[NSFileManager defaultManager] createFileAtPath:_cachedPath contents:nil attributes:nil];
#if TARGET_OS_IPHONE
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionNone}
                                     ofItemAtPath:_cachedPath
                                            error:NULL];
#endif /* TARGET_OS_IPHONE */
    [[NSFileHandle fileHandleForWritingAtPath:_cachedPath] truncateFileAtOffset:_expectedLength];
    
    _mimeType = [[_request responseHeaders] objectForKey:@"Content-Type"];
    
    _mappedData = [NSMutableData dataWithLength:_expectedLength];
}

- (void)handleRequestReceivedData:(NSData *)data {
    
    if (_mappedData == nil) {
        return;
    }
    
    NSUInteger availableSpace = _expectedLength - _receivedLength;
    NSUInteger bytesToWrite = MIN(availableSpace, [data length]);
    
    [(NSMutableData *)_mappedData replaceBytesInRange:NSMakeRange(_receivedLength, [data length]) withBytes:[data bytes]];
    _receivedLength += bytesToWrite;
    
    if (_sha256Ctx != NULL) {
        CC_SHA256_Update(_sha256Ctx, [data bytes], (CC_LONG)[data length]);
    }
    
    if (!_readyToProducePackets && !_failed && !_requiresCompleteFile) {
        OSStatus status = kAudioFileStreamError_UnsupportedFileType;
        
        if (_audioFileStreamID != NULL) {
            status = AudioFileStreamParseBytes(_audioFileStreamID,
                                               (UInt32)[data length],
                                               [data bytes],
                                               0);
        }
        
        if (status != noErr && status != kAudioFileStreamError_NotOptimized) {
            NSArray *fallbackTypeIDs = [self fetchTypeIDs];
            for (NSNumber *typeIDNumber in fallbackTypeIDs) {
                AudioFileTypeID typeID = (AudioFileTypeID)[typeIDNumber unsignedLongValue];
                [self closeAudioFileStream];
                [self openAudioFileStreamWithFileTypeID:typeID];
                
                if (_audioFileStreamID != NULL) {
                    status = AudioFileStreamParseBytes(_audioFileStreamID,
                                                       (UInt32)_receivedLength,
                                                       [_mappedData bytes],
                                                       0);
                    
                    if (status == noErr || status == kAudioFileStreamError_NotOptimized) {
                        break;
                    }
                }
            }
            
            if (status != noErr && status != kAudioFileStreamError_NotOptimized) {
                _failed = YES;
            }
        }
        
        if (status == kAudioFileStreamError_NotOptimized) {
            [self closeAudioFileStream];
            _requiresCompleteFile = YES;
        }
    }
}

- (void)handleRequestProgressChanged:(double)progress {
    
    [self callEventBlock];
}

- (NSArray *)fetchTypeIDs {
    
    NSMutableArray *fallbackTypeIDs = [NSMutableArray array];
    NSMutableSet *fallbackTypeIDSet = [NSMutableSet set];
    
    struct {
        CFStringRef specifier;
        AudioFilePropertyID propertyID;
    } properties[] = {
        { (__bridge CFStringRef)[self mimeType], kAudioFileGlobalInfo_TypesForMIMEType },
        { (__bridge CFStringRef)[self fileExtension], kAudioFileGlobalInfo_TypesForExtension }
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

#pragma mark - Audio File Stream Methods

- (void)openAudioFileStreamWithFileTypeID:(AudioFileTypeID)fileTypeID {
    
    OSStatus status = AudioFileStreamOpen((__bridge void *)self,
                                          audio_file_stream_property_listener_proc,
                                          audio_file_stream_packets_proc,
                                          fileTypeID,
                                          &_audioFileStreamID);
    
    if (status != noErr) {
        _audioFileStreamID = NULL;
    }
}

- (void)closeAudioFileStream {
    
    if (_audioFileStreamID != NULL) {
        AudioFileStreamClose(_audioFileStreamID);
        _audioFileStreamID = NULL;
    }
}

- (void)handleAudioFileStreamProperty:(AudioFileStreamPropertyID)propertyID {
    
    if (propertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
        _readyToProducePackets = YES;
    }
}

- (void)handleAudioFileStreamPackets:(const void *)packets
                       numberOfBytes:(UInt32)numberOfBytes
                     numberOfPackets:(UInt32)numberOfPackets
                  packetDescriptions:(AudioStreamPacketDescription *)packetDescriptioins {
    
}

static void audio_file_stream_property_listener_proc(void *inClientData,
                                                     AudioFileStreamID inAudioFileStream,
                                                     AudioFileStreamPropertyID inPropertyID,
                                                     UInt32 *ioFlags)
{
    __unsafe_unretained XMNAudioRemoteFileProvider *fileProvider = (__bridge XMNAudioRemoteFileProvider *)inClientData;
    [fileProvider handleAudioFileStreamProperty:inPropertyID];
}

static void audio_file_stream_packets_proc(void *inClientData,
                                           UInt32 inNumberBytes,
                                           UInt32 inNumberPackets,
                                           const void *inInputData,
                                           AudioStreamPacketDescription	*inPacketDescriptions)
{
    __unsafe_unretained XMNAudioRemoteFileProvider *fileProvider = (__bridge XMNAudioRemoteFileProvider *)inClientData;
    [fileProvider handleAudioFileStreamPackets:inInputData
                                 numberOfBytes:inNumberBytes
                               numberOfPackets:inNumberPackets
                            packetDescriptions:inPacketDescriptions];
    
}

#pragma mark - Getters


- (NSString *)fileExtension {
    
    if (_fileExtension == nil) {
        _fileExtension = [[[[self audioFile] audioFileURL] path] pathExtension];
    }
    return _fileExtension;
}

- (NSUInteger)downloadSpeed {
    
    return [_request downloadSpeed];
}

- (BOOL)isReady {
    
    if (!_requiresCompleteFile) {
        return _readyToProducePackets;
    }
    return _requestCompleted;
}

#pragma mark - Class Methods

+ (NSString *)cachedPathForAudioFileURL:(NSURL *)audioFileURL {
    
    NSString *filename = [NSString stringWithFormat:@"XMNAudioPlayer-%@.tmp", [self sha256ForAudioFileURL:audioFileURL]];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
}

+ (NSString *)sha256ForAudioFileURL:(NSURL *)audioFileURL {
    
    NSString *string = [audioFileURL absoluteString];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], hash);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (size_t i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        [result appendFormat:@"%02x", hash[i]];
    }
    return result;
}


@end
