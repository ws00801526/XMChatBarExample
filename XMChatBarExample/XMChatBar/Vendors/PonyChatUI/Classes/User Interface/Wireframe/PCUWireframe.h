//
//  PCUWireframe.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PCUMessageManager;

@protocol PCUDelegate;

@interface PCUWireframe : NSObject

- (UIView *)addMainViewToViewController:(UIViewController<PCUDelegate> *)viewController
                     withMessageManager:(PCUMessageManager *)messageManager;

@end
