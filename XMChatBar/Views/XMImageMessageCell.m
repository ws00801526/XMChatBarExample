//
//  XMImageMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMImageMessageCell.h"
#import "XMNShapeImageView.h"

@interface XMImageMessageCell  ()

@property (strong, nonatomic) UIImageView *messageImageView /**< 显示image的imageView */;
@end

@implementation XMImageMessageCell

#pragma mark - Override Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches allObjects][0];
    CGPoint touchPoint = [touch locationInView:self.messageContentView];
    if (CGRectContainsPoint(self.messageImageView.frame, touchPoint)) {
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(XMImageMessageTapped:)]) {
            [self.messageDelegate XMImageMessageTapped:(XMImageMessage *)self.message];
        }
    }
}

#pragma mark - Public Methods

- (void)updateConstraints{
    [super updateConstraints];
    NSLog(@"updateConstraints :%@",[self class]);
    XMImageMessage *imageMessage = (XMImageMessage *)self.message;
    
    [self.messageImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
    
}

- (void)setup{
    
    [super setup];
    [self.messageContentView addSubview:self.messageImageView];

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
    
    self.messageImageView.maskView = [self messageMaskImageViewWithMessage:imageMessage];
    
    [super setMessage:message];
}

#pragma mark - Getters

- (UIImageView *)messageImageView{
    if (!_messageImageView) {
        _messageImageView = [[UIImageView alloc] init];
    }
    return _messageImageView;
}

- (UIImageView *)messageMaskImageViewWithMessage:(XMImageMessage *)message {
    UIImageView *maskView = [[UIImageView alloc] init];
    if (message.messageOwner == XMMessageOwnerTypeSelf) {
//        [maskView setImage:[UIImage imageNamed:@"message_sender_background_normal"]];
        [maskView setImage:[[UIImage imageNamed:@"message_sender_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 16, 16, 24) resizingMode:UIImageResizingModeStretch]];
    }else {
        [maskView setImage:[[UIImage imageNamed:@"message_receiver_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 24, 16, 16) resizingMode:UIImageResizingModeStretch]];
    }
    maskView.frame = CGRectMake(0, 0, message.imageSize.width, message.imageSize.height);
    return maskView;
}

@end
