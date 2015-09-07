//
//  XMLocationMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMLocationMessageCell.h"

@interface XMLocationMessageCell ()

@property (strong, nonatomic) UIView *messageContentView;
@property (weak, nonatomic) UIImageView *locationImageView;
@property (weak, nonatomic) UILabel *tipsLabel;
@property (weak, nonatomic) UILabel *addressLabel;

@end

@implementation XMLocationMessageCell

#pragma mark - Public Methods

- (void)setup{
    [super setup];
    
    [self.contentView addSubview:self.messageBackgroundImageView];
    [self.contentView addSubview:self.messageContentView];
}

- (void)updateConstraints{
    [super updateConstraints];
    
    if (self.message.messageOwner == XMMessageOwnerTypeOther) {
        [self.messageBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(8);
            make.width.lessThanOrEqualTo(@200);
        }];
    }else if (self.message.messageOwner == XMMessageOwnerTypeSelf){
        [self.messageBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-8);
            make.width.lessThanOrEqualTo(@200);
        }];
    }
    
    [self.messageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageBackgroundImageView).with.insets(UIEdgeInsetsMake(8, 8, 8, 8));
        make.width.greaterThanOrEqualTo(@150);
    }];
}


- (void)setMessage:(XMMessage *)message{
    
    self.addressLabel.text = [(XMLocationMessage *)message address];
    [super setMessage:message];
}

#pragma mark - Getters

- (UIView *)messageContentView{
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        _messageContentView.layer.cornerRadius = 6.0f;
        _messageContentView.layer.masksToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImage:[UIImage imageNamed:@"location"]];
        [_messageContentView addSubview:self.locationImageView = imageView];
        
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        tipsLabel.textColor = [UIColor darkTextColor];
        tipsLabel.text = @"位置分享";
        [_messageContentView addSubview:self.tipsLabel = tipsLabel];
        
        
        UILabel *addressLabel = [[UILabel alloc] init];
        addressLabel.font = [UIFont systemFontOfSize:12.0f];
        addressLabel.textColor = [UIColor darkGrayColor];
        addressLabel.numberOfLines = 3;
        addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        addressLabel.preferredMaxLayoutWidth = 100;
        [_messageContentView addSubview:self.addressLabel = addressLabel];
        
        {
            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(imageView.mas_height);
                make.left.equalTo(_messageContentView.mas_left).with.offset(8);
                make.centerY.equalTo(_messageContentView.mas_centerY);
                make.top.equalTo(_messageContentView.mas_top);
                make.bottom.equalTo(_messageContentView.mas_bottom);
            }];
            
            [tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(imageView.mas_top);
                make.left.equalTo(imageView.mas_right).with.offset(8);
            }];
            
            [addressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(tipsLabel.mas_bottom).with.offset(2);
                make.left.equalTo(imageView.mas_right).with.offset(8);
                make.right.equalTo(_messageContentView.mas_right).with.offset(-8).with.priorityHigh();
            }];
            
        }
    }
    return _messageContentView;
}

@end
