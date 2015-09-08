//
//  XMSystemMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMSystemMessageCell.h"

@interface XMSystemMessageCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *titleBackgroundView;

@end

@implementation XMSystemMessageCell

#pragma mark - Public Methods

- (void)setup{
    [super setup];
    
    [self.contentView addSubview:self.titleBackgroundView];
    [self.contentView addSubview:self.titleLabel];
    
}

#pragma mark - Override Methods

- (void)updateConstraints{
    [super updateConstraints];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.mas_lessThanOrEqualTo(@200);
    }];
    
    [self.titleBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left).with.offset(-kSystemTextPaddingLeft);
        make.right.equalTo(self.titleLabel.mas_right).with.offset(kSystemTextPaddingRight);
        make.top.equalTo(self.titleLabel.mas_top).with.offset(-kSystemTextPaddingTop);
        make.bottom.equalTo(self.titleLabel.mas_bottom).with.offset(kSystemTextPaddingBottom);
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(3, 8, 3, 8)).with.priorityLow();
    }];
    
}

#pragma mark - Setters

- (void)setMessage:(XMMessage *)message{
    NSString *text = message.messageText;
    if (text == nil) {
        text = @"";
    }
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self textStyle]];
    [super setMessage:message];
}

#pragma mark - Getters

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        NSString *text = self.message.messageText;
        if (text == nil) {
            text = @"";
        }
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.preferredMaxLayoutWidth = 200;
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self textStyle]];
    }
    return _titleLabel;
}


- (UIView *)titleBackgroundView{
    if (!_titleBackgroundView) {
        _titleBackgroundView = [[UIView alloc] init];
        _titleBackgroundView.backgroundColor = [UIColor lightGrayColor];
        _titleBackgroundView.alpha = .8f;
        _titleBackgroundView.layer.cornerRadius = 6.0f;
    }
    return _titleBackgroundView;
}

- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:14];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.15 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    return @{
             NSFontAttributeName: font,
             NSParagraphStyleAttributeName: style,
             NSForegroundColorAttributeName: [UIColor whiteColor]
             };
}

@end
