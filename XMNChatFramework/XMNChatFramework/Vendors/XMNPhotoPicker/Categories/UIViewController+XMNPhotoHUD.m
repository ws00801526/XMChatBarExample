//
//  UIViewController+HUD.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/2/2.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "UIViewController+XMNPhotoHUD.h"

#import "XMNPhotoPickerDefines.h"


@implementation UIViewController (XMNPhotoHUD)

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"


/**
 *  显示一个alert提示框
 *  只显示提示信息,和一个确定按钮
 *  @param title 具体提示的message
 */
- (void)showAlertWithMessage:(NSString *)message {
    

    
    if (iOS8Later) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:action];
        [self showDetailViewController:alertC sender:self];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}




#pragma clang diagnostic pop

@end
