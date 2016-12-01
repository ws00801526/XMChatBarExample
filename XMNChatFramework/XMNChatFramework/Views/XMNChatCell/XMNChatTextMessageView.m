//
//  XMNChatTextMessageView.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatTextMessageView.h"

#import "YYText.h"

#import "XMNChatMessage.h"
#import "XMNChatExpressionManager.h"


@interface XMNChatTextMessageView ()

@property (weak, nonatomic) IBOutlet YYLabel *textLabel;

@end

@implementation XMNChatTextMessageView

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.autoresizingMask = UIViewAutoresizingNone;
    //    self.textLabel.displaysAsynchronously = YES;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    
    //设置textView 解析表情 解析link
    XMNChatTextParser *parser = [[XMNChatTextParser alloc] init];
    parser.emoticonMapper = [XMNChatExpressionManager sharedManager].qqGifMapper;
    parser.emotionSize = CGSizeMake(24.f, 24.f);
    parser.alignFont = [UIFont systemFontOfSize:14.f];
    parser.parseLinkEnabled = YES;
    self.textLabel.textParser = parser;
    
    //设置textView 固定行高
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = 26;
    self.textLabel.linePositionModifier = mod;
}

#pragma mark - Methods

- (void)setupViewWithMessage:(XMNChatBaseMessage *)aMessage {
    
    //设置显示的文本内容
    //    self.textLabel.text = aMessage.content;
    
    //计算aMessage.content 所需要的高度
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:aMessage.content];
    
    [self.textLabel.textParser parseText:one
                           selectedRange:NULL];
    
    one.yy_font = self.textLabel.font;
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kXMNMessageViewMaxWidth - 36, CGFLOAT_MAX)];
    container.linePositionModifier = self.textLabel.linePositionModifier;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:one];
    self.textLabel.textLayout = layout;
    self.contentSize  = CGSizeMake(MIN(MIN(layout.textBoundingSize.width + 36, kXMNMessageViewMaxWidth), self.textLabel.textLayout.textBoundingSize.width + 36), layout.rowCount * [(YYTextLinePositionSimpleModifier *)self.textLabel.linePositionModifier fixedLineHeight] );
    /// 2. 添加高亮点击事件
    
    //    [one yy_setTextHighlightRange:one.yy_rangeOfAll
    //                            color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
    //                  backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220]
    //                        tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
    //                            XMNLog(@"this is click");
    //                        }];
    //    self.textLabel.attributedText = one;
}

@end
