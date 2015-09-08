//
//  XMLocationMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMLocationMessageCell.h"

@interface XMLocationMessageCell ()

@property (strong, nonatomic) UIView *locationMessageContentView;
@property (weak, nonatomic) UIImageView *locationImageView;
@property (weak, nonatomic) UILabel *tipsLabel;
@property (weak, nonatomic) UILabel *addressLabel;

@end

@implementation XMLocationMessageCell

#pragma mark - Public Methods

- (void)setup{
    [super setup];
    
    [self.messageContentView addSubview:self.messageBackgroundImageView];
    [self.messageContentView addSubview:self.locationMessageContentView];
    
}

- (void)updateConstraints{
    [super updateConstraints];
    
    [self.messageBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
    }];
    
    [self.locationMessageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageBackgroundImageView).with.insets(UIEdgeInsetsMake(8, 8, 8, 8));
        make.width.greaterThanOrEqualTo(@150);
    }];
}


- (void)setMessage:(XMMessage *)message{
    
    self.addressLabel.text = [(XMLocationMessage *)message address];
    [super setMessage:message];
}

#pragma mark - Getters

- (UIView *)locationMessageContentView{
    if (!_locationMessageContentView) {
        _locationMessageContentView = [[UIView alloc] init];
        _locationMessageContentView.layer.cornerRadius = 6.0f;
        _locationMessageContentView.layer.masksToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImage:[UIImage imageNamed:@"location"]];
        [_locationMessageContentView addSubview:self.locationImageView = imageView];
        
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        tipsLabel.textColor = [UIColor darkTextColor];
        tipsLabel.text = @"位置分享";
        [_locationMessageContentView addSubview:self.tipsLabel = tipsLabel];
        
        
        UILabel *addressLabel = [[UILabel alloc] init];
        addressLabel.font = [UIFont systemFontOfSize:12.0f];
        addressLabel.textColor = [UIColor darkGrayColor];
        addressLabel.numberOfLines = 3;
        addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        addressLabel.preferredMaxLayoutWidth = 100;
        [_locationMessageContentView addSubview:self.addressLabel = addressLabel];
        
        {
            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(imageView.mas_height);
                make.left.equalTo(_locationMessageContentView.mas_left).with.offset(8);
                make.centerY.equalTo(_locationMessageContentView.mas_centerY);
                make.top.equalTo(_locationMessageContentView.mas_top);
                make.bottom.equalTo(_locationMessageContentView.mas_bottom);
            }];
            
            [tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(imageView.mas_top);
                make.left.equalTo(imageView.mas_right).with.offset(8);
            }];
            
            [addressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(tipsLabel.mas_bottom).with.offset(2);
                make.left.equalTo(imageView.mas_right).with.offset(8);
                make.right.equalTo(_locationMessageContentView.mas_right).with.offset(-8).with.priorityHigh();
            }];
            
        }
    }
    return _locationMessageContentView;
}

@end
