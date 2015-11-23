//
//  UITableViewCell+XMNCellIdentifier.h
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChatMessageCell.h"

@interface XMNChatMessageCell (XMNCellIdentifier)

/**
 *  用来获取cellIdentifier
 *
 *  @param messageConfiguration 消息类型,需要传入两个key
 *  kXMNMessageConfigurationTypeKey     代表消息的类型
 *  kXMNMessageConfigurationOwnerKey    代表消息的所有者
 */
+ (NSString *)cellIdentifierForMessageConfiguration:(NSDictionary *)messageConfiguration;


@end
