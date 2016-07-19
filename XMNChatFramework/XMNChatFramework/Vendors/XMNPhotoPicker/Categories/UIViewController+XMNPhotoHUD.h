//
//  UIViewController+HUD.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/2/2.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (XMNPhotoHUD)

/**
 *  显示一个alert提示框
 *  只显示提示信息,和一个确定按钮
 *  @param title 具体提示的message
 */
- (void)showAlertWithMessage:(NSString *)message;

@end
