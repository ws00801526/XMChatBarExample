//
//  XMNPhotoPicker.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/2/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMNAssetModel;
@interface XMNPhotoPickerSheet : UIView


/** 最大选择数量 默认0 不限制  使用sharePhotoPicker 则为9*/
@property (nonatomic, assign) NSUInteger maxCount;
/** 最大预览图数量 默认20 */
@property (nonatomic, assign) NSUInteger maxPreviewCount;

/**
 *  !!! 此属性修改为是否选择视频, 默认视频,图片不能同时选择
 *  默认为NO
 **/
@property (nonatomic, assign) BOOL pickingVideoEnable;

/** 拍照完成之后是否自动旋转  默认YES */
@property (nonatomic, assign) BOOL autoFixImageOrientation;


/** parentController,用来显示其他controller */
@property (nonatomic, weak, nullable)   UIViewController *parentController;

/** 用户选择完照片的回调 images<previewImage>  assets<PHAsset or ALAsset>*/
@property (nonatomic, copy, nullable)   void(^didFinishPickingPhotosBlock)(NSArray<UIImage *> * _Nullable images, NSArray<XMNAssetModel *>* _Nullable assets);

/** 用户选择完视频的回调 coverImage:视频的封面,asset 视频资源地址 */
@property (nonatomic, copy, nullable)   void(^didFinishPickingVideoBlock)(UIImage * _Nullable coverImage, XMNAssetModel * _Nullable asset);

/** 使用移动手势 发送图片时使用
 *
 *  asset           被发送的图片资源
 *  originView      显示图片的view 注意是UIView类型 要获取其imageView 可以通过 [originView viewWithTag:999];
 *  completedBlock  执行完didSendAsset后 需要执行的一个block
 */
@property (nonatomic, copy, nullable)   void(^didSendAsset)(XMNAssetModel * _Nonnull asset, UIView * _Nonnull originView, void(^ _Nonnull completedBlock)());

+ (instancetype _Nonnull )sharePhotoPicker ;
- (instancetype _Nullable )initWithMaxCount:(NSUInteger)maxCount;

- (void)showPhotoPickerwithController:(UIViewController * _Nonnull )controller animated:(BOOL)animated;

@end

