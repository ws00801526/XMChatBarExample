//
//  XMNAudioDecoder.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioDecoder.h"
#import "XMNAudioLPCM.h"
#import "XMNAudioFileProvider.h"
#import "XMNAudioPlaybackItem.h"

#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <pthread.h>

#import "XMNAudioDecoder+XMNAMR.h"

/** 声明解码的文件IO结构 */
typedef struct {
    
    /** fileID */
    AudioFileID afid;
    /** packet 位置 */
    SInt64 pos;
    /** 缓冲区 */
    void *buffer;
    /** 缓冲区大小 */
    UInt32 bufferSize;
    /** 基础format */
    AudioStreamBasicDescription format;
    /** 帧描述 */
    AudioStreamPacketDescription *pktDescs;
    
    /// ========================================
    /// @name   输入IO使用的变量
    /// ========================================
    /** 每帧文件大小 */
    UInt32 srcSizePerPacket;
    UInt32 numPacketsPerRead;
    
    /// ========================================
    /// @name   输出IO使用的变量
    /// ========================================
    UInt32 numOutputPackets;

} AudioFileIO;

/** 声明解码的结构体 */
typedef struct {

    AudioStreamBasicDescription inputFormat;
    AudioStreamBasicDescription outputFormat;
    
    AudioFileIO inputFile;
    AudioFileIO outputFile;
    SInt64 decodeValidFrames;
    pthread_mutex_t mutex;
    
} XMNAudioDecodingContext;



@interface XMNAudioDecoder ()
{
@private
    XMNAudioPlaybackItem *_playbackItem;
    XMNAudioLPCM *_lpcm;
    
    AudioStreamBasicDescription _outputFormat;
    AudioConverterRef _audioConverter;
    
    NSUInteger _bufferSize;
    XMNAudioDecodingContext _decodingContext;
    BOOL _decodingContextInitialized;
}
@end

static OSStatus decoder_data_proc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{

    AudioFileIO *afio = (AudioFileIO *)inUserData;
    
    if (*ioNumberDataPackets > afio->numPacketsPerRead) {
        *ioNumberDataPackets = afio->numPacketsPerRead;
    }
    
    /** 使用AudioFileReadPacketData读取数据时,需要传入需要读取的数据 否则返回-50错误*/
    UInt32 inOutNumBytes = *ioNumberDataPackets * afio->srcSizePerPacket;
    OSStatus status = noErr;

    
    /** 重新生产AudioStreamPacketDescription */
    UInt32 descSize = sizeof(AudioStreamPacketDescription) * *ioNumberDataPackets;
    AudioStreamPacketDescription *outPacketDescriptions = NULL;
    if (afio->format.mFormatID != kAudioFormatLinearPCM) {
        outPacketDescriptions = (AudioStreamPacketDescription *)malloc(descSize);
        status = AudioFileReadPacketData(afio->afid, false, &inOutNumBytes, outPacketDescriptions, afio->pos, ioNumberDataPackets, afio->buffer);
    } else {
        status = AudioFileReadPacketData(afio->afid, false, &inOutNumBytes, outPacketDescriptions, afio->pos, ioNumberDataPackets, afio->buffer);
    }
    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored"-Wdeprecated-declarations"
//    NSLog(@"使用已经declarations的方法:AudioFileReadPackets读取数据");
//    /** 使用AudioFileReadPackets 不需要计算inOutNumBytes, 只作为输出参数,告知读取了多少bytes数据*/
//    inOutNumBytes = 0;
//    status = AudioFileReadPackets(afio->afid, FALSE, &inOutNumBytes, afio->pktDescs, afio->pos, ioNumberDataPackets, afio->buffer);
//#pragma clang diagnostic pop
//    if (status != noErr) {
//        return status;
//    }
    
    afio->pos += *ioNumberDataPackets;
    
    ioData->mBuffers[0].mData = afio->buffer;
    ioData->mBuffers[0].mDataByteSize = inOutNumBytes;
    ioData->mBuffers[0].mNumberChannels = afio->format.mChannelsPerFrame;
    
    if (outDataPacketDescription != NULL) {
        if (outPacketDescriptions!=NULL) {
            *outDataPacketDescription = outPacketDescriptions;
            free(outPacketDescriptions);
        }else {
            *outDataPacketDescription = afio->pktDescs;
        }
    }
    
    return status;
}

