//
//  XMNChatCollectionCell.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/26.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChatConfiguration.h"

@interface XMNChatExpressionCollectionCell : UICollectionViewCell

@property (nonatomic, copy)   NSArray *emotions;
@property (nonatomic, assign) XMNChatExpressionType type;

@end
