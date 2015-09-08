//
//  XMMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMMessageCell.h"
#import "XMSystemMessage.h"
#import "XMTextMessage.h"
#import "XMImageMessage.h"
#import "XMLocationMessage.h"
#import "XMVoiceMessage.h"

@interface XMMessageCell    ()

@end

@implementation XMMessageCell


+ (NSString *)cellIndetifyForMessage:(XMMessage *)message{
    if ([message isKindOfClass:[XMSystemMessage class]]) {
        return @"XMSystemMessageCell";
    }else if ([message isKindOfClass:[XMTextMessage class]]){
        return @"XMTextMessageCell";
    }else if ([message isKindOfClass:[XMImageMessage class]]){
        return @"XMImageMessageCell";
    }else if ([message isKindOfClass:[XMLocationMessage class]]){
        return @"XMLocationMessageCell";
    }else if ([message isKindOfClass:[XMVoiceMessage class]]){
        return @"XMVoiceMessageCell";
    }
    return @"XMMessageCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.messageNickNameLabel];
    [self.contentView addSubview:self.messageContentView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Override Methods

- (void)updateConstraints{
    [super updateConstraints];
    if (self.message.messageChatType == XMMessageChatSingle) {
        self.messageNickNameLabel.hidden = YES;
        [self.messageNickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top).with.offset(-8);
            make.width.equalTo(@0);
            make.height.equalTo(@0);
            if (self.message.messageOwner == XMMessageOwnerTypeSelf) {
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-8);
            }else{
                make.left.equalTo(self.avatarImageView.mas_right).with.offset(8);
            }
        }];
    }else if (self.message.messageChatType == XMMessageChatGroup){
        self.messageNickNameLabel.hidden = NO;
        [self.messageNickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top).with.offset(-4);
            make.width.lessThanOrEqualTo(@200);
            make.height.equalTo(@10);
            if (self.message.messageOwner == XMMessageOwnerTypeSelf) {
                make.right.equalTo(self.avatarImageView.mas_left).with.offset(-8);
            }else{
                make.left.equalTo(self.avatarImageView.mas_right).with.offset(8);
            }
        }];
    }
    
    [self.messageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageNickNameLabel.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
        if (self.message.messageOwner == XMMessageOwnerTypeSelf) {
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-8);
        }else{
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(8);
        }
    }];
    
    
    
    self.avatarImageView.hidden = NO;
    if (self.message.messageOwner == XMMessageOwnerTypeOther) {
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(10);
            make.top.equalTo(self.contentView.mas_top).with.offset(8);
            make.width.mas_equalTo(@kAvatarSize).with.priorityHigh();
            make.height.mas_equalTo(@kAvatarSize).with.priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8).priorityMedium();
        }];
 
    }else if (self.message.messageOwner == XMMessageOwnerTypeSelf){
        [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            make.top.equalTo(self.contentView.mas_top).with.offset(8);
            make.width.mas_equalTo(@kAvatarSize).with.priorityHigh();
            make.height.mas_equalTo(@kAvatarSize).with.priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8).priorityMedium();
        }];
    }else{
        self.avatarImageView.hidden = YES;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches allObjects][0];
    CGPoint touchPoint = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(self.messageContentView.frame, touchPoint)) {
        self.messageBackgroundImageView.highlighted = YES;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    self.messageBackgroundImageView.highlighted = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.messageBackgroundImageView.highlighted = NO;
    UITouch *touch = [touches allObjects][0];
    CGPoint touchPoint = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(self.avatarImageView.frame, touchPoint) || CGRectContainsPoint(self.messageNickNameLabel.frame, touchPoint)) {
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(XMMessageAvatarTapped:)]) {
            [self.messageDelegate XMMessageAvatarTapped:self.message];
        }
    }else if (CGRectContainsPoint(self.messageContentView.frame, touchPoint)){
        
    }else{
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(XMMessageBankTapped:)]) {
            [self.messageDelegate XMMessageBankTapped:self.message];
        }
    }
}

#pragma mark - Setters

- (void)setMessage:(XMMessage *)message{
    _message = message;
    if (message.messageOwner == XMMessageOwnerTypeSelf) {
        self.messageBackgroundImageView.image = [[UIImage imageNamed:@"message_sender_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
        self.messageBackgroundImageView.highlightedImage = [[UIImage imageNamed:@"message_sender_background_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    }else if (message.messageOwner == XMMessageOwnerTypeOther){
        [self.messageBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch]];
        self.messageBackgroundImageView.highlightedImage = [[UIImage imageNamed:@"message_receiver_background_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    }
    
    [self updateConstraints];

}

#pragma mark - Getters

- (UIImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.backgroundColor = [UIColor yellowColor];
        _avatarImageView.layer.cornerRadius = kAvatarCornerRadius;
    }
    return _avatarImageView;
}


- (UIImageView *)messageBackgroundImageView{
    if (!_messageBackgroundImageView) {
        _messageBackgroundImageView = [[UIImageView alloc] init];
    }
    return _messageBackgroundImageView;
}

- (UILabel *)messageNickNameLabel{
    if (!_messageNickNameLabel) {
        _messageNickNameLabel = [[UILabel alloc] init];
        _messageNickNameLabel.font = [UIFont systemFontOfSize:10.0f];
        _messageNickNameLabel.textColor = [UIColor darkGrayColor];
        _messageNickNameLabel.text = @"测试昵称";
    }
    return _messageNickNameLabel;
}

- (UIView *)messageContentView{
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
    }
    return _messageContentView;
}

@end
