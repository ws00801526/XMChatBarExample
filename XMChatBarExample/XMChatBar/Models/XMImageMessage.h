//
//  XMImageMessage.h
//  XMChatControllerExample
//
//  Created by shscce on 15/9/2.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMMessage.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface XMImageMessage : XMMessage

@property (assign, nonatomic) CGSize imageSize /**< 图片尺寸 默认CGSize(150,200)*/;
@property (strong, nonatomic) UIImage *image /**< 显示的图片 */;
@property (copy, nonatomic) NSString *imageUrlString /**< 需要显示的图片地址 */;

@end
