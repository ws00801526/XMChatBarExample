//
//  XMNPhotoPickerOption.m
//  XMNPhotoPicker
//
//  Created by XMFraker on 16/7/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"

static CGFloat gPadding = 16.f;
static BOOL   gPanGestureEnabled = YES;
static CGFloat gDuration = .3f;
static NSUInteger  gImageViewTag = 999;
static NSBundle *gBundle;

@implementation XMNPhotoPickerOption

+ (void)initialize {
    
#if __has_include(<XMNPhotoPicker/XMNPhotoPicker.h>)
    gBundle = [NSBundle bundleWithIdentifier:@"com.XMFraker.XMNPhotoPicker"];
#else
    gBundle = [NSBundle mainBundle];
#endif
}

/**
 *  @brief 是否允许XMNPhotoPickerSheet 拖动图片发送
 *  默认 YES
 *  @return
 */
+ (BOOL)isPanGestureEnabled {
    
    return gPanGestureEnabled;
}

/**
 *  @brief 设置是否允许XMNPhotoPickerSheet拖动图片发送
 *
 *  @param enabled YES or NO
 */
+ (void)setPanGestureEnabled:(BOOL)enabled {
    
    gPanGestureEnabled = enabled;
}

/**
 *  @brief 预览图片,视频时间距
 *  默认  16.f
 *  @return
 */
+ (NSInteger)previewPadding {
    
    return gPadding;
}
/**
 *  @brief 设置预览图片,视频时间距
 *
 *  @param previewPadding
 */
+ (void)setPreviewPadding:(CGFloat)previewPadding {
    
    gPadding = previewPadding;
}

/**
 *  @brief 拖动图片发送时 图片动画时间
 *  默认.3f
 *  @return
 */
+ (CGFloat)sendingPictureAnimationDuration {
    
    return gDuration;
}

/**
 *  @brief 设置拖动图片发送时动画时间
 *
 *  @param duration
 */
+ (void)setSendingPictureAnimationDuration:(CGFloat)duration {
    
    gDuration = gDuration;
}

/**
 *  @brief 发送图片时,显示图片的imageView tag
 *  默认 999
 *  @return
 */
+ (NSInteger)sendingImageViewTag {
    
    return gImageViewTag;
}

/**
 *  @brief 设置发送图片时,显示图片的imageView Tag
 *
 *  @param tag
 */
+ (void)setSendingImageViewTag:(NSInteger)tag {
    
    gImageViewTag = tag;
}

/**
 *  @brief 资源文件所在的bundle
 *  默认   直接拖入工程引用返回[NSBundle mainBundle] 作为framework引用返回[NSBundle bundleWithIdentifier:@"com.XMFraker.XMNPhotoPicker"]
 *  @return
 */
+ (NSBundle * _Nonnull)resourceBundle {
    
    return gBundle;
}

/**
 *  @brief 设置资源文件所在的bundle
 *
 *  @param bundle
 */
+ (void)setResourceBundle:(NSBundle * _Nonnull)bundle {
    
    if (bundle) {
        gBundle = bundle;
    }
}


+ (UICollectionViewLayout *)photoCollectionViewLayoutWithWidth:(CGFloat)width {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = kXMNMargin;
    layout.itemSize = kXMNThumbnailSize;
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    return layout;
}
@end


