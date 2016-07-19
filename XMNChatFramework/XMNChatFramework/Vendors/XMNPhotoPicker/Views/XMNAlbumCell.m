//
//  XMNAlbumCell.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAlbumCell.h"

#import "XMNAlbumModel.h"
#import "XMNPhotoManager.h"
#import "XMNPhotoPickerDefines.h"


@interface XMNAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation XMNAlbumCell


#pragma mark - Override Methods

- (void)awakeFromNib {
    
    self.albumCoverImageView.layer.masksToBounds = YES;
}


#pragma mark - Methods

- (void)configCellWithItem:(XMNAlbumModel * _Nonnull)item {
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:item.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",item.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    
    __weak typeof(*&self) wSelf = self;

    
#if defined(iOS8Later)
    [[XMNPhotoManager sharedManager] getThumbnailWithAsset:[item.fetchResult lastObject] size:kXMNThumbnailSize completionBlock:^(UIImage *image) {
        __weak typeof(*&self) self = wSelf;
        self.albumCoverImageView.image = image;
    }];
#else
    ALAssetsGroup *assets = (ALAssetsGroup *)item.fetchResult;
    
    [assets enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            NSLog(@"this is last object :%@",result);
            [[XMNPhotoManager sharedManager] getThumbnailWithAsset:result size:kXMNThumbnailSize completionBlock:^(UIImage *image) {
                __weak typeof(*&self) self = wSelf;
                self.albumCoverImageView.image = image;
            }];
            *stop =  YES;
        }
    }];
#endif
}

@end
