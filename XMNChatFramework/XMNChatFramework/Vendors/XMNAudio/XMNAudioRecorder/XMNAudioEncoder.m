//
//  XMNAudioEncoder.m
//  XMNAudioRecorder
//
//  Created by XMFraker on 16/6/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioEncoder.h"
#import "XMNAudioRecorder.h"
#import "XMNAudioConfiguration.h"



#pragma mark - MP3 Encoder

#ifdef kXMNAudioEncoderMP3Enable
@implementation XMNAudioRecorderMP3Encoder
{
    FILE *_file;
    lame_t _lame;
    /** 录音文件的大小 */
    unsigned long _filesize;
    /** 录音文件的时长 */
    double _seconds;
}

- (BOOL)recorder:(XMNAudioRecorder *)recorder createFileAtPath:(NSString *)filePath {
    
    // mp3压缩参数
    _lame = lame_init();
    lame_set_num_channels(_lame, 1);
    lame_set_in_samplerate(_lame, (int)recorder.sampleRate);
    lame_set_out_samplerate(_lame, (int)recorder.sampleRate);
    lame_set_brate(_lame, 128);
    lame_set_mode(_lame, 1);
    lame_set_quality(_lame, 2);
    lame_init_params(_lame);
    
    //建立mp3文件
    _file = fopen((const char *)[filePath UTF8String], "wb+");
    
    if (_file==0) {
        
        XMNLog(@"建立文件失败:%s",__FUNCTION__);
        return NO;
    }
    
    _filesize = 0;
    _seconds = 0;
    
    XMNLog(@"create mp3 file success :%@",filePath);
    return YES;
    
}


- (BOOL)recorder:(XMNAudioRecorder *)recorder
   writeFileData:(NSData *)data
   inputQueueRef:(AudioQueueRef)inputQueueRef
  inputTimeStamp:(const AudioTimeStamp *)inputTimeStamp
    inputPackets:(UInt32)inputPackets
inputPacketsDesc:(const AudioStreamPacketDescription *)inputPacketsDesc {
    
    
    /** 添加限制时长功能 */
    if (recorder.maxSeconds > 0) {
        if (_seconds + recorder.bufferDurationSeconds > recorder.maxSeconds) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [recorder stopRecording];
            });
            return YES;
        }
        _seconds += recorder.bufferDurationSeconds;
    }
    
    //编码
    short *recordingData = (short*)data.bytes;
    int pcmLen = (UInt32)data.length;
    
    if (pcmLen<2){
        return YES;
    }
    
    int nsamples = pcmLen / 2;
    
    unsigned char buffer[pcmLen];
    // mp3 encode
    int recvLen = lame_encode_buffer(_lame, recordingData, recordingData, nsamples, buffer, pcmLen);
    // add NSMutable
    if (recvLen>0) {
        
        /** 添加限制录音文件大小功能 */
        if (recorder.maxFileSize > 0){
            if(_filesize + recvLen > recorder.maxFileSize){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [recorder stopRecording];
                });
                return YES;
            }
        }
        
        if(fwrite(buffer,1,recvLen,_file)==0){
            return NO;
        }
        _filesize += recvLen;
    }
    return YES;
}


- (BOOL)recorder:(XMNAudioRecorder *)recorder completedRecordWithError:(NSError *)error {
    
    if (_file) {
        fclose(_file);
    }
    
    if (_lame) {
        
        lame_close(_lame);
        _lame = 0;
    }
    return YES;
}

- (void)dealloc {
    
    if (_file) {
        fclose(_file);
    }
    
    if (_lame) {
        
        lame_close(_lame);
        _lame = 0;
    }
}


@end

#endif


#pragma mark - AMR Encoder

#ifdef kXMNAudioEncoderAMREnable

@implementation XMNAudioRecorderAMREncoder
{
    FILE *_file;

    void *_destate;
    /** 录音文件的大小 */
    unsigned long _filesize;
    /** 录音文件的时长 */
    double _seconds;
    
    /** 记录上次录音大小长度 */
    unsigned long _lastBytesLength;
    /** 记录上次录音 */
    unsigned char *_lastBytes;
}

- (BOOL)recorder:(XMNAudioRecorder *)recorder createFileAtPath:(NSString *)filePath {
    
    _destate = 0;
    // amr 压缩句柄
    _destate = Encoder_Interface_init(0);
    
    if(_destate==0){
        return NO;
    }
    
    //建立amr文件
    _file = fopen((const char *)[filePath UTF8String], "wb+");
    if (_file==0) {
        XMNLog(@"创建amr录音文件失败");
        return NO;
    }
    
    _filesize = 0;
    _seconds = 0;
    
    if (!_lastBytes) {
        _lastBytes = malloc(320);
    }
    _lastBytesLength = 0;
    
    /** 写入amr头文件 */
    static const char* amrHeader = "#!AMR\n";
    if(fwrite(amrHeader, 1, strlen(amrHeader), _file)==0){
        return NO;
    }
    _filesize += strlen(amrHeader);
    
    return YES;
}


- (BOOL)recorder:(XMNAudioRecorder *)recorder
   writeFileData:(NSData *)data
   inputQueueRef:(AudioQueueRef)inputQueueRef
  inputTimeStamp:(const AudioTimeStamp *)inputTimeStamp
    inputPackets:(UInt32)inputPackets
