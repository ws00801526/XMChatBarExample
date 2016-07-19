//
//  XMNPhotoPickerOption.h
//  XMNPhotoPicker
//
//  Created by XMFraker on 16/7/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMNPhotoPickerOption : NSObject

/**
 *  @brief 是否允许XMNPhotoPickerSheet 拖动图片发送
 *  默认 YES
 *  @return
 */
+ (BOOL)isPanGestureEnabled;
/**
 *  @brief 设置是否允许XMNPhotoPickerSheet拖动图片发送
 *
 *  @param enabled YES or NO
 */
+ (void)setPanGestureEnabled:(BOOL)enabled;

/**
 *  @brief 预览图片,视频时间距
 *  默认  16.f
 *  @return
 */
+ (NSInteger)previewPadding;
/**
 *  @brief 设置预览图片,视频时间距
 *
 *  @param previewPadding
 */
+ (void)setPreviewPadding:(CGFloat)previewPadding;

/**
 *  @brief 拖动图片发送时 图片动画时间
 *  默认.3f
 *  @return
 */
+ (CGFloat)sendingPictureAnimationDuration;

/**
 *  @brief 设置拖动图片发送时动画时间
 *
 *  @param duration
 */
+ (void)setSendingPictureAnimationDuration:(CGFloat)duration;

/**
 *  @brief 发送图片时,显示图片的imageView tag
 *  默认 999
 *  @return
 */
+ (NSInteger)sendingImageViewTag;
/**
 *  @brief 设置发送图片时,显示图片的imageView Tag
 *
 *  @param tag
 */
+ (void)setSendingImageViewTag:(NSInteger)tag;

/**
 *  @brief 资源文件所在的bundle
 *  默认   直接拖入工程引用返回[NSBundle mainBundle] 作为framework引用返回[NSBundle bundleWithIdentifier:@"com.XMFraker.XMNPhotoPicker"]
 *  @return
 */
+ (NSBundle * _Nonnull)resourceBundle;

/**
 *  @brief 设置资源文件所在的bundle
 *
 *  @param bundle
 */
+ (void)setResourceBundle:(NSBundle * _Nonnull)bundle;


/**
 *  根据给定宽度 获取UICollectionViewLayout 实例
 *
 *  @param width collectionView 宽度
 *
 *  @return UICollectionViewLayout实例
 */
+ (UICollectionViewLayout * _Nonnull)photoCollectionViewLayoutWithWidth:(CGFloat)width;

@end