@implementation XMNAudioDecoder
@synthesize outputFormat = _outputFormat;
@synthesize playbackItem = _playbackItem;
@synthesize lpcm = _lpcm;

#pragma mark - Life Cycle

+ (instancetype)decoderWithPlaybackItem:(XMNAudioPlaybackItem *)playbackItem
                             bufferSize:(NSUInteger)bufferSize
{
    return [[[self class] alloc] initWithPlaybackItem:playbackItem
                                           bufferSize:bufferSize];
}

- (instancetype)initWithPlaybackItem:(XMNAudioPlaybackItem *)playbackItem
                          bufferSize:(NSUInteger)bufferSize {
    
    if (self = [super init]) {
        
        _playbackItem = playbackItem;
        _bufferSize = bufferSize;
        _lpcm = [[XMNAudioLPCM alloc] init];
        
        
        AudioFileTypeID fileTypeID = 0;
        if ([self.playbackItem.audioFile respondsToSelector:@selector(fileTypeID)]) {
            fileTypeID = [self.playbackItem.audioFile fileTypeID];
        }
        if (fileTypeID == kAudioFileAMRType) {
            _outputFormat = [[self class] defaultAMROutputFormat];
        }else {
            _outputFormat = [[self class] defaultOutputFormat];
        }
        if (![self setupAudioConverter]) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    
    if (_decodingContextInitialized) {
        [self tearDown];
    }
    if (_audioConverter != NULL) {
        AudioConverterDispose(_audioConverter);
    }
}

#pragma mark - Methods

- (BOOL)setup {
 
    if (_decodingContextInitialized) {
        return YES;
    }
    
    if (self.playbackItem.fileTypeID == kAudioFileAMRType) {
        return YES;
    }
    
    AudioFileID inputFile = [_playbackItem fileID];
    if (inputFile == NULL) {
        return NO;
    }
    
    _decodingContext.inputFormat = [_playbackItem fileFormat];
    _decodingContext.outputFormat = _outputFormat;
    [self fillMagicCookieForFileID:inputFile];
    
    UInt32 size;
    OSStatus status;
    
    size = sizeof(_decodingContext.inputFormat);
    status = AudioConverterGetProperty(_audioConverter, kAudioConverterCurrentInputStreamDescription, &size, &_decodingContext.inputFormat);
    if (status != noErr) {
        return NO;
    }
    
    size = sizeof(_decodingContext.outputFormat);
    status = AudioConverterGetProperty(_audioConverter, kAudioConverterCurrentOutputStreamDescription, &size, &_decodingContext.outputFormat);
    if (status != noErr) {
        return NO;
    }
    
    AudioStreamBasicDescription baseFormat;
    UInt32 propertySize = sizeof(baseFormat);
    AudioFileGetProperty(inputFile, kAudioFilePropertyDataFormat, &propertySize, &baseFormat);
    
    double actualToBaseSampleRateRatio = 1.0;
    if (_decodingContext.inputFormat.mSampleRate != baseFormat.mSampleRate &&
        _decodingContext.inputFormat.mSampleRate != 0.0 &&
        baseFormat.mSampleRate != 0.0) {
        actualToBaseSampleRateRatio = _decodingContext.inputFormat.mSampleRate / baseFormat.mSampleRate;
    }
    
    double srcRatio = 1.0;
    if (_decodingContext.outputFormat.mSampleRate != 0.0 &&
        _decodingContext.inputFormat.mSampleRate != 0.0) {
        srcRatio = _decodingContext.outputFormat.mSampleRate / _decodingContext.inputFormat.mSampleRate;
    }
    
    _decodingContext.decodeValidFrames = 0;
    AudioFilePacketTableInfo srcPti;
    if (_decodingContext.inputFormat.mBitsPerChannel == 0) {
        size = sizeof(srcPti);
        status = AudioFileGetProperty(inputFile, kAudioFilePropertyPacketTableInfo, &size, &srcPti);
        if (status == noErr) {
            _decodingContext.decodeValidFrames = (SInt64)(actualToBaseSampleRateRatio * srcRatio * srcPti.mNumberValidFrames + 0.5);
            
            AudioConverterPrimeInfo primeInfo;
            primeInfo.leadingFrames = (UInt32)(srcPti.mPrimingFrames * actualToBaseSampleRateRatio + 0.5);
            primeInfo.trailingFrames = 0;
            
            status = AudioConverterSetProperty(_audioConverter, kAudioConverterPrimeInfo, sizeof(primeInfo), &primeInfo);
            if (status != noErr) {
                return NO;
            }
        }
    }
    
    _decodingContext.inputFile.afid = inputFile;
    _decodingContext.inputFile.bufferSize = (UInt32)_bufferSize;
    _decodingContext.inputFile.buffer = malloc(_decodingContext.inputFile.bufferSize);
    _decodingContext.inputFile.pos = 0;
    _decodingContext.inputFile.format = _decodingContext.inputFormat;
    
    if (_decodingContext.inputFormat.mBytesPerPacket == 0) {
        size = sizeof(_decodingContext.inputFile.srcSizePerPacket);
        status = AudioFileGetProperty(inputFile, kAudioFilePropertyPacketSizeUpperBound, &size, &_decodingContext.inputFile.srcSizePerPacket);
        if (status != noErr) {
            free(_decodingContext.inputFile.buffer);
            return NO;
        }
        
        _decodingContext.inputFile.numPacketsPerRead = _decodingContext.inputFile.bufferSize / _decodingContext.inputFile.srcSizePerPacket;
        _decodingContext.inputFile.pktDescs = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * _decodingContext.inputFile.numPacketsPerRead);
    } else {
        _decodingContext.inputFile.srcSizePerPacket = _decodingContext.inputFormat.mBytesPerPacket;
        _decodingContext.inputFile.numPacketsPerRead = _decodingContext.inputFile.bufferSize / _decodingContext.inputFile.srcSizePerPacket;
        _decodingContext.inputFile.pktDescs = NULL;
    }
    
    _decodingContext.outputFile.pktDescs = NULL;
    UInt32 outputSizePerPacket = _decodingContext.outputFormat.mBytesPerPacket;
    
    _decodingContext.outputFile.bufferSize = (UInt32)_bufferSize;
    _decodingContext.outputFile.buffer = malloc(_decodingContext.outputFile.bufferSize);
    
    if (outputSizePerPacket == 0) {
        size = sizeof(outputSizePerPacket);
        status = AudioConverterGetProperty(_audioConverter, kAudioConverterPropertyMaximumOutputPacketSize, &size, &outputSizePerPacket);
        if (status != noErr) {
            free(_decodingContext.inputFile.buffer);
            free(_decodingContext.outputFile.buffer);
            if (_decodingContext.inputFile.pktDescs != NULL) {
                free(_decodingContext.inputFile.pktDescs);
            }
            return NO;
        }
        
        _decodingContext.outputFile.pktDescs = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * _decodingContext.outputFile.bufferSize / outputSizePerPacket);
    }
    
    _decodingContext.outputFile.numOutputPackets = _decodingContext.outputFile.bufferSize / outputSizePerPacket;
    _decodingContext.outputFile.pos = 0;
    
    pthread_mutex_init(&_decodingContext.mutex, NULL);
    _decodingContextInitialized = YES;
    
    return YES;
}


