//
//  XMNChatSystemCell.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/6/21.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatSystemCell.h"
#import "YYLabel.h"

#import "XMNChatMessage.h"


@interface XMNChatSystemCell ()

/** 显示系统消息文字 */
@property (weak, nonatomic) IBOutlet UIButton *titleLabel;

@end

@implementation XMNChatSystemCell


#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.layer.cornerRadius = 4.f;
    self.titleLabel.layer.masksToBounds = YES;
}

#pragma mark - Methods

- (void)configCellWithMessage:(XMNChatSystemMessage *)aMessage {
 
    [self.titleLabel setTitle:[NSString stringWithFormat:@"%@",aMessage.content] forState:UIControlStateDisabled];
}

@end
