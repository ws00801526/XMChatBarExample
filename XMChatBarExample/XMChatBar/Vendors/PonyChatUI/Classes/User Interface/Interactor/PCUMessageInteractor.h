//
//  PCUMessageInteractor.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUMessageItemInteractor.h"

@class PCUMessageManager;

@protocol PCUMessageInteractorDelegate <NSObject>

- (void)messageInteractorItemsDidUpdated;

- (void)messageInteractorItemDidInserted;

- (void)messageInteractorItemDidPushed;

@end

@interface PCUMessageInteractor : NSObject

@property (nonatomic, weak) id<PCUMessageInteractorDelegate> delegate;

@property (nonatomic, strong) PCUMessageManager *messageManager;

@property (nonatomic, copy) NSArray *items;

@end
