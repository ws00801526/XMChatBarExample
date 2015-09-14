//
//  UIImageView+XMWebImage.m
//  XMChatBarExample
//
//  Created by shscce on 15/9/14.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "UIImageView+XMWebImage.h"

@implementation UIImageView (XMWebImage)

- (void)setImageWithUrlString:(NSString *)urlString{
    if (!urlString) {
        return;
    }
    dispatch_async(dispatch_queue_create("pic", nil), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = [UIImage imageWithData:data];
        });
    });
}

@end
