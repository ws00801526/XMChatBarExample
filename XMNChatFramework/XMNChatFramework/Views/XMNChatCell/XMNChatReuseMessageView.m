//
//  XMNChatReuseMessageView.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatReuseMessageView.h"

@implementation XMNChatReuseMessageView

#pragma mark - Override Methods

- (CGSize)intrinsicContentSize {
    
    return self.contentSize;
}

#pragma mark - Methods

/**
 *  配置messageView
 *
 *  @param aMessage 消息
 */
- (void)setupViewWithMessage:(XMNChatBaseMessage *)aMessage {
    
}

/**
 *  @brief 根据message.state,substate 更改UI状态
 *
 *  @param aMessage 消息
 */
- (void)updateUIWithMessage:(XMNChatBaseMessage *)aMessage {
    
}


#pragma mark - Class Methods

+ (XMNChatReuseMessageView *)messageViewWithMessageType:(XMNMessageType)messageType {
    
    return [[kXMNChatBundle loadNibNamed:[self messageViewIdentifierForMessageType:messageType] owner:nil options:nil] lastObject];
}

+ (NSString *)messageViewIdentifierForMessageType:(XMNMessageType)messageType {
    
    switch (messageType) {
        case XMNMessageTypeImage:
            return @"XMNChatImageMessageView";
            break;
        case XMNMessageTypeText:
            return @"XMNChatTextMessageView";
        case XMNMessageTypeVoice:
            return @"XMNChatVoiceMessageView";
        default:
            return @"XMNChatUnknownMessageView";
            break;
    }
}

#pragma mark - Setters

- (void)setContentSize:(CGSize)contentSize {
    
    _contentSize = contentSize;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
