//
//  XMNAudioRecorder.m
//  XMNAudioRecorder
//
//  Created by XMFraker on 16/6/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioRecorder.h"

#import <CommonCrypto/CommonCrypto.h>
#import <AVFoundation/AVFoundation.h>

#import "XMNAudioConfiguration.h"

#define audioQueueOpertaion(operation,error) \
do{\
if(operation!=noErr) { \
[self handleErrorWithCode:XMNAudioRecorderErrorCodeSession errorDesc:error]; \
return; \
}   \
}while(0)

static NSDateFormatter *kXMNAudioDateFormatter = nil;
static dispatch_once_t onceToken;

@interface XMNAudioRecorder ()
{
    //音频输入缓冲区
    AudioQueueBufferRef	_audioBuffers[3];
}

/** 文件操作队列 */
@property (nonatomic, strong) dispatch_queue_t recordOperationQueue;

/** 信号量,处理队列中 错误 */
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, assign, getter=isRecording) BOOL recording;

@property (nonatomic, strong) id<XMNAudioEncoder> encoder;

@property (nonatomic, copy)   NSString *filename;
@property (nonatomic, copy, readonly)   NSString *fileExtension;

@property (nonatomic, assign) NSTimeInterval startTimeInterval;
@property (nonatomic, assign) NSTimeInterval seconds;

@end

@implementation XMNAudioRecorder

- (instancetype)init {
    
    if (self = [super init]) {
        
        /** 需要注意的是 转换成amr的话必须使用8000 */
        _sampleRate = 44100;
        _bufferDurationSeconds = .5f;
        _recording = NO;
        
        _recordOperationQueue = dispatch_queue_create("com.XMFraker.XMNAudioRecorder.FileOperationQueue", NULL);
        
        /** 坚挺打断通知,打断时停止录音 */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        self.encoderType = XMNAudioEncoderTypeCAF;
        
        _filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"com.XMFraker.XMNAudioRecorder"] copy];
        
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
            }
        }else {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_filePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString * _Nullable)filePath {
    
    if (self = [[[self class] alloc] init]) {
        
        _filePath = filePath ? [filePath copy] : _filePath;
        
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
            }
        }else {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_filePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    }
    return self;
}

