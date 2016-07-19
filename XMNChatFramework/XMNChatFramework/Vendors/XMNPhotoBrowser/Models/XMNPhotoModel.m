//
//  XMNPhotoModel.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoModel.h"

#import "YYWebImage.h"

@implementation XMNPhotoModel

- (instancetype)initWithImagePath:(NSString *)imagePath
                        thumbnail:(UIImage *)thumnail {
    
    if (self = [super init]) {
        
        _imagePath = [imagePath copy];
        _thumbnail = thumnail;
    }
    return self;
}

- (instancetype)initWithImagePath:(NSString *)imagePath
                    thumbnailData:(NSData *)thumnailData {
    
    return [self initWithImagePath:imagePath
                         thumbnail:[[YYImage alloc] initWithData:thumnailData
                                                           scale:[UIScreen mainScreen].scale]];
}

#pragma mark - Getters

- (UIImage *)thumbnail {
    
    if (!_thumbnail || ![_thumbnail isKindOfClass:[UIImage class]]) {
        
        return [YYImage yy_imageWithColor:[UIColor blackColor]
                                     size:CGSizeMake([UIScreen mainScreen].bounds.size.width, 400)];
    }
    return _thumbnail;
}

- (CGSize)imageSize {
    
    if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
        
        if (self.image) {
            return self.image.size;
        }
        
        if (self.thumbnail) {
            return self.thumbnail.size;
        }
    }
    return _imageSize;
}

- (UIImage *)image {
    
    return [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.imagePath]]];
}


#pragma mark - Class Methods

+ (CGSize)adjustOriginSize:(CGSize)originSize
              toTargetSize:(CGSize)targetSize {
    
    CGSize retSize;
    
    /** 计算图片的比例 */
    CGFloat widthPercent = (originSize.width ) / (targetSize.width);
    CGFloat heightPercent = (originSize.height ) / targetSize.height;
    if (widthPercent <= 1.0f && heightPercent <= 1.0f) {
        retSize = CGSizeMake(originSize.width, originSize.height);
    } else if (widthPercent > 1.0f && heightPercent < 1.0f) {
        
        retSize = CGSizeMake(targetSize.width, (originSize.height * targetSize.width) / originSize.width);
    }else if (widthPercent <= 1.0f && heightPercent > 1.0f) {
        
        retSize = CGSizeMake((targetSize.height * originSize.width) / originSize.height, targetSize.height);
    }else {
        if (widthPercent > heightPercent) {
            retSize = CGSizeMake(targetSize.width, (originSize.height * targetSize.width) / originSize.width);
        }else {
            retSize = CGSizeMake((targetSize.height * originSize.width) / originSize.height, targetSize.height);
        }
    }
    return retSize;
}

@end
