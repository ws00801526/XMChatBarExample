//
//  ChatListCell.m
//  SpotGoods
//
//  Created by shscce on 15/8/14.
//  Copyright (c) 2015年 shscce. All rights reserved.
//

#import "ChatListCell.h"

#import "Masonry.h"

@interface ChatListCell ()

@end

@implementation ChatListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.unreadLabel.backgroundColor = RGB(233, 10, 1);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    self.unreadLabel.backgroundColor = RGB(233, 10, 1);
}

- (void)updateConstraints{
    [super updateConstraints];
    
    [self.headImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).with.offset(12);
        make.width.equalTo(40);
        make.height.equalTo(40);
        make.centerY.equalTo(self.contentView.centerY);
    }];
    
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.right).with.offset(8);
        make.top.equalTo(self.headImageView.top).with.offset(2);
    }];
    
    [self.lastMessageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.right).with.offset(8);
        make.right.equalTo(self.contentView.right).with.offset(-8);
        make.bottom.equalTo(self.headImageView.bottom).with.offset(-2);
    }];
    
    [self.timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).with.offset(-8);
        make.centerY.equalTo(self.titleLabel.centerY);
    }];
    
    [self.unreadLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.right).with.offset(-8);
        make.centerY.equalTo(self.lastMessageLabel.centerY);
        make.width.mas_greaterThanOrEqualTo(@20);
        make.height.equalTo(15);
    }];
    
}

#pragma mark - Private Methods

- (void)setup{
    UIImageView *headImageView = [[UIImageView alloc] init];
    headImageView.layer.cornerRadius = 20;
    headImageView.layer.masksToBounds = YES;
    [headImageView setImage:[UIImage imageNamed:@"chatListCellHead"]];
    [self.contentView addSubview:self.headImageView = headImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.text = @"ceshi xia";
    [self.contentView addSubview:self.titleLabel = titleLabel];
    
    UILabel *lastMessageLabel = [[UILabel alloc] init];
    lastMessageLabel.font = [UIFont systemFontOfSize:12.0f];
    lastMessageLabel.textColor = [UIColor lightGrayColor];
    lastMessageLabel.text= @"最好赛";
    [self.contentView addSubview:self.lastMessageLabel = lastMessageLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:10.0f];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.text = @"2015- dsa";
    [self.contentView addSubview:self.timeLabel = timeLabel];
    
    UILabel *unreadLabel = [[UILabel alloc] init];
    unreadLabel.textColor = [UIColor whiteColor];
    unreadLabel.font = [UIFont systemFontOfSize:10.0f];
    unreadLabel.textAlignment = NSTextAlignmentCenter;
    unreadLabel.layer.cornerRadius = 7.5f;
    unreadLabel.layer.masksToBounds = YES;
    unreadLabel.backgroundColor = RGB(233, 10, 1);
    unreadLabel.text = @"10";
    [self.contentView addSubview:self.unreadLabel = unreadLabel];
    
    
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.backgroundColor = RGB(234, 234, 234);
    [self.contentView addSubview:lineImageView];
    [lineImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
        make.height.mas_equalTo(.5);
    }];
    
    [self updateConstraintsIfNeeded];
}


#pragma mark - Setters
- (void)setUnReadCount:(NSUInteger)unReadCount{
    _unReadCount = unReadCount;
    if (unReadCount == 0) {
        self.unreadLabel.hidden = YES;
    }else{
        self.unreadLabel.hidden = NO;
    }
    if (unReadCount <= 99) {
        [self.unreadLabel setText:[NSString stringWithFormat:@"%ld  ",unReadCount]];
    }else{
        [self.unreadLabel setText:[NSString stringWithFormat:@"%ld+  ",unReadCount]];
    }
}
@end
