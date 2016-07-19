//
//  XMNChatSystemCell.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/6/21.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMNChatBaseMessage;
@interface XMNChatSystemCell : UITableViewCell

- (void)configCellWithMessage:(XMNChatBaseMessage *)aMessage;

@end
