//
//  UIView+Animations.h
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XMNAnimationType) {
    XMNAnimationTypeBigger,
    XMNAnimationTypeSmaller,
};

@interface UIView (Animations)

+ (void)animationWithLayer:(CALayer *)layer type:(XMNAnimationType)type;

+ (CABasicAnimation *)animationWithFromValue:(id)fromValue toValue:(id)toValue duration:(CGFloat)duration forKeypath:(NSString *)keypath;

@end
