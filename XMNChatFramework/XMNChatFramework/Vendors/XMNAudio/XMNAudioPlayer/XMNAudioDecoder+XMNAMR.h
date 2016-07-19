//
//  XMNAudioDecoder+XMNAMR.h
//  XMNAudio
//
//  Created by XMFraker on 16/7/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioDecoder.h"

@interface XMNAudioDecoder (XMNAMR)

- (BOOL)setupAMRDecoder;

- (NSData *)parseAMRDataWithData:(UInt32)bufferSize;

@end
