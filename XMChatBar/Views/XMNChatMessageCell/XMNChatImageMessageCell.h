//
//  XMNChatImageMessageCell.h
//  XMNChatExample
//
//  Created by shscce on 15/11/16.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatMessageCell.h"

@interface XMNChatImageMessageCell : XMNChatMessageCell

- (void)imageProgressAnimationWithBlock:(void(^)(UIView *progressView, UILabel *progressLabel))uploadBlock;

@end
