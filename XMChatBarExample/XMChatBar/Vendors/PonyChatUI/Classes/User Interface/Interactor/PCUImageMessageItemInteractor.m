//
//  PCUImageMessageItemInteractor.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUImageMessageItemInteractor.h"
#import "PCUImageMessageEntity.h"

@implementation PCUImageMessageItemInteractor

- (instancetype)initWithMessageItem:(PCUMessageEntity *)messageItem {
    self = [super initWithMessageItem:messageItem];
    if (self) {
        _imageURLString = [(PCUImageMessageEntity *)messageItem imageURLString];
        _image = [(PCUImageMessageEntity *)messageItem image];
        if ([(PCUImageMessageEntity *)messageItem imageSize].width > 120.0) {
            _imageWidth = 120.0;
            _imageHeight = 120.0 * [(PCUImageMessageEntity *)messageItem imageSize].height / [(PCUImageMessageEntity *)messageItem imageSize].width;
            if (_imageHeight > 180.0) {
                _imageHeight = 180.0;
            }
        }
        else if ([(PCUImageMessageEntity *)messageItem imageSize].height > 180.0) {
            _imageHeight = 180.0;
            _imageWidth = 180.0 * [(PCUImageMessageEntity *)messageItem imageSize].width / [(PCUImageMessageEntity *)messageItem imageSize].height;
            if (_imageWidth > 120.0) {
                _imageWidth = 120.0;
            }
        }else{
            //修复指定imageSize 小于(120,180)时不显示的bug
            _imageWidth = [(PCUImageMessageEntity *)messageItem imageSize].width;
            _imageHeight = [(PCUImageMessageEntity *)messageItem imageSize].height;
        }
    }
    return self;
}

@end
