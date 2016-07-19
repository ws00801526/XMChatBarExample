//
//  XMNChatStateView.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/27.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatStateView.h"

@interface XMNChatStateView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation XMNChatStateView

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [self setup];
}

- (void)layoutSubviews {
    
    self.imageView.frame = self.indicatorView.frame = self.bounds;
}

#pragma mark - Methods

- (void)setup {
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.imageView = [[UIImageView alloc] initWithImage:XMNCHAT_LOAD_IMAGE(@"message_send_failed")];
    self.imageView.contentMode = UIViewContentModeCenter;
    
    [self addSubview:self.indicatorView];
    [self addSubview:self.imageView];
}

#pragma mark - Setters

/**
 *  重写messageState setter
 *  根据对应的messageState显示不同的界面
 *  @param messageState 更改后的messageState
 */
- (void)setMessageState:(XMNMessageState)messageState {
    
    _messageState = messageState;
    self.hidden = NO;
    switch (messageState) {
        case XMNMessageStateFailed:
            self.indicatorView.hidden = YES;
            self.imageView.hidden = NO;
            [self.indicatorView stopAnimating];
            break;
        case XMNMessageStateSending:
        case XMNMessageStateRecieving:
            self.indicatorView.hidden = NO;
            self.imageView.hidden = YES;
            [self.indicatorView startAnimating];
            break;
        default:
            self.hidden = YES;
            break;
    }
    
}

@end
