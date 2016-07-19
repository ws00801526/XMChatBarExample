//
//  XMNPhotoCollectionController.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>


@class XMNAlbumModel;
@interface XMNPhotoCollectionController : UICollectionViewController

/** 具体的相册 */
@property (nonatomic, strong) XMNAlbumModel *album;

@end
