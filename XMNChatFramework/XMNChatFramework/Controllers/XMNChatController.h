//
//  XMNChatController.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChatViewModel.h"
#import "XMNChatConfiguration.h"

@class XMNChatBaseMessage;
@interface XMNChatController : UIViewController

@property (nonatomic, strong) XMNChatViewModel<UITableViewDataSource> *chatVM;
@property (nonatomic, assign, readonly) XMNChatMode chatMode;


- (instancetype)initWithChatMode:(XMNChatMode)aChatMode;

/**
 *  @brief 发送一个消息
 *
 *  @param aMessage 发送的消息内容
 */
- (void)sendMessage:(XMNChatBaseMessage *)aMessage;

- (void)scrollBottom:(BOOL)animated;
@end
