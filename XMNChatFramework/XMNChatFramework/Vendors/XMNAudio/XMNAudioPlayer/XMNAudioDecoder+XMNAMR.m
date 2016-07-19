//
//  XMNAudioDecoder+XMNAMR.m
//  XMNAudio
//
//  Created by XMFraker on 16/7/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioDecoder+XMNAMR.h"

#import "XMNAudioFile.h"
#import "XMNAudioPlaybackItem.h"
#import "XMNAudioConfiguration.h"

#if __has_include("interf_enc.h")
    #ifndef kXMNAudioEncoderAMREnable
        #define kXMNAudioEncoderAMREnable
    #endif
    #import "interf_dec.h"
    #define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
    #define MAX_AMR_FRAME_SIZE 32
    #define AMR_FRAME_COUNT_PER_SECOND 50
    #define AMR_MAGIC_NUMBER "#!AMR\n"
#endif

@implementation XMNAudioDecoder (XMNAMR)

- (BOOL)setupAMRDecoder {
    
#ifndef kXMNAudioEncoderAMREnable
    return NO;
#endif
    
    _destate = 0;
    // amr 解压句柄
    
    /** 初始化amr 句柄 */
    _destate = Decoder_Interface_init();
    
    if(_destate == 0){
        
        XMNLog(@"初始化AMR句柄出错");
        return NO;
    }
    
    //建立amr文件
    
    /** 打开AMR文件 */
    NSString *filePath = [[[self.playbackItem audioFile] audioFileURL] path];
    /** 出去file:// 头部*/
    if ([filePath hasPrefix:@"file://"]) {
        filePath = [filePath substringFromIndex:7];
    }
    
    _file = fopen((const char *)[filePath UTF8String], "rb");
    if (_file==0) {
        
        XMNLog(@"打开AMR文件失败");
        return NO;
    }
    
//    //忽略文件头大小
//    char magic[8];
//    static const char * amrHeader = AMR_MAGIC_NUMBER;
//    /** 读取不到AMR头部, 出错 */
//    strncmp(magic, amrHeader, strlen(amrHeader));
    
    //读取一个参考帧
    if(!XMNAMRReadFirstFrame(_file, &_stdFrameSize, &_stdFrameHeader)){
        return NO;
    }
    
    return YES;
}


- (NSData *)parseAMRDataWithData:(UInt32)bufferSize {
    
#ifndef kXMNAudioEncoderAMREnable
    return nil;
#endif
    
    //读取数据
    if (!_file) {

        return nil;
    }
    
    //计算存储到bufferSize里需要读取多少帧
    int needReadFrameCount = floor(bufferSize/(PCM_FRAME_SIZE*sizeof(short)));
    
    NSMutableData *data = [NSMutableData data];
    
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
    short pcmFrame[PCM_FRAME_SIZE];
    
    for (NSUInteger i=0; i<needReadFrameCount; i++) {
        memset(amrFrame, 0, sizeof(amrFrame));
        memset(pcmFrame, 0, sizeof(pcmFrame));
                unsigned char frameHeader; // 帧头
        
        // 读帧头
        // 如果是坏帧(不是标准帧头)，则继续读下一个字节，直到读到标准帧头
        while(1) {
            fread(&frameHeader, 1, sizeof(unsigned char), _file);
            if (feof(_file)) break;
            if (frameHeader == _stdFrameHeader) break;
        }
        
        // 读该帧的语音数据(帧头已经读过)
        amrFrame[0] = _stdFrameHeader;
        fread(&(amrFrame[1]), 1, (_stdFrameSize-1)*sizeof(unsigned char), _file);
        if (feof(_file)) break;
        // 解码一个AMR音频帧成PCM数据 (8k-16b-单声道)
        Decoder_Interface_Decode(_destate, amrFrame, pcmFrame, 0);
        [data appendBytes:pcmFrame length:sizeof(pcmFrame)];
    }
    
    return data;
}


// 读第一个帧 - (参考帧)
BOOL XMNAMRReadFirstFrame(FILE* fpamr, int* stdFrameSize, unsigned char* stdFrameHeader)
{
    unsigned long curpos = ftell(fpamr); //记录当前位置，这一帧只是读取一下，并不做处理
    
    fseek(fpamr, strlen(AMR_MAGIC_NUMBER), SEEK_SET);
    
    //先读帧头
    fread(stdFrameHeader, 1, sizeof(unsigned char), fpamr);
    if (feof(fpamr)) return NO;
    
    fseek(fpamr,curpos,SEEK_SET); //还原位置
    
    // 根据帧头计算帧大小
    *stdFrameSize = XMNAMRCalculateFrameSize(*stdFrameHeader);
    
    return YES;
}

const int myround(const double x)
{
    return((int)(x+0.5));
}

// 根据帧头计算当前帧大小
int XMNAMRCalculateFrameSize(unsigned char frameHeader)
{
    
    int amrEncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200}; // amr 编码方式
    
    int mode;
    int temp1 = 0;
    int temp2 = 0;
    int frameSize;
    
    temp1 = frameHeader;
    
    // 编码方式编号 = 帧头的3-6位
    temp1 &= 0x78; // 0111-1000
    temp1 >>= 3;
    
    mode = amrEncodeMode[temp1];
    
    // 计算amr音频数据帧大小
    // 原理: amr 一帧对应20ms，那么一秒有50帧的音频数据
    temp2 = myround((double)(((double)mode / (double)AMR_FRAME_COUNT_PER_SECOND) / (double)8));
    
    frameSize = myround((double)temp2 + 0.5);
    return frameSize;
}


/**
 *  计算文件文本大小
 *
 */
long filesize(FILE *stream)
{
    long curpos,length;
    curpos=ftell(stream);
    fseek(stream,0L,SEEK_END);
    length=ftell(stream);
    fseek(stream,curpos,SEEK_SET);
    return length;
}

+ (double)durationOfAmrFilePath:(NSString*)filePath {
    //建立amr文件
    if ([filePath hasPrefix:@"file://"]) {
        filePath = [filePath substringFromIndex:7];
    }
    
    FILE *file = fopen((const char *)[filePath UTF8String], "rb");
    if (file==0) {
        XMNLog(@"计算AMR时长  打开文件失败");
        return 0;
    }
    
    unsigned char stdFrameHeader;
    int stdFrameSize;
    if(!XMNAMRReadFirstFrame(file, &stdFrameSize, &stdFrameHeader)){
        XMNLog(@"计算AMR时长  读取AMR首帧失败");
        return 0;
    }
    
    //检测此文件一共有多少帧
    long fileSize = filesize(file);
    if(file){
        fclose(file);
    }
    
    return ((fileSize - strlen(AMR_MAGIC_NUMBER))/(double)stdFrameSize)/(double)AMR_FRAME_COUNT_PER_SECOND;
}
@end
