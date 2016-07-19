//
//  XMNPhotoBrowserCell.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>


/** 加载图片的显示方式 */
typedef NS_ENUM(NSUInteger, XMNPhotoBrowserLoadingMode) {
    
    /** 显示转圈动画 */
    XMNPhotoBrowserLoadingCircle = 0,
    /** 显示加载进度 */
    XMNPhotoBrowserLoadingProgress,
};

@class XMNPhotoModel;
@class YYAnimatedImageView;
@interface XMNPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong, readonly, nonnull) YYAnimatedImageView *imageView;

@property (nonatomic, copy, nullable)   void(^singleTapBlock)(XMNPhotoBrowserCell __weak  * _Nullable  browserCell);

@property (nonatomic, assign) XMNPhotoBrowserLoadingMode loadingMode;


- (void)configCellWithItem:(XMNPhotoModel * _Nonnull )item;
- (void)cancelImageRequest;
@end
