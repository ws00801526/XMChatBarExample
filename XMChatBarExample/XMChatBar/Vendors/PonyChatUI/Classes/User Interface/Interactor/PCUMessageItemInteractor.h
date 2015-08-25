//
//  PCUMessageItemInteractor.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PCUMessageEntity;

@interface PCUMessageItemInteractor : NSObject

+ (PCUMessageItemInteractor *)itemInteractorWithMessageItem:(PCUMessageEntity *)messageItem;

@property (nonatomic, strong) PCUMessageEntity *messageItem;

@property (nonatomic, assign) BOOL ownSender;

@property (nonatomic, assign) double messageOrder;

@property (nonatomic, copy) NSString *avatarURLString;

@property (nonatomic, copy) NSString *nicknameString;

- (instancetype)initWithMessageItem:(PCUMessageEntity *)messageItem;

@end
