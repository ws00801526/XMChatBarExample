//
//  XMNVideoPreviewController.h
//  XMNPhotoPickerFrameworkExample
//  视频预览的Controller
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//
//  使用AVPlayer 播放选择的视频

#import <UIKit/UIKit.h>

@class XMNAssetModel;
@interface XMNVideoPreviewController : UIViewController

/** 是否可以选择视频 默认视频,照片不能同时选择(如果已经选择照片了,则不能选择视频) */
@property (nonatomic, assign) BOOL selectedVideoEnable;
/** 资源model */
@property (nonatomic, strong) XMNAssetModel *asset;

/** 点击底部bottomBar 确认按钮后回调 */
@property (nonatomic, copy)   void(^didFinishPickingVideo)(UIImage *coverImage, XMNAssetModel *asset);

/** 当用户点击返回后 回调 */
@property (nonatomic, copy)   void(^didFinishPreviewBlock)();

@end
