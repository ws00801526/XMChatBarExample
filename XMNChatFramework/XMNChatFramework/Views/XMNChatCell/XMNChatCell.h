//
//  XMNChatCell.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/14.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMNChatConfiguration.h"

@class FBKVOController;
@class XMNChatStateView;
@class XMNChatReuseMessageView;
@class XMNChatBaseMessage;
@protocol XMNChatCellDelegate;
@interface XMNChatCell : UITableViewCell

@property (weak, nonatomic)   id<XMNChatCellDelegate> delegate;
@property (strong, nonatomic) FBKVOController *kvoController;

@property (copy, nonatomic, readonly)   NSArray<NSLayoutConstraint *> *messageViewConstraints;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *messageContentView;
@property (weak, nonatomic) IBOutlet XMNChatStateView *messageStateView;

@property (weak, nonatomic) XMNChatReuseMessageView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameHConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContentViewWConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContentViewHConstraint;

- (void)configCellWithMessage:(XMNChatBaseMessage *)aMessage;
- (void)setupMessageViewConstraint:(XMNMessageType)messageType;

@end


@protocol XMNChatCellDelegate <NSObject>

@optional

- (void)messageCellDidTapAvatar:(XMNChatCell *)cell;
- (void)messageCellDidTapContent:(XMNChatCell *)cell;
- (void)messageCellDidDoubleTapContent:(XMNChatCell *)cell;

@end
