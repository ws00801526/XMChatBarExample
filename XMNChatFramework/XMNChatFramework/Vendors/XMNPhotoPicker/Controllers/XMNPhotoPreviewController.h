//
//  XMNPhotoPreviewController.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMNAssetModel;
@interface XMNPhotoPreviewController : UICollectionViewController

/** 所有的图片资源 */
@property (nonatomic, copy)   NSArray<XMNAssetModel *> *assets;
/** 选择的图片资源 */
@property (nonatomic, strong) NSMutableArray<XMNAssetModel *> *selectedAssets;

/** 当用户更改了选择的图片,点击返回时,回调此block */
@property (nonatomic, copy)   void(^didFinishPreviewBlock)( NSArray<XMNAssetModel *> *selectedAssets);

/** 用户点击底部bottom按钮后 回调 */
@property (nonatomic, copy)   void (^didFinishPickingBlock)(NSArray<UIImage *> *images ,NSArray<XMNAssetModel *> *assets);


/** 当前显示的asset index */
@property (nonatomic, assign) NSUInteger currentIndex;
/** 最大选择数量 */
@property (nonatomic, assign) NSUInteger maxCount;


+ (UICollectionViewLayout *)photoPreviewViewLayoutWithSize:(CGSize)size;

@end
