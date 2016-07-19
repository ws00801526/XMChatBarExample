//
//  XMNAssetModel.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAssetModel.h"

#import "XMNPhotoPickerDefines.h"
#import "XMNPhotoManager.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface XMNAssetModel ()


/** PHAsset or ALAsset */
@property (nonatomic, strong) _Nonnull id asset;
/** asset  类型 */
@property (nonatomic, assign) XMNAssetType type;

/// ========================================
/// @name   视频,audio相关信息
/// ========================================

/** asset为Video时 video的时长 */
@property (nonatomic, copy) NSString *timeLength;


@end

@implementation XMNAssetModel
@synthesize originImage = _originImage;
@synthesize thumbnail = _thumbnail;
@synthesize previewImage = _previewImage;
@synthesize imageOrientation = _imageOrientation;
@synthesize playerItem = _playerItem;
@synthesize playerItemInfo = _playerItemInfo;
@synthesize filename = _filename;
@synthesize filepath = _filepath;

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
+ ( XMNAssetModel  * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(XMNAssetType)type {
    return [self modelWithAsset:asset type:type timeLength:@""];
}

/**
 *  根据asset,type,timeLength获取XMNAssetModel实例
 *
 *  @param asset      asset 非空
 *  @param type       asset 类型
 *  @param timeLength video时长
 *
 *  @return XMNAssetModel实例
 */
+ ( XMNAssetModel * _Nonnull )modelWithAsset:(_Nonnull id)asset type:(XMNAssetType)type timeLength:(NSString * _Nullable )timeLength {
    XMNAssetModel *model = [[XMNAssetModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.timeLength = timeLength;
    return model;
}

#pragma mark - Getters

- (UIImage *)originImage {
    if (_originImage) {
        return _originImage;
    }
    __block UIImage *resultImage;
    [[XMNPhotoManager sharedManager] getOriginImageWithAsset:self.asset completionBlock:^(UIImage *image){
        resultImage = image;
    }];
    _originImage = resultImage;
    return resultImage;
}

- (UIImage *)thumbnail {
    if (_thumbnail) {
        return _thumbnail;
    }
    __block UIImage *resultImage;
    [[XMNPhotoManager sharedManager] getThumbnailWithAsset:self.asset size:kXMNThumbnailSize completionBlock:^(UIImage *image){
        resultImage = image;
    }];
    _thumbnail = resultImage;
    return _thumbnail;
}

- (UIImage *)previewImage {
    
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    [[XMNPhotoManager sharedManager] getPreviewImageWithAsset:self.asset completionBlock:^(UIImage *image) {
        resultImage = image;
    }];
    _previewImage = resultImage;
    return _previewImage;
}

- (UIImageOrientation)imageOrientation {
    if (_imageOrientation) {
        return _imageOrientation;
    }
    __block UIImageOrientation resultOrientation;
    [[XMNPhotoManager sharedManager] getImageOrientationWithAsset:self.asset completionBlock:^(UIImageOrientation imageOrientation) {
        resultOrientation = imageOrientation;
    }];
    _imageOrientation = resultOrientation;
    return _imageOrientation;
}

- (AVPlayerItem *)playerItem {
    
    if (_playerItem) {
        return _playerItem;
    }
    __block AVPlayerItem *resultItem;
    __block NSDictionary *resultItemInfo;
    [[XMNPhotoManager sharedManager] getVideoInfoWithAsset:self.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playerItemInfo) {
        resultItem = playerItem;
        resultItemInfo = [playerItemInfo copy];
    }];
    _playerItem = resultItem;
    _playerItemInfo = resultItemInfo ? : _playerItemInfo;
    return _playerItem;
}


- (NSDictionary *)playerItemInfo {
    
    if (_playerItemInfo) {
        return _playerItemInfo;
    }
    __block AVPlayerItem *resultItem;
    __block NSDictionary *resultItemInfo;
    [[XMNPhotoManager sharedManager] getVideoInfoWithAsset:self.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playerItemInfo) {
        resultItem = playerItem;
        resultItemInfo = [playerItemInfo copy];
    }];
    _playerItem = resultItem ? : _playerItem;
    _playerItemInfo = resultItemInfo;
    return _playerItemInfo;
}

- (NSString *)filepath{
    
    if (!_filepath) {
        
        __block NSString *resultFilePath;
        [[XMNPhotoManager sharedManager] getAssetPathWithAsset:self.asset completionBlock:^(NSString * _Nullable info) {
            resultFilePath = [info copy];
        }];
        _filepath = [resultFilePath copy];
    }
    return _filepath;
}

- (NSString *)filename {
    
    if (!_filename) {
        __block NSString *resultFilePath;
        if (self.filepath) {
            resultFilePath = [self.filepath lastPathComponent];
        }else {
            [[XMNPhotoManager sharedManager] getAssetPathWithAsset:self.asset completionBlock:^(NSString * _Nullable info) {
                resultFilePath = [info copy];
            }];
        }
        _filename = [self.filepath lastPathComponent];
    }
    return _filename;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n-------XMNAssetModel Desc Start-------\ntype : %d\nsuper :%@\n-------XMNAssetModel Desc End-------",(int)self.type,[super description]];
}
@end
