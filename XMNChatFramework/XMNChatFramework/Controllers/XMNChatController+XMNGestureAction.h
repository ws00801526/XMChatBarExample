//
//  XMNChatController+XMNMenu.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <XMNChat/XMNChat.h>

@interface XMNChatController (XMNMenu)

/**
 *  @brief 给tableView添加tap,doubletap,longpress手势操作
 */
- (void)setupGestures;
/**
 *  @brief 设置弹出框按钮的菜单
 */
- (void)setupMenuItems;

@end