- (void)tearDown {
 
    if (!_decodingContextInitialized) {
        return;
    }
    
    free(_decodingContext.inputFile.buffer);
    free(_decodingContext.outputFile.buffer);
    
    if (_decodingContext.inputFile.pktDescs != NULL) {
        free(_decodingContext.inputFile.pktDescs);
    }
    
    if (_decodingContext.outputFile.pktDescs != NULL) {
        free(_decodingContext.outputFile.pktDescs);
    }
    
    pthread_mutex_destroy(&_decodingContext.mutex);
    _decodingContextInitialized = NO;
}

- (XMNAudioDecoderStatus)decodeOnce {
    
    if (!_decodingContextInitialized) {
        return XMNAudioDecoderFailed;
    }
    
    AudioFileTypeID fileTypeID = [self.playbackItem.audioFile fileTypeID];
    
    if (fileTypeID == kAudioFileAMRType) {
        
        NSData *data = [self parseAMRDataWithData:(UInt32)16384];
        [_lpcm writeBytes:[data bytes] length:data.length];
        if (!data || data.length == 0) {
            
            return XMNAudioDecoderEndEncountered;
        }
        return XMNAudioDecoderSucceeded;
    }
    pthread_mutex_lock(&_decodingContext.mutex);
    
    XMNAudioFileProvider *provider = [_playbackItem fileProvider];
    
    /** provider打开文件失败,不解码,直接报错 */
    if ([provider isFailed]) {
        [_lpcm setEnd:YES];
        pthread_mutex_unlock(&_decodingContext.mutex);
        return XMNAudioDecoderFailed;
    }
    
    /** provider 还未加载完成, 判断是否有足够的数据用来解码 */
    if (![provider isFinished]) {
        NSUInteger dataOffset = [_playbackItem dataOffset];
        NSUInteger expectedDataLength = [provider expectedLength];
        NSInteger receivedDataLength  = (NSInteger)([provider receivedLength] - dataOffset);
        
        SInt64 packetNumber = _decodingContext.inputFile.pos + _decodingContext.inputFile.numPacketsPerRead;
        SInt64 packetDataOffset = packetNumber * _decodingContext.inputFile.srcSizePerPacket;
        
        SInt64 bytesPerPacket = _decodingContext.inputFile.srcSizePerPacket;
        SInt64 bytesPerRead = bytesPerPacket * _decodingContext.inputFile.numPacketsPerRead;
        
        SInt64 framesPerPacket = _decodingContext.inputFormat.mFramesPerPacket;
        double intervalPerPacket = 1000.0 / _decodingContext.inputFormat.mSampleRate * framesPerPacket;
        double intervalPerRead = intervalPerPacket / bytesPerPacket * bytesPerRead;
        
        double downloadTime = 1000.0 * (bytesPerRead - (receivedDataLength - packetDataOffset)) / [provider downloadSpeed];
        SInt64 bytesRemaining = (SInt64)(expectedDataLength - (NSUInteger)receivedDataLength);
        
        if (receivedDataLength < packetDataOffset ||
            (bytesRemaining > 0 &&
             downloadTime > intervalPerRead)) {
                pthread_mutex_unlock(&_decodingContext.mutex);
                return XMNAudioDecoderWaiting;
            }
    }
    
    /** 创建缓冲队列 */
    AudioBufferList fillBufList;
    fillBufList.mNumberBuffers = 1;
    fillBufList.mBuffers[0].mNumberChannels = _decodingContext.inputFormat.mChannelsPerFrame;
    fillBufList.mBuffers[0].mDataByteSize = _decodingContext.outputFile.bufferSize;
    fillBufList.mBuffers[0].mData = _decodingContext.outputFile.buffer;
    
    OSStatus status;
    UInt32 ioOutputDataPackets = _decodingContext.outputFile.numOutputPackets;
    status = AudioConverterFillComplexBuffer(_audioConverter, decoder_data_proc, &_decodingContext.inputFile, &ioOutputDataPackets, &fillBufList, _decodingContext.outputFile.pktDescs);
    if (status != noErr) {
        pthread_mutex_unlock(&_decodingContext.mutex);
        return XMNAudioDecoderFailed;
    }
    
    if (ioOutputDataPackets == 0) {
        [_lpcm setEnd:YES];
        pthread_mutex_unlock(&_decodingContext.mutex);
        return XMNAudioDecoderEndEncountered;
    }
    
    SInt64 frame1 = _decodingContext.outputFile.pos + ioOutputDataPackets;
    if (_decodingContext.decodeValidFrames != 0 &&
        frame1 > _decodingContext.decodeValidFrames) {
        SInt64 framesToTrim64 = frame1 - _decodingContext.decodeValidFrames;
        UInt32 framesToTrim = (framesToTrim64 > ioOutputDataPackets) ? ioOutputDataPackets : (UInt32)framesToTrim64;
        int bytesToTrim = (int)(framesToTrim * _decodingContext.outputFormat.mBytesPerFrame);
        
        fillBufList.mBuffers[0].mDataByteSize -= (unsigned long)bytesToTrim;
        ioOutputDataPackets -= framesToTrim;
        
        if (ioOutputDataPackets == 0) {
            [_lpcm setEnd:YES];
            pthread_mutex_unlock(&_decodingContext.mutex);
            return XMNAudioDecoderEndEncountered;
        }
    }
    
    UInt32 inNumBytes = fillBufList.mBuffers[0].mDataByteSize;
    [_lpcm writeBytes:_decodingContext.outputFile.buffer length:inNumBytes];
    _decodingContext.outputFile.pos += ioOutputDataPackets;
    
    pthread_mutex_unlock(&_decodingContext.mutex);
    return XMNAudioDecoderSucceeded;
}

