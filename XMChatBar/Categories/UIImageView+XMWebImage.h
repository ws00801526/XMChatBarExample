//
//  UIImageView+XMWebImage.h
//  XMChatBarExample
//
//  Created by shscce on 15/9/14.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  很简单的直接设置网络图片,需要用户自己去替换成SDWebImage类库 或者其他的相似类库
 *
 *  11.20 -> 更新 增加了简单的本地文件缓存 -> 还是推荐用SD其他成熟的第三方类库
 */
@interface UIImageView (XMWebImage)

- (void)setImageWithUrlString:(NSString *)urlString;

@end
