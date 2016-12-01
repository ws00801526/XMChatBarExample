//
//  XMNChatCell.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//


#import "XMNChatCell.h"
#import "XMNChatStateView.h"
#import "XMNChatReuseMessageView.h"

#import "XMNChatMessage.h"
#import "FBKVOController.h"

#import "YYText.h"
#import "XMNChatTextMessageView.h"

@implementation XMNChatCell

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize kvoController  = _kvoController;
@synthesize delegate = _delegate;

#pragma mark - Life Cycle
- (void)dealloc {
    
    XMNLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self.kvoController unobserveAll];
}

#pragma mark - Override Methods

//- (void)layoutSubviews {
//
////    self.messageContentView.maskView.frame = self.messageContentView.bounds;
//    [super layoutSubviews];
//    
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    self.backgroundImageView.highlighted  = selected;
}

#pragma mark - Methods

- (void)setupConstraints {
    
    if ([[self.reuseIdentifier lowercaseString] containsString:@"group"]) {
        self.nickNameLabel.hidden = NO;
        self.nicknameHConstraint.constant = 20.f;
    }else {
        self.nickNameLabel.hidden = YES;
        self.nicknameHConstraint.constant = .0f;
    }
}

- (void)configCellWithMessage:(XMNChatBaseMessage *)aMessage {
    
    /** 先取消所有的监听 */
    [self.kvoController unobserveAll];
    
    /** 重新监听 */
    __weak typeof(*&self) wSelf = self;
    [self.kvoController observe:aMessage keyPath:@"state" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(*&wSelf) self = wSelf;
            [self updateUIWithMessage:object];
        });
    }];
    
    [self.kvoController observe:aMessage keyPath:@"substate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(*&wSelf) self = wSelf;
            [self updateUIWithMessage:object];
        });
    }];
        
    [self.messageView removeFromSuperview];
    [self.messageContentView removeConstraints:self.messageViewConstraints];
    
    XMNChatReuseMessageView *reuseView = [XMNChatReuseMessageView messageViewWithMessageType:aMessage.type];
    [self.messageContentView addSubview:self.messageView = reuseView];
    [self.messageView setupViewWithMessage:aMessage];
    [self setupMessageViewConstraint:aMessage.type];
    self.messageContentViewWConstraint.constant = [self.messageView intrinsicContentSize].width;
    self.messageContentViewHConstraint.constant = [self.messageView intrinsicContentSize].height;
    [self.messageStateView setMessageState:aMessage.state];

    /** 修复 iOS10 +  layoutSubview  计算contentSize 不准确问题 */
    self.messageContentView.maskView.frame = CGRectMake(0, 0, self.messageContentViewWConstraint.constant, self.messageContentViewHConstraint.constant + 15.f);

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setupMessageViewConstraint:(XMNMessageType)messageType {
    
    self.messageContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageView.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.messageViewConstraints) {
        [self.messageContentView removeConstraints:self.messageViewConstraints];
    }
}

-(void)updateUIWithMessage:(XMNChatBaseMessage *)message {
    
    self.messageStateView.messageState = message.state;
    [self.messageView updateUIWithMessage:message];
}

#pragma mark - Setters

- (void)setReuseIdentifier:(NSString *)reuseIdentifier {
    
    _reuseIdentifier = [reuseIdentifier copy];
    [self setupConstraints];
}

#pragma mark - Getters

- (FBKVOController *)kvoController {
    
    if (!_kvoController) {
        _kvoController = [FBKVOController controllerWithObserver:self];
    }
    return _kvoController;
}
@end
