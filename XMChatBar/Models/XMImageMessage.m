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

- (CGSize)imageSize{
    if (_imageSize.width > 150) {
        CGSize size = CGSizeMake(150, 0);
        size.height = 150 * _imageSize.height / _imageSize.width;
        return size;
    }else if (_imageSize.height > 200){
        CGSize size = CGSizeMake(0, 200);
        size.width = 200 * _imageSize.width / _imageSize.height;
        return size;
    }else{
        return _imageSize;
    }
}

@end
