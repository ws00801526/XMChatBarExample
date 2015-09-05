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

//
//- (void)setImageSize:(CGSize)imageSize{
//    CGSize lastImageSize = CGSizeZero;
//    if (imageSize.width > 150.0f) {
//        lastImageSize.width = 150.0f;
//        lastImageSize.height = imageSize.height * 150.0f / imageSize.width;
//    }else if (imageSize.height > 200.0) {
//        lastImageSize.height = 200.0f;
//        lastImageSize.width = 200.0f * imageSize.width / imageSize.height;
//        if (lastImageSize.width > 15.0f) {
//            lastImageSize.width = 15.0f;
//        }
//    }else{
//        //修复指定imageSize 小于(120,180)时不显示的bug
//        lastImageSize.width = 150.0f;
//        lastImageSize.height = 200.0f;
//    }
//    _imageSize = lastImageSize;
//}

@end