inputPacketsDesc:(const AudioStreamPacketDescription *)inputPacketsDesc {
    
    
    /** 添加限制时长功能 */
    if (recorder.maxSeconds > 0) {
        if (_seconds + recorder.bufferDurationSeconds > recorder.maxSeconds) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [recorder stopRecording];
            });
            return YES;
        }
        _seconds += recorder.bufferDurationSeconds;
    }
    
    //编码
    const void *recordingData = data.bytes;
    NSUInteger pcmLen = data.length;

    if (pcmLen<=0){
        return YES;
    }
    if (pcmLen%2!=0){
        pcmLen--; //防止意外，如果不是偶数，减去最后一个字节。
    }
    
    unsigned char * bytes = malloc(pcmLen+320);
    memset(bytes,0,pcmLen+320);
    memcpy(bytes,_lastBytes,_lastBytesLength);
    memcpy(bytes+_lastBytesLength, recordingData, pcmLen);
    pcmLen += _lastBytesLength;
    _lastBytesLength=0;
    unsigned char buffer[320];
    for (int i =0; i < pcmLen ;i+=160*2) {
        short *pPacket = (short *)((unsigned char*)bytes+i);
        if (pcmLen-i<160*2){
            
            _lastBytesLength = pcmLen - i;
            memcpy(_lastBytes, pPacket, _lastBytesLength);
            continue; //不是一个完整的就拜拜，等待下次数据传递进来再处理
        }
        
        memset(buffer, 0, sizeof(buffer));
        //encode
        int recvLen = Encoder_Interface_Encode(_destate,MR515,pPacket,buffer,0);
        if (recvLen>0) {
            
            /** 添加限制录音文件大小功能 */
            if (recorder.maxFileSize > 0){
                if(_filesize+recvLen > recorder.maxFileSize){

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [recorder stopRecording];
                    });
                    free(bytes);
                    return YES;//超过了最大文件大小就直接返回
                }
            }
            
            if(fwrite(buffer,1,recvLen,_file)==0){
                free(bytes);
                return NO;//只有写文件有可能出错。返回NO
            }
            _filesize += recvLen;
        }
    }
    
    free(bytes);
    return YES;
}


- (BOOL)recorder:(XMNAudioRecorder *)recorder completedRecordWithError:(NSError *)error {
    
    /** 关闭打开的文件 */
    if(_file){
        fclose(_file);
    }
    if (_destate){
        /** 关闭amr写入句柄 */
        Encoder_Interface_exit((void*)_destate);
        _destate = 0;
    }
    
    /** 释放内存 */
    if(_lastBytes) {
        free(_lastBytes);
        _lastBytes = nil;
    }
    _lastBytesLength = 0;
    
    return YES;
}

- (void)dealloc
{
    if(_file){
        fclose(_file);
        _file = 0;
    }
    if (_destate){
        Encoder_Interface_exit((void*)_destate);
        _destate = 0;
    }
    
    /** 释放内存 */
    if(_lastBytes) {
        free(_lastBytes);
        _lastBytes = nil;
    }
    _lastBytesLength = 0;
}

@end

#endif

#pragma mark - CAF Encoder

@implementation XMNAudioRecorderCAFEncoder
{
    AudioFileID _recordFile;
    SInt64      _recordPacketCount;
}


- (BOOL)recorder:(XMNAudioRecorder *)recorder
createFileAtPath:(NSString *)filePath {
    
    //建立文件
    _recordPacketCount = 0;
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)filePath, NULL);
    OSStatus err = AudioFileCreateWithURL(url, kAudioFileCAFType, (const AudioStreamBasicDescription	*)(&(recorder->_recordFormat)), kAudioFileFlags_EraseFile, &_recordFile);
    url ? CFRelease(url) : nil;
    return err == noErr;
}

- (BOOL)recorder:(XMNAudioRecorder *)recorder
   writeFileData:(NSData *)data
   inputQueueRef:(AudioQueueRef)inputQueueRef
  inputTimeStamp:(const AudioTimeStamp *)inputTimeStamp
    inputPackets:(UInt32)inputPackets
inputPacketsDesc:(const AudioStreamPacketDescription *)inputPacketsDesc {
    
    
    OSStatus err = AudioFileWritePackets(_recordFile, FALSE, (UInt32)[data length],
                                         inputPacketsDesc, _recordPacketCount, &inputPackets, data.bytes);
    if (err!=noErr) {
        return NO;
    }
    _recordPacketCount += inputPackets;
    
    return YES;
}

- (BOOL)recorder:(XMNAudioRecorder *)recorder completedRecordWithError:(NSError *)error {
    
    if (_recordFile) {
        
        OSStatus err =  AudioFileClose(_recordFile);
        if (err) {
            XMNLog(@"caf recorder failed ");
            return NO;
        }else {
            XMNLog(@"caf recorder success ");
            return YES;
        }
    }
    //    NSData *data = [[NSData alloc]initWithContentsOfFile:self.filePath];
    //    DLOG(@"文件长度%ld",data.length);
    return YES;
}

-(void)dealloc {
    
    if (_recordFile) {
        AudioFileClose(_recordFile);
    }
}

@end

