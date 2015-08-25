//
//  PCUSystemMessageCell.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PCUSystemMessageCell.h"
#import "PCUSystemMessageItemInteractor.h"

static const CGFloat kTextPaddingTop = 3.0f;
static const CGFloat kTextPaddingLeft = 8.0f;
static const CGFloat kTextPaddingRight = 8.0f;
static const CGFloat kTextPaddingBottom = 3.0f;

@interface PCUSystemMessageCell ()

@property (nonatomic, strong) ASTextNode *textNode;

@property (nonatomic, strong) ASDisplayNode *backgroundNode;

@end

@implementation PCUSystemMessageCell

- (instancetype)initWithMessageInteractor:(PCUMessageItemInteractor *)messageInteractor
{
    self = [super initWithMessageInteractor:messageInteractor];
    if (self) {
        [self addSubnode:self.backgroundNode];
        [self addSubnode:self.textNode];
    }
    return self;
}

#pragma mark - Node

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize {
    CGSize textSize = [self.textNode measure:CGSizeMake(constrainedSize.width - kTextPaddingLeft - kTextPaddingRight,
                                                        constrainedSize.height)];
    return CGSizeMake(constrainedSize.width, textSize.height + kTextPaddingTop + kTextPaddingBottom + kCellGaps);
}

- (void)layout {
    self.textNode.frame = CGRectMake((self.calculatedSize.width - self.textNode.calculatedSize.width) / 2.0,
                                     kTextPaddingTop,
                                     self.textNode.calculatedSize.width,
                                     self.textNode.calculatedSize.height);
    CGRect backgroundFrame = self.textNode.frame;
    backgroundFrame.origin.x -= kTextPaddingLeft;
    backgroundFrame.origin.y -= kTextPaddingTop;
    backgroundFrame.size.width += kTextPaddingLeft + kTextPaddingRight;
    backgroundFrame.size.height += kTextPaddingTop + kTextPaddingBottom;
    self.backgroundNode.frame = backgroundFrame;
}

#pragma mark - Getter

- (PCUSystemMessageItemInteractor *)systemMessageInteractor {
    return (id)[super messageInteractor];
}

- (ASTextNode *)textNode {
    if (_textNode == nil) {
        _textNode = [[ASTextNode alloc] init];
        NSString *text = [[self systemMessageInteractor] messageText];
        if (text == nil) {
            text = @"";
        }
        _textNode.attributedString = [[NSAttributedString alloc] initWithString:text attributes:[self textStyle]];
    }
    return _textNode;
}

- (ASDisplayNode *)backgroundNode {
    if (_backgroundNode == nil) {
        _backgroundNode = [[ASDisplayNode alloc] init];
        _backgroundNode.backgroundColor = [UIColor lightGrayColor];
        _backgroundNode.layer.cornerRadius = 6.0f;
        _backgroundNode.alpha = 0.6;
    }
    return _backgroundNode;
}

- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:kFontSize * 0.85];
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