- (void)seekToTime:(NSUInteger)milliseconds {
    
    if (!_decodingContextInitialized) {
        return;
    }
    
    pthread_mutex_lock(&_decodingContext.mutex);
    
    double frames = (double)milliseconds * _decodingContext.inputFormat.mSampleRate / 1000.0;
    double packets = frames / _decodingContext.inputFormat.mFramesPerPacket;
    SInt64 packetNumebr = (SInt64)lrint(floor(packets));
    
    _decodingContext.inputFile.pos = packetNumebr;
    _decodingContext.outputFile.pos = packetNumebr * _decodingContext.inputFormat.mFramesPerPacket / _decodingContext.outputFormat.mFramesPerPacket;
    
    pthread_mutex_unlock(&_decodingContext.mutex);
}

/// ========================================
/// @name   Private Methods
/// ========================================

- (BOOL)setupAudioConverter {
    
    if (self.playbackItem.fileTypeID == kAudioFileAMRType) {
        _decodingContextInitialized = [self setupAMRDecoder];
        return _decodingContextInitialized;
    }
    AudioStreamBasicDescription inputFormat = [_playbackItem fileFormat];
    OSStatus status = AudioConverterNew(&inputFormat, &_outputFormat, &_audioConverter);
    if (status != noErr) {

        _audioConverter = NULL;
    }
    return status == noErr;
}

