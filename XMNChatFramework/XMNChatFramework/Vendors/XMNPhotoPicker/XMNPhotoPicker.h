//
//  XMNPhotoPicker.h
//  XMNPhotoPicker
//
//  Created by XMFraker on 16/7/19.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XMNPhotoPicker.
FOUNDATION_EXPORT double XMNPhotoPickerVersionNumber;

//! Project version string for XMNPhotoPicker.
FOUNDATION_EXPORT const unsigned char XMNPhotoPickerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XMNPhotoPicker/PublicHeader.h>

#if __has_include(<XMNPhotoPicker/XMNPhotoPicker.h>)

    #import <XMNPhotoPicker/XMNAssetModel.h>
    #import <XMNPhotoPicker/XMNPhotoManager.h>
    #import <XMNPhotoPicker/XMNPhotoPickerSheet.h>
    #import <XMNPhotoPicker/XMNPhotoPickerController.h>
    #import <XMNPhotoPicker/XMNPhotoPickerOption.h>
#else

    #import "XMNPhotoPickerOption.h"
    #import "XMNAssetModel.h"
    #import "XMNPhotoManager.h"
    #import "XMNPhotoPickerSheet.h"
    #import "XMNPhotoPickerController.h"
#endif
