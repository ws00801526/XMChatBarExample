//
//  XMNPhotoBrowser.h
//  XMNPhotoBrowser
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XMNPhotoBrowser.
FOUNDATION_EXPORT double XMNPhotoBrowserVersionNumber;

//! Project version string for XMNPhotoBrowser.
FOUNDATION_EXPORT const unsigned char XMNPhotoBrowserVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XMNPhotoBrowser/PublicHeader.h>


#if __has_include(<XMNPhotoBrowser/XMNPhotoBrowser.h>)

#import <XMNPhotoBrowser/YYWebImage.h>

#import <XMNPhotoBrowser/XMNPhotoModel.h>

#import <XMNPhotoBrowser/XMNPhotoBrowserCell.h>
#import <XMNPhotoBrowser/XMNPhotoProgressView.h>

#import <XMNPhotoBrowser/XMNPhotoBrowserController.h>

#else

#import "YYWebImage.h"

#import "XMNPhotoModel.h"

#import "XMNPhotoBrowserCell.h"
#import "XMNPhotoProgressView.h"

#import "XMNPhotoBrowserController.h"

#endif