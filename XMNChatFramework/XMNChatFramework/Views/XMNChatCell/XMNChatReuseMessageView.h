//
//  XMNChatReuseMessageView.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMNChatConfiguration.h"

@class XMNChatBaseMessage;
@interface XMNChatReuseMessageView : UIView

@property (nonatomic, assign) CGSize contentSize;

/**
 *  配置messageView
 *
 *  @param aMessage 消息
 */
- (void)setupViewWithMessage:(XMNChatBaseMessage *)aMessage;

/**
 *  @brief 根据message.state,substate 更改UI状态
 *
 *  @param aMessage 消息
 */
- (void)updateUIWithMessage:(XMNChatBaseMessage *)aMessage;

+ (XMNChatReuseMessageView *)messageViewWithMessageType:(XMNMessageType)messageType;

@end
