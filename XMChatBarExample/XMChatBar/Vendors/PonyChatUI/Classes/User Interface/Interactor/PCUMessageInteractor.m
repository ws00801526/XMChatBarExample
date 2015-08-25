//
//  PCUMessageInteractor.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUMessageInteractor.h"
#import "PCUMessageManager.h"

@interface PCUMessageInteractor ()<PCUMessageManagerDelegate>

@end

@implementation PCUMessageInteractor

#pragma mark - PCUMessageManagerDelegate

- (void)messageManagerItemsDidChanged {
    if ([self.messageManager.messageItems count] == 1) {
        [self reloadAllItems];
    }
    else if ([self.messageManager.messageItems count] == [self.items count] + 1) {
        if ([[self.messageManager.messageItems lastObject] messageOrder] > [[self.items lastObject] messageOrder]) {
            [self pushItem];
        }
        else if ([[self.messageManager.messageItems firstObject] messageOrder] < [[self.items firstObject] messageOrder]) {
            [self insertItem];
        }
        else {
            [self reloadAllItems];
        }
    }
    else {
        [self reloadAllItems];
    }
}

- (void)reloadAllItems {
    NSMutableArray *itemsInteractor = [NSMutableArray array];
    [self.messageManager.messageItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [itemsInteractor addObject:[PCUMessageItemInteractor itemInteractorWithMessageItem:obj]];
    }];
    self.items = itemsInteractor;
    [self.delegate messageInteractorItemsDidUpdated];
}

- (void)pushItem {
    NSMutableArray *itemsInteractor = [self.items mutableCopy];
    [itemsInteractor addObject:[PCUMessageItemInteractor itemInteractorWithMessageItem:[self.messageManager.messageItems lastObject]]];
    self.items = itemsInteractor;
    [self.delegate messageInteractorItemDidPushed];
}

- (void)insertItem {
    NSMutableArray *itemsInteractor = [self.items mutableCopy];
    [itemsInteractor insertObject:[PCUMessageItemInteractor itemInteractorWithMessageItem:[self.messageManager.messageItems firstObject]] atIndex:0];
    self.items = itemsInteractor;
    [self.delegate messageInteractorItemDidInserted];
}

#pragma mark - Setter

- (void)setMessageManager:(PCUMessageManager *)messageManager {
    _messageManager = messageManager;
    [_messageManager setDelegate:self];
}

@end
