//
//  XMNAssetModel.h
//  XMNPhotoPickerFrameworkExample
//  资源相关的model
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    XMNAssetTypePhoto = 0,
    XMNAssetTypeLivePhoto,
    XMNAssetTypeVideo,
    XMNAssetTypeAudio,
} XMNAssetType;

@class AVPlayerItem;
@interface XMNAssetModel : NSObject

/** PHAsset or ALAsset */
@property (nonatomic, strong, readonly, nonnull) id asset;
/** asset  类型 */
@property (nonatomic, assign, readonly) XMNAssetType type;

/// ========================================
/// @name   图片相关信息
/// ========================================

/** 获取照片asset对应的原图 */
@property (nonatomic, strong, readonly, nullable) UIImage * originImage;
/** 获取照片asset对应的缩略图, 默认缩略图大小 80x80 */
@property (nonatomic, strong, readonly, getter=thumbnail, nullable) UIImage *thumbnail;
/** 获取照片asset的预览图,默认大小 [UIScreen mainScreen].bounds.size */
@property (nonatomic, strong, nullable) UIImage * previewImage;
/** 获取照片的方向 */
@property (nonatomic, assign, readonly) UIImageOrientation imageOrientation;
/** 图片的相关信息 */
@property (nonatomic, copy  , readonly, nullable)   NSString *filename;

/** 图片路径,视频路径 */
@property (nonatomic, copy  , readonly, nullable)   NSString *filepath;

/// ========================================
/// @name   视频,audio相关信息
/// ========================================

/** asset为Video时 video的时长 */
@property (nonatomic, copy,   readonly, nullable) NSString * timeLength;
/** 视频的播放item */
@property (nonatomic, strong, readonly, nullable) AVPlayerItem * playerItem;
/** 视频播放item的信息 */
@property (nonatomic, copy,   readonly, nullable) NSDictionary * playerItemInfo;

/** 是否被选中  默认NO */
@property (nonatomic, assign) BOOL selected;


#pragma mark - Methods


/// ========================================
/// @name   Class Methods
/// ========================================


/**
 *  根据asset,type获取XMNAssetModel实例
 *
 *  @param asset 具体的Asset类型 PHAsset or ALAsset
 *  @param type  asset类型
 *
 *  @return XMNAssetModel实例
 */
+ (XMNAssetModel  * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(XMNAssetType)type;

/**
 *  根据asset,type,timeLength获取XMNAssetModel实例
 *
 *  @param asset      asset 非空
 *  @param type       asset 类型
 *  @param timeLength video时长
 *
 *  @return XMNAssetModel实例
 */
+ ( XMNAssetModel * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(XMNAssetType)type timeLength:(NSString * _Nullable )timeLength;

@end
