//
//  XMNChatImageMessageView.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatImageMessageView.h"
#import "YYWebImage.h"
#import "XMNChatMessage.h"

@interface XMNChatImageMessageView ()

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imageView;

@end

@implementation XMNChatImageMessageView

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}

#pragma mark - Methods

- (void)setupViewWithMessage:(XMNChatImageMessage *)aMessage {
    
    if (aMessage.image) {
        self.imageView.image = aMessage.image;
        self.contentSize = CGSizeMake(MIN(aMessage.imageSize.width, kXMNMessageViewMaxWidth), ((MIN(aMessage.imageSize.width, kXMNMessageViewMaxWidth) * aMessage.imageSize.height) / aMessage.imageSize.width));
    }else if (aMessage.imagePath) {
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:aMessage.imagePath] placeholder:[UIImage yy_imageWithColor:[UIColor clearColor] size:aMessage.imageSize] options:YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        self.contentSize = CGSizeMake(MIN(aMessage.imageSize.width, kXMNMessageViewMaxWidth), ((MIN(aMessage.imageSize.width, kXMNMessageViewMaxWidth) * aMessage.imageSize.height) / aMessage.imageSize.width));
    }else {
        XMNLog(@"unknown image type");
        self.contentSize = CGSizeMake(100, 100);
    }
}
@end
