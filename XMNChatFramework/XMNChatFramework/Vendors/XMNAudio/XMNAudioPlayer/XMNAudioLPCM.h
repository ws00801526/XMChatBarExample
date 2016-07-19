//
//  XMNAudioLPCM.h
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  处理读写LPCM数据
 */
@interface XMNAudioLPCM : NSObject

@property (nonatomic, assign, getter=isEnd) BOOL end;

/**
 *  读取指定长度数据
 *
 *  @param bytes  输出的buffer
 *  @param length 读取的长度
 *
 *  @return 是否读取成功
 */
- (BOOL)readBytes:(void **)bytes length:(NSUInteger *)length;

/**
 *  写入指定长度的数据
 *
 *  @param bytes  需要写入的数据缓冲区
 *  @param length 写入数据的长度
 */
- (void)writeBytes:(const void *)bytes length:(NSUInteger)length;

@end
