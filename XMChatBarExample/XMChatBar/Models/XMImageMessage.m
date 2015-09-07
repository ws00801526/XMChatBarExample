//
//  XMImageMessage.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/2.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMImageMessage.h"

@implementation XMImageMessage
@synthesize imageSize = _imageSize;

#pragma mark - Setters
- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageSize = image.size;
}


#pragma mark - Getters

@end
