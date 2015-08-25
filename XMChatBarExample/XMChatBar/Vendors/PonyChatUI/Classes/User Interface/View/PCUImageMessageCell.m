//
//  PCUImageMessageCell.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PCUImageMessageCell.h"
#import "PCUImageMessageItemInteractor.h"
#import "PCUCore.h"

@interface PCUImageMessageCell ()

@property (nonatomic, strong) ASNetworkImageNode *imageNode;

@property (nonatomic, strong) ASImageNode *maskNode;

@end

@implementation PCUImageMessageCell

- (instancetype)initWithMessageInteractor:(PCUMessageItemInteractor *)messageInteractor
{
    self = [super initWithMessageInteractor:messageInteractor];
    if (self) {
        [self addSubnode:self.imageNode];
        [self addSubnode:self.maskNode];
    }
    return self;
}

#pragma mark - Event

- (void)handleImageNodeTapped {
    if ([self.delegate respondsToSelector:@selector(PCUImageMessageItemTapped:)]) {
        [self.delegate PCUImageMessageItemTapped:(id)self.messageInteractor.messageItem];
    }
}

#pragma mark - Node

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize {
    CGSize superSize = [super calculateSizeThatFits:constrainedSize];
    CGSize imageSize = CGSizeMake([[self imageMessageInteractor] imageWidth], [[self imageMessageInteractor] imageHeight]);
    
    return CGSizeMake(constrainedSize.width, MAX(superSize.height, imageSize.height) + kCellGaps);
}

- (void)layout {
    [super layout];
    if ([super actionType] == PCUMessageActionTypeSend) {
        self.imageNode.frame = CGRectMake(self.calculatedSize.width - kAvatarSize - 10.0 - [self imageMessageInteractor].imageWidth, 0.0, [self imageMessageInteractor].imageWidth, [self imageMessageInteractor].imageHeight);
    }
    else if ([super actionType] == PCUMessageActionTypeReceive) {
        self.imageNode.frame = CGRectMake(kAvatarSize + 10.0, 0.0, [self imageMessageInteractor].imageWidth, [self imageMessageInteractor].imageHeight);
    }
    else {
        self.imageNode.hidden = YES;
    }
    if ([super actionType] == PCUMessageActionTypeSend) {
        self.maskNode.image = [[UIImage imageNamed:@"SenderTextNodeBkgReversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 30, 15, 30) resizingMode:UIImageResizingModeStretch];
        self.maskNode.frame = self.imageNode.frame;
    }
    else if ([super actionType] == PCUMessageActionTypeReceive) {
        self.maskNode.image = [[UIImage imageNamed:@"ReceiverTextNodeBkgReversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 30, 15, 30) resizingMode:UIImageResizingModeStretch];
        self.maskNode.frame = self.imageNode.frame;
    }
    else {
        self.maskNode.hidden = YES;
    }
}

#pragma mark - Getter

- (PCUImageMessageItemInteractor *)imageMessageInteractor {
    return (id)[super messageInteractor];
}

- (ASNetworkImageNode *)imageNode {
    if (_imageNode == nil) {
        _imageNode = [[ASNetworkImageNode alloc] init];
        [_imageNode addTarget:self action:@selector(handleImageNodeTapped) forControlEvents:ASControlNodeEventTouchUpInside];
        _imageNode.contentMode = UIViewContentModeScaleAspectFill;
        _imageNode.URL = [NSURL URLWithString:[[self imageMessageInteractor] imageURLString]];
        //XMFraker 增加,显示默认图片
        _imageNode.defaultImage = [self imageMessageInteractor].image;
        _imageNode.backgroundColor = [UIColor clearColor];
    }
    return _imageNode;
}

- (ASImageNode *)maskNode {
    if (_maskNode == nil) {
        _maskNode = [[ASImageNode alloc] init];
    }
    return _maskNode;
}

@end
