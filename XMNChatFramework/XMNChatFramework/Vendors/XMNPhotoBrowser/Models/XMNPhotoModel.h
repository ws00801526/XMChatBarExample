//
//  XMNPhotoModel.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface XMNPhotoModel : NSObject

/** 图片地址 */
@property (nonatomic, copy, nullable)   NSString *imagePath;

/** 高清图片 */
@property (nonatomic, strong, readonly, nullable) UIImage *image;

/** 预览图 UIImage
 *  不设置 返回一个黑色的纯色图片 大小默认(屏幕宽度x400 or self.imageSize)*/
@property (nonatomic, strong, nullable) UIImage *thumbnail;

/** 图片的大小 默认大小 屏幕宽度x400 */
@property (nonatomic, assign) CGSize imageSize;


/**
 *  够着一个XMNPhotoModel实例
 *
 *  @param imagePath 图片的路径
 *  @param thumnail  预览图
 *
 *  @return XMNPhotoModel 实例
 */
- (_Nonnull instancetype)initWithImagePath:(NSString * _Nonnull )imagePath
                                 thumbnail:(UIImage * _Nullable )thumnail;


+ (CGSize)adjustOriginSize:(CGSize)originSize
              toTargetSize:(CGSize)targetSize;

@end
