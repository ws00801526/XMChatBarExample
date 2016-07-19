//
//  XMNAlbumCell.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMNAlbumModel;
@interface XMNAlbumCell : UITableViewCell


- (void)configCellWithItem:(XMNAlbumModel * _Nonnull)item;

@end
