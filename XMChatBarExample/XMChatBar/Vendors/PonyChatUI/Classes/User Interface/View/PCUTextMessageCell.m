//
//  PCUTextMessageCell.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PCUTextMessageCell.h"
#import "PCUTextMessageItemInteractor.h"

#import "XMFaceManager.h"

static const CGFloat kTextPaddingLeft = 18.0f;
static const CGFloat kTextPaddingRight = 18.0f;
static const CGFloat kTextPaddingTop = 10.0f;
static const CGFloat kTextPaddingBottom = 10.0f;

@interface PCUTextMessageCell ()

@property (nonatomic, strong) ASTextNode *textNode;

@property (nonatomic, strong) ASImageNode *backgroundImageNode;

@end

@implementation PCUTextMessageCell

- (instancetype)initWithMessageInteractor:(PCUMessageItemInteractor *)messageInteractor
{
    self = [super initWithMessageInteractor:messageInteractor];
    if (self) {
        [self addSubnode:self.backgroundImageNode];
        [self addSubnode:self.textNode];
    }
    return self;
}

#pragma mark - Node

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize {
    CGSize superSize = [super calculateSizeThatFits:constrainedSize];
    CGSize textSize = [self.textNode measure:CGSizeMake(constrainedSize.width - kAvatarSize - 10.0 - kTextPaddingLeft - kTextPaddingRight,
                                                        constrainedSize.height)];
    CGFloat requiredHeight = MAX(superSize.height, textSize.height);
    return CGSizeMake(constrainedSize.width, requiredHeight + kTextPaddingTop + kTextPaddingBottom + kCellGaps);
}

- (void)layout {
    [super layout];
    if ([super actionType] == PCUMessageActionTypeSend) {
        self.textNode.frame = CGRectMake(self.calculatedSize.width - kAvatarSize - 10.0 - kTextPaddingRight - self.textNode.calculatedSize.width,
                                         kTextPaddingTop,
                                         self.textNode.calculatedSize.width,
                                         self.textNode.calculatedSize.height);
    }
    else if ([super actionType] == PCUMessageActionTypeReceive) {
        self.textNode.frame = CGRectMake(kAvatarSize + 10.0 + kTextPaddingLeft,
                                         kTextPaddingTop,
                                         self.textNode.calculatedSize.width,
                                         self.textNode.calculatedSize.height);
    }
    else {
        self.textNode.frame = CGRectZero;
    }
    if ([super actionType] == PCUMessageActionTypeSend) {
        self.backgroundImageNode.image = [[UIImage imageNamed:@"SenderTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
        CGRect frame = self.textNode.frame;
        frame.origin.x -= kTextPaddingLeft;
        frame.origin.y -= kTextPaddingTop;
        frame.size.width += kTextPaddingLeft + kTextPaddingRight;
        frame.size.height += kTextPaddingTop + kTextPaddingBottom + kTextPaddingBottom;
        self.backgroundImageNode.frame = frame;
    }
    else if ([super actionType] == PCUMessageActionTypeReceive) {
        self.backgroundImageNode.image = [[UIImage imageNamed:@"ReceiverTextNodeBkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
        CGRect frame = self.textNode.frame;
        frame.origin.x -= kTextPaddingLeft;
        frame.origin.y -= kTextPaddingTop;
        frame.size.width += kTextPaddingLeft + kTextPaddingRight;
        frame.size.height += kTextPaddingTop + kTextPaddingBottom + kTextPaddingBottom;
        self.backgroundImageNode.frame = frame;
    }
    else {
        self.backgroundImageNode.hidden = YES;
    }
}

#pragma mark - Getter

- (PCUTextMessageItemInteractor *)textMessageInteractor {
    return (id)[super messageInteractor];
}

- (ASTextNode *)textNode {
    if (_textNode == nil) {
        _textNode = [[ASTextNode alloc] init];
        NSString *text = [[self textMessageInteractor] messageText];
        if (text == nil) {
            text = @"";
        }
        
        NSMutableAttributedString *attrS = [XMFaceManager emotionStrWithString:text];
        [attrS addAttributes:[self textStyle] range:NSMakeRange(0, attrS.length)];
        _textNode.attributedString = attrS;
        
//        _textNode.attributedString = [[NSAttributedString alloc] initWithString:text attributes:[self textStyle]];
    }
    return _textNode;
}

- (ASImageNode *)backgroundImageNode {
    if (_backgroundImageNode == nil) {
        _backgroundImageNode = [[ASImageNode alloc] init];
        _backgroundImageNode.backgroundColor = [UIColor clearColor];
    }
    return _backgroundImageNode;
}

- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:kFontSize];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = 0.25 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    return @{
             NSFontAttributeName: font,
             NSParagraphStyleAttributeName: style
             };
}

@end
