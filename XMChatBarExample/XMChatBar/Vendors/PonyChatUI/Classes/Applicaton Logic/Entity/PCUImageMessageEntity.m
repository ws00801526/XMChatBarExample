//
//  PCUImageMessageEntity.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUImageMessageEntity.h"

@implementation PCUImageMessageEntity

- (void)setImage:(UIImage *)image{
    _image = image;
    _imageSize = image.size;
}

@end
