//
//  XMImageMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMImageMessageCell.h"

@interface XMImageMessageCell  ()

@property (strong, nonatomic) UIImageView *messageImageView /**< 显示image的imageView */;
@property (strong, nonatomic) UIImageView *messageMaskImageView /**< 遮罩imageView */;

@end

@implementation XMImageMessageCell

#pragma mark - Override Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches allObjects][0];
    CGPoint touchPoint = [touch locationInView:self.messageContentView];
    if (CGRectContainsPoint(self.messageMaskImageView.frame, touchPoint)) {
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(XMImageMessageTapped:)]) {
            [self.messageDelegate XMImageMessageTapped:(XMImageMessage *)self.message];
        }
    }
}

#pragma mark - Public Methods

- (void)updateConstraints{
    [super updateConstraints];
    
    XMImageMessage *imageMessage = (XMImageMessage *)self.message;
    
    [self.messageMaskImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageContentView.mas_top);
        make.bottom.equalTo(self.messageContentView.mas_bottom).priorityHigh();
        make.height.mas_lessThanOrEqualTo(imageMessage.imageSize.height);
        make.width.mas_lessThanOrEqualTo(imageMessage.imageSize.width);
        if (self.message.messageOwner == XMMessageOwnerTypeSelf) {
            make.right.equalTo(self.messageContentView.mas_right);
        }else{
            make.left.equalTo(self.messageContentView.mas_left);
        }
    }];
    
    [self.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageMaskImageView);
    }];

}

- (void)setup{
    [super setup];
    
    [self.messageContentView addSubview:self.messageImageView];
    [self.messageContentView addSubview:self.messageMaskImageView];
    
}

- (void)setMessage:(XMMessage *)message{
    XMImageMessage *imageMessage = (XMImageMessage *)message;
    if (imageMessage.image) {
        self.messageImageView.image = imageMessage.image;
    }else if (imageMessage.imageUrlString){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageMessage.imageUrlString]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageImageView.image = [UIImage imageWithData:data];
            });
        });
    }
    self.messageMaskImageView.image = nil;
    if (message.messageOwner == XMMessageOwnerTypeSelf) {
        self.messageMaskImageView.image = [[UIImage imageNamed:@"message_sender_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 50, 15, 30) resizingMode:UIImageResizingModeStretch];
    }else{
        self.messageMaskImageView.image = [[UIImage imageNamed:@"message_receiver_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 50, 15, 30) resizingMode:UIImageResizingModeStretch];
    }
    [super setMessage:message];
}

#pragma mark - Getters

- (UIImageView *)messageImageView{
    if (!_messageImageView) {
        _messageImageView = [[UIImageView alloc] init];
    }
    return _messageImageView;
}

- (UIImageView *)messageMaskImageView{
    if (!_messageMaskImageView) {
        _messageMaskImageView = [[UIImageView alloc] init];
    }
    return _messageMaskImageView;
}

@end
