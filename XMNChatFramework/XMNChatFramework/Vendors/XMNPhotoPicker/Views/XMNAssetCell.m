//
//  XMNAssetCell.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAssetCell.h"

#import "XMNAssetModel.h"
#import "XMNPhotoManager.h"

#import "UIView+Animations.h"

@interface XMNAssetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;

@end

@implementation XMNAssetCell
@synthesize asset = _asset;

#pragma mark - Methods

/// ========================================
/// @name   Public Methods
/// ========================================

/**
 *  XMNPhotoCollectionController 中配置collectionView的cell
 *
 *  @param item 具体的AssetModel
 */
- (void)configCellWithItem:(XMNAssetModel * _Nonnull )item {
    
    _asset = item;
    switch (item.type) {
        case XMNAssetTypeVideo:
        case XMNAssetTypeAudio:
            self.videoView.hidden = NO;
            self.videoTimeLabel.text = item.timeLength;
            break;
        case XMNAssetTypeLivePhoto:
        case XMNAssetTypePhoto:
            self.videoView.hidden = YES;
            break;
    }
    self.photoStateButton.selected = item.selected;
    self.photoImageView.image = item.thumbnail;
}

/// ========================================
/// @name   Private Methods
/// ========================================

/**
 *  处理stateButton的点击动作
 *
 *  @param sender button
 */
- (IBAction)_handleButtonAction:(UIButton *)sender {
    BOOL originState = sender.selected;
    self.photoStateButton.selected = self.willChangeSelectedStateBlock ? self.willChangeSelectedStateBlock(self.asset) : NO;
    if (self.photoStateButton.selected) {
        [UIView animationWithLayer:self.photoStateButton.layer type:XMNAnimationTypeBigger];
    }
    if (originState != self.photoStateButton.selected) {
        self.didChangeSelectedStateBlock ? self.didChangeSelectedStateBlock(self.photoStateButton.selected, self.asset) : nil;
    }
}

@end
