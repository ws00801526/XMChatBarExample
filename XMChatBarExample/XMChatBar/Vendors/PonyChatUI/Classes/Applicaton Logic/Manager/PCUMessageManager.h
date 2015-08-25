//
//  PCUMessageManager.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUMessageEntity.h"
#import "PCUTextMessageEntity.h"
#import "PCUSystemMessageEntity.h"
#import "PCUImageMessageEntity.h"
#import "PCUVoiceMessageEntity.h"

@class PCUMessageEntity;

@protocol PCUMessageManagerDelegate <NSObject>

@required
- (void)messageManagerItemsDidChanged;

@end

@interface PCUMessageManager : NSObject

@property (nonatomic, weak) id<PCUMessageManagerDelegate> delegate;

@property (nonatomic, copy) NSArray *messageItems;

- (void)didReceiveMessageItem:(PCUMessageEntity *)messageItem;

- (void)didReceiveMessageItems:(NSArray *)messageItems;

@end
