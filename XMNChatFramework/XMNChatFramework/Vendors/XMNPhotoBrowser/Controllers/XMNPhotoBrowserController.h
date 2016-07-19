//
//  XMNPhotoBrowserController.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMNPhotoBrowserCell.h"

UIKIT_EXTERN CGFloat kXMNPhotoBrowserCellPadding;


@class XMNPhotoModel;
/**
 *  图片浏览器
 *  @code
 *  
 *   // 构造photos 数组
    NSMutableArray *photos = [NSMutableArray array];
    for (<#type *object#> in <#collection#>) {
        // 构造XMNPhotoModel 实例
        XMNPhotoModel *model = [[XMNPhotoModel alloc] initWithImagePath:@"your photo url"
        thumbnail:[YYImage imageNamed:@"your thumb nail image name"]];
        [photos addObject:model];
    }
 
    // 够着XMNPhotoBrowserController 实例
    XMNPhotoBrowserController *browserC = [[XMNPhotoBrowserController alloc] initWithPhotos:photos];
    // 设置第一张预览图片位置  默认0
    browserC.currentItemIndex = indexPath.row;
    // 设置 预览的sourceView
    //    browserC.sourceView = [[collectionView cellForItemAtIndexPath:indexPath] valueForKey:@"photoImageView"];
    // 使用presentVC方式 弹出
    [self presentViewController:browserC animated:YES completion:nil];
 */
@interface XMNPhotoBrowserController : UICollectionViewController

/** 保存XMNPhotoModel 的数组 */
@property (nonatomic, copy, readonly, nullable)   NSArray<XMNPhotoModel *> *photos;

/** 当前预览的图片 index */
@property (nonatomic, assign) NSInteger currentItemIndex;

/** 第一个预览的图片 index */
@property (nonatomic, assign, readonly) NSInteger firstBrowserItemIndex;

/** 预览的sourceView 推荐传入UIImageView
 *
 *  如果不传 此参数, 放大效果 会从中间方法
 *  如果传 此参数    放大效果 ,会从sourceImageView 放大到全屏
 */
@property (nonatomic, weak, nullable) UIView *sourceView;

/** 加载图片时的 加载进度条类型 */
@property (nonatomic, assign) XMNPhotoBrowserLoadingMode loadingMode;


#pragma mark - Life Cycle

/**
 *  初始化一个XMNPhotoBrowserController实例
 *
 *  @param photos 图片数组
 *
 *  @return
 */
- (_Nullable instancetype)initWithPhotos:(NSArray <XMNPhotoModel *> * _Nonnull)photos;

@end
