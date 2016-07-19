//
//  XMNBottomToolBar.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNBottomBar.h"

#import "XMNAssetModel.h"
#import "XMNPhotoManager.h"
#import "XMNPhotoPickerOption.h"

#import "UIView+Animations.h"

@interface XMNBottomBar ()

@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIView *originView;
@property (weak, nonatomic) IBOutlet UIImageView *originStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *originSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIImageView *numberImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (nonatomic, assign) BOOL selectOriginEnable;


@end

@implementation XMNBottomBar
@synthesize barType = _barType;
@synthesize selectOriginEnable = _selectOriginEnable;
@synthesize totalSize = _totalSize;

#pragma mark - Life Cycle

- (instancetype)initWithBarType:(XMNBottomBarType)barType {
    
    XMNBottomBar *bottomBar = [[[XMNPhotoPickerOption resourceBundle] loadNibNamed:@"XMNBottomBar" owner:nil options:nil] firstObject];
    bottomBar ? [bottomBar _setupWithType:barType] : nil;
    return bottomBar;
}


#pragma mark - Methods

- (void)updateBottomBarWithAssets:(NSArray *)assets {
    
    _totalSize = .0f;
    
    if (!assets || assets.count == 0) {
        self.originStateImageView.highlighted = NO;
        self.originSizeLabel.textColor = [UIColor lightGrayColor];
        self.originSizeLabel.text = @"原图";
    }else {
        self.originStateImageView.highlighted = self.selectOriginEnable;
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)assets.count];
    
    self.numberImageView.hidden = self.numberLabel.hidden = assets.count <= 0;
    self.confirmButton.enabled = assets.count >= 1;
    
    self.previewButton.enabled = assets.count >= 1;
    self.originView.userInteractionEnabled = assets.count >= 1;
    
    [UIView animationWithLayer:self.numberImageView.layer type:XMNAnimationTypeSmaller];
    
    __weak typeof(*&self) wSelf = self;
    [assets enumerateObjectsUsingBlock:^(XMNAssetModel  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[XMNPhotoManager sharedManager] getAssetSizeWithAsset:obj.asset completionBlock:^(CGFloat size) {
            __weak typeof(*&self) self = wSelf;
            _totalSize += size;
            if (idx == assets.count - 1) {
                [self _updateSizeLabel];
                *stop = YES;
            }
        }];
    }];
    
}

- (void)_setupWithType:(XMNBottomBarType)barType {
    _barType = barType;
    _selectOriginEnable = YES;
    
    self.lineView.hidden = barType == XMNPreviewBottomBar;
    self.backgroundColor = barType == XMNPreviewBottomBar ? [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:.7f] : [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0 alpha:1.0f];
    self.lineView.backgroundColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.f];
    
    //config previewButton
    self.previewButton.hidden = barType == XMNPreviewBottomBar;
    self.previewButton.hidden = YES;
    self.previewButton.enabled = NO;
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton setTitle:@"预览" forState:UIControlStateDisabled];
    [self.previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    //config originView
    self.originView.hidden = YES;
    self.originView.userInteractionEnabled = NO;
    self.originView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *originViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleOriginViewTap)];
    [self.originView addGestureRecognizer:originViewTap];
    
    self.originStateImageView.highlighted = NO;
    [self.originStateImageView setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"bottom_bar_origin_normal@2x" ofType:@"png"]]];
    [self.originStateImageView setHighlightedImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"bottom_bar_origin_selected@2x" ofType:@"png"]]];
    
    self.originSizeLabel.text = @"原图";
    self.originSizeLabel.textColor = [UIColor lightGrayColor];
    
    //config number
    self.numberImageView.hidden = self.numberLabel.hidden = YES;
    [self.numberImageView setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"bottom_bar_number_background@2x" ofType:@"png"]]];

    self.numberLabel.textColor = [UIColor whiteColor];
    
    //config confirmButton
    self.confirmButton.enabled = NO;
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateDisabled];
    [self.confirmButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0f] forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:.5f] forState:UIControlStateDisabled];
    [self.confirmButton addTarget:self action:@selector(_handleConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)_handleConfirmAction {
    self.confirmBlock ? self.confirmBlock() : nil;
}

- (void)_handleOriginViewTap {
    self.selectOriginEnable = !self.selectOriginEnable;
    self.originStateImageView.highlighted = self.selectOriginEnable;
    [self _updateSizeLabel];
}

- (void)_updateSizeLabel {
    if (self.selectOriginEnable) {
        self.originSizeLabel.text = [NSString stringWithFormat:@"原图 (%@)",[self _bytesStringFromDataLength:self.totalSize]];
        self.originSizeLabel.textColor = self.barType == XMNCollectionBottomBar ? [UIColor blackColor] : [UIColor whiteColor];
    }else {
        self.originSizeLabel.text = @"原图";
        self.originSizeLabel.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Getters

- (NSString *)_bytesStringFromDataLength:(CGFloat)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else if (dataLength == .0f){
        bytes = @"";
    }else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}


@end