- (void)fillMagicCookieForFileID:(AudioFileID)inputFile {
    
    UInt32 cookieSize = 0;
    OSStatus status = AudioFileGetPropertyInfo(inputFile, kAudioFilePropertyMagicCookieData, &cookieSize, NULL);
    
    if (status == noErr && cookieSize > 0) {
        void *cookie = malloc(cookieSize);
        
        status = AudioFileGetProperty(inputFile, kAudioFilePropertyMagicCookieData, &cookieSize, cookie);
        if (status != noErr) {
            free(cookie);
            return;
        }
        
        status = AudioConverterSetProperty(_audioConverter, kAudioConverterDecompressionMagicCookie, cookieSize, cookie);
        free(cookie);
        if (status != noErr) {
            return;
        }
    }
}

/// ========================================
/// @name   Class Methods
/// ========================================

+ (AudioStreamBasicDescription)defaultOutputFormat {
    
    static AudioStreamBasicDescription defaultOutputFormat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultOutputFormat.mFormatID = kAudioFormatLinearPCM;
        defaultOutputFormat.mSampleRate = 44100;
        
        defaultOutputFormat.mBitsPerChannel = 16;
        defaultOutputFormat.mChannelsPerFrame = 2;
        defaultOutputFormat.mBytesPerFrame = defaultOutputFormat.mChannelsPerFrame * (defaultOutputFormat.mBitsPerChannel / 8);
        
        defaultOutputFormat.mFramesPerPacket = 1;
        defaultOutputFormat.mBytesPerPacket = defaultOutputFormat.mFramesPerPacket * defaultOutputFormat.mBytesPerFrame;
        
        defaultOutputFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    });

    return defaultOutputFormat;
}

+ (AudioStreamBasicDescription)defaultAMROutputFormat {
    
    static AudioStreamBasicDescription defaultAMROutputFormat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        defaultAMROutputFormat.mFormatID = kAudioFormatLinearPCM;
        defaultAMROutputFormat.mSampleRate = 8000;
        
        defaultAMROutputFormat.mBitsPerChannel = 16;
        defaultAMROutputFormat.mChannelsPerFrame = 1;
        defaultAMROutputFormat.mBytesPerFrame = defaultAMROutputFormat.mChannelsPerFrame * (defaultAMROutputFormat.mBitsPerChannel / 8);
        
        defaultAMROutputFormat.mFramesPerPacket = 1;
        defaultAMROutputFormat.mBytesPerPacket = defaultAMROutputFormat.mFramesPerPacket * defaultAMROutputFormat.mBytesPerFrame;
        
        defaultAMROutputFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    });
    
    return defaultAMROutputFormat;
}
@end