- (void)dealloc {
    
    NSAssert(!self.isRecording, @"you should stop recording before dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:[AVAudioSession sharedInstance]];
}

#pragma mark - Methods

/// ========================================
/// @name   Public Methods
/// ========================================

- (void)startRecording {
    
    self.filename = [self randomFilename:24];
    if (self.fileExtension) {
        self.filename = [self.filename stringByAppendingPathExtension:self.fileExtension];
    }
    [self startRecordingWithFileName:self.filename];
}

- (void)startRecordingWithFileName:(NSString *)filename {
    
    NSAssert(filename, @"you should pass a filename");
    
    /** 开始录音 */
    NSError *error = nil;
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        
        [self handleErrorWithCode:XMNAudioRecorderErrorCodeSession errorDesc:@"AVAudioSession setCategory error"];
        XMNLog(@"AVAudioSession setCategory error :%@",error);
        return;
    }
    
    if (![[AVAudioSession sharedInstance] setActive:YES error:&error]) {
        
        [self handleErrorWithCode:XMNAudioRecorderErrorCodeSession errorDesc:@"AVAudioSession setActive error"];
        XMNLog(@"AVAudioSession setActive error :%@",error);
        return;
    }
    
    NSAssert(self.encoder, @"you should set convertType && convert before recording");
    
    if (self.encoder && [self.encoder respondsToSelector:@selector(customAudioFomatForRecorder:)]) {
        
        XMNLog(@"will use custom AudioStreamFormat");
        /** 设置 自定义的录音格式 */
        dispatch_sync(self.recordOperationQueue, ^{
            AudioStreamBasicDescription format = [self.encoder customAudioFomatForRecorder:self];
            memcpy(&_recordFormat, &format,sizeof(_recordFormat));
        });
    }else {
        /** 设置默认的录音格式 */
        [self setupAudioFormat];
    }
    
    __block BOOL canRecord = YES;;
    
    dispatch_sync(self.recordOperationQueue, ^{
        
        if ([self.encoder recorder:self createFileAtPath:[self.filePath stringByAppendingPathComponent:filename]]) {
            
            XMNLog(@"create recording file success");
        }else {
            
            canRecord = NO;
            XMNLog(@"create recording file failed");
            [self handleErrorWithCode:XMNAudioRecorderErrorCodeFile errorDesc:@"create recording file failed"];
        }
    });
    
    if (!canRecord) {
        
        return;
    }
    
    /** 创建信号量 */
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(self.semaphore);
    
    audioQueueOpertaion(AudioQueueNewInput(&_recordFormat, recordingBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue), @"初始化音频队列失败");
    
    //计算估算的缓存区大小
    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);
    int bufferByteSize = frames * _recordFormat.mBytesPerFrame;
    XMNLog(@"缓冲区大小:%d",bufferByteSize);
    
    //创建缓冲器
    for (int i = 0; i < 3; ++i){
        audioQueueOpertaion(AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]), @"创建音频缓存区失败");
        audioQueueOpertaion(AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL), @"为音频输入队列缓冲区做准备失败");
    }
    audioQueueOpertaion(AudioQueueStart(_audioQueue, NULL), @"音频队列开始录音失败");
    
    _recording = YES;
    self.startTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (void)stopRecording {
    
    /** 停止录音 */
    if (self.isRecording) {
        _recording = NO;
        self.seconds = [[NSDate date] timeIntervalSinceReferenceDate] - self.startTimeInterval;

        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        __block BOOL canContinue = YES;;
        dispatch_sync(self.recordOperationQueue, ^{
            if (![self.encoder recorder:self completedRecordWithError:nil]) {
                XMNLog(@"录音结束");
                canContinue = NO;
            }
        });
        
        if (self.seconds < self.bufferDurationSeconds) {
            [self handleErrorWithCode:XMNAudioRecorderErrorCodeTooShort errorDesc:@"录音文件时长太短"];
            canContinue = NO;
        }
        
        if (canContinue) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didRecordFinishWithRecorder:)]) {
                
                [self.delegate didRecordFinishWithRecorder:self];
            }
            self.recordFinishBlock ? self.recordFinishBlock(self) : nil;
        }
    }
}


/// ========================================
/// @name   Private Methods
/// ========================================

- (void)handleErrorWithCode:(XMNAudioRecorderErrorCode)errorCode
                  errorDesc:(NSString *)errorDesc {
    
    _recording = NO;
    
    if (_audioQueue) {
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
    }
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    dispatch_sync(self.recordOperationQueue, ^{
        
        [self.encoder recorder:self completedRecordWithError:nil];
    });
    
    
    XMNLog(@"recording failed :%@",errorDesc);
    NSError *error = [NSError errorWithDomain:kXMNAudioRecorderErrorDomain
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorder:didRecordError:)]) {
        [self.delegate recorder:self didRecordError:error];
    }
    
    self.recordErrorBlock ? self.recordErrorBlock(self, error) : nil;
}

- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType)
    {
        //直接停止录音
        [self stopRecording];
    } else if (AVAudioSessionInterruptionTypeEnded == interruptionType) {
    
        /** 不提供继续录音功能 */
    }
}


// 设置录音格式
- (void)setupAudioFormat
{
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    
    //设置采样率，这里先获取系统默认的测试下 //TODO:
    //采样率的意思是每秒需要采集的帧数
    _recordFormat.mSampleRate = self.sampleRate;//[[AVAudioSession sharedInstance] sampleRate];
    
    //设置通道数,这里先使用系统的测试下 //TODO:
    _recordFormat.mChannelsPerFrame = 1;//(UInt32)[[AVAudioSession sharedInstance] inputNumberOfChannels];
    
    //    DLOG(@"sampleRate:%f,通道数:%d",_recordFormat.mSampleRate,_recordFormat.mChannelsPerFrame);
    
    //设置format，怎么称呼不知道。
    _recordFormat.mFormatID = kAudioFormatLinearPCM;
    
    if (_recordFormat.mFormatID == kAudioFormatLinearPCM){
        //这个屌属性不知道干啥的。，
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
    }
}


