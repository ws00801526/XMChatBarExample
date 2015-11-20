//
//  XMNContentView.m
//  XMNChatExample
//
//  Created by shscce on 15/11/13.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNContentView.h"

@implementation XMNContentView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskView.frame = CGRectInset(self.bounds, 0, 0);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    self.layer.mask.frame = CGRectInset(self.bounds, 0, 0);
    self.layer.mask.cornerRadius = 5.0f;
}

@end
