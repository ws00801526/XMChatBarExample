//
//  UIImage+XMNResize.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/17.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XMNResize)

- (UIImage *)xmn_resizeImageToSize:(CGSize)targetSize;
- (UIImage *)xmn_fixImageOrientation;

@end
