//
//  XMNChatOtherCell.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/27.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatOtherCell.h"
#import "XMNChatStateView.h"
#import "XMNChatReuseMessageView.h"
#import "XMNChatMessage.h"
#import "FBKVOController.h"

#import "UIImageView+YYWebImage.h"

@interface XMNChatOtherCell ()

@property (copy, nonatomic)   NSArray<NSLayoutConstraint *> *messageViewConstraints;

@end

@implementation XMNChatOtherCell
@synthesize messageViewConstraints = _messageViewConstraints;

#pragma mark - Override Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.backgroundImageView setImage:[XMNCHAT_LOAD_IMAGE(@"message_receiver_background_normal") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24) resizingMode:UIImageResizingModeStretch]];
    [self.backgroundImageView setHighlightedImage:[XMNCHAT_LOAD_IMAGE(@"message_receiver_background_highlight") resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24) resizingMode:UIImageResizingModeStretch]];
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:self.backgroundImageView.image highlightedImage:self.backgroundImageView.highlightedImage];
    self.messageContentView.maskView = maskImageView;
    self.messageContentViewWConstraint.constant = kXMNMessageViewMaxWidth;
}

#pragma mark - Methods

- (void)setupMessageViewConstraint:(XMNMessageType)aMessageType {
    
    [super setupMessageViewConstraint:aMessageType];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.messageContentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:aMessageType == XMNMessageTypeImage ? 0 : -16.f];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.messageContentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:aMessageType == XMNMessageTypeImage ? 0 :16.f];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.messageContentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:aMessageType != XMNMessageTypeText ? 0 : 6.f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.messageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.messageContentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:aMessageType != XMNMessageTypeText ? 0 :-16.f];
    self.messageViewConstraints = @[leftConstraint,rightConstraint,topConstraint,bottomConstraint];
    [self.messageContentView addConstraints:self.messageViewConstraints];
}

@end
