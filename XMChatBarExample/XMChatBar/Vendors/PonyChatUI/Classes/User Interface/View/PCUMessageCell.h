//
//  PCUMessageCell.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "ASCellNode.h"

static const CGFloat kCellGaps = 8.0f;
static const CGFloat kAvatarSize = 40.0f;
static const CGFloat kFontSize = 15.0f;

typedef NS_ENUM(NSInteger, PCUMessageActionType) {
    PCUMessageActionTypeUnknown = 0,
    PCUMessageActionTypeSend,
    PCUMessageActionTypeReceive
};

@class PCUMessageItemInteractor;

@protocol PCUDelegate;

@interface PCUMessageCell : ASCellNode

@property (nonatomic, weak) id<PCUDelegate> delegate;

@property (nonatomic, assign) PCUMessageActionType actionType;

+ (PCUMessageCell *)cellForMessageInteractor:(PCUMessageItemInteractor *)messageInteractor;

#pragma mark - Private

@property (nonatomic, strong) PCUMessageItemInteractor *messageInteractor;

- (instancetype)initWithMessageInteractor:(PCUMessageItemInteractor *)messageInteractor;

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize;

- (void)layout;

@end