- (NSString *)randomFilename:(NSUInteger)length {

    char data[length];
    for (int x=0;x<length;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    NSString *str = [[NSString alloc] initWithBytes:data
                                             length:length
                                           encoding:NSUTF8StringEncoding];
    [[[NSDateFormatter alloc] init] stringFromDate:[NSDate date]];
    
    dispatch_once(&onceToken, ^{
        kXMNAudioDateFormatter = [[NSDateFormatter alloc] init];
        [kXMNAudioDateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
    });
    
    return [[_XMNMD5(str) stringByAppendingString:@"__"] stringByAppendingString:[kXMNAudioDateFormatter stringFromDate:[NSDate date]]];
}

/// String's md5 hash.
static NSString *_XMNMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


/// ========================================
/// @name   AVAudioSession 回调函数
/// ========================================


void recordingBufferHandler(void *inputData,
                            AudioQueueRef inputQueueRef,
                            AudioQueueBufferRef inputQueueBufferRef,
                            const AudioTimeStamp *inputTime,
                            UInt32 inputPackets,
                            const AudioStreamPacketDescription *inputPacketDesc) {
    
    XMNAudioRecorder *recorder = (__bridge XMNAudioRecorder*)inputData;
    
    if (inputPackets > 0) {
        
        NSData *pcmData = [[NSData alloc] initWithBytes:inputQueueBufferRef->mAudioData
                                                 length:inputQueueBufferRef->mAudioDataByteSize];
        if (pcmData&&pcmData.length>0) {
            
            //在后台串行队列中去处理文件写入
            dispatch_async(recorder.recordOperationQueue, ^{
                
                BOOL writeDataSuccess =  [recorder.encoder recorder:recorder
                                                        writeFileData:pcmData
                                                        inputQueueRef:inputQueueRef
                                                       inputTimeStamp:inputTime
                                                         inputPackets:inputPackets
                                                     inputPacketsDesc:inputPacketDesc];
                
                if (!writeDataSuccess) {
                    if (dispatch_semaphore_wait(recorder.semaphore ,DISPATCH_TIME_NOW) == 0) {
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            [recorder handleErrorWithCode:XMNAudioRecorderErrorCodeFile errorDesc:@"数据写入文件失败"];
                        });
                    }
                }
            });
        }
    }
    if (recorder.isRecording) {
        
        if(AudioQueueEnqueueBuffer(inputQueueRef, inputQueueBufferRef, 0, NULL)!=noErr) {
            
            /** 修改isRecording */
            recorder.recording = NO;
            dispatch_async(dispatch_get_main_queue(),^{
                
            });
        }
    }
}

#pragma mark - Setters

- (void)setEncoderType:(XMNAudioEncoderType)convertType {
    
    _encoderType =  convertType;
    switch (convertType) {
        case XMNAudioEncoderTypeAMR:
#ifdef kXMNAudioEncoderAMREnable
            self.encoder = [[XMNAudioRecorderAMREncoder alloc] init];
            _sampleRate = 8000;
#else
            self.encoder = nil;
            XMNLog(@"AMREncoder is not avaliable,you should import libopencore_amr library");
#endif
            break;
        case XMNAudioEncoderTypeMP3:
#ifdef kXMNAudioEncoderMP3Enable
            self.encoder = [[XMNAudioRecorderMP3Encoder alloc] init];
            _sampleRate = 44100;
#else
            self.encoder = nil;
            XMNLog(@"MP3Encoder is not avaliable,you should import lame library");
#endif
            break;
        case XMNAudioEncoderTypeCAF:
            
            self.encoder = [[XMNAudioRecorderCAFEncoder alloc] init];
            _sampleRate = 44100;
            break;
        default:
            self.encoder = nil;
            break;
    }
}

#pragma mark - Getters

- (BOOL)isRecording {
    
    return _recording;
}

- (NSString *)fileExtension {
    
    switch (self.encoderType) {
        case XMNAudioEncoderTypeAMR:
            return @"amr";
        case XMNAudioEncoderTypeCAF:
            
            return @"caf";
        case XMNAudioEncoderTypeMP3:
            return @"mp3";
        default:
            return nil;
    }
}

@end

