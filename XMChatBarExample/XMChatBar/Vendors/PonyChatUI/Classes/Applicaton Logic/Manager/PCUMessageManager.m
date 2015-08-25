//
//  PCUMessageManager.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUMessageManager.h"

@interface PCUMessageManager ()

@end

@implementation PCUMessageManager

- (void)didReceiveMessageItem:(PCUMessageEntity *)messageItem {
    if (messageItem != nil) {
        NSMutableArray *messageItems = [self.messageItems mutableCopy];
        [messageItems addObject:messageItem];
        self.messageItems = [self sortedItems:messageItems];
        [self.delegate messageManagerItemsDidChanged];
    }
}

- (void)didReceiveMessageItems:(NSArray *)messageItems {
    if (messageItems != nil) {
        NSMutableArray *theMessageItems = [self.messageItems mutableCopy];
        [theMessageItems addObjectsFromArray:messageItems];
        self.messageItems = [self sortedItems:theMessageItems];
        [self.delegate messageManagerItemsDidChanged];
    }
}

- (NSArray *)sortedItems:(NSArray *)items {
    return [items sortedArrayUsingComparator:^NSComparisonResult(PCUMessageEntity *obj1, PCUMessageEntity *obj2) {
        if (obj1.messageOrder == obj2.messageOrder) {
            return NSOrderedSame;
        }
        else {
            return obj1.messageOrder > obj2.messageOrder ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
}

- (NSArray *)messageItems {
    if (_messageItems == nil) {
        _messageItems = @[];
    }
    return _messageItems;
}

@end
