//
//  PCUMainPresenter.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUMainPresenter.h"
#import "PCUMainViewController.h"
#import "PCUMessageInteractor.h"

@interface PCUMainPresenter ()<PCUMessageInteractorDelegate>{
    BOOL isViewDidLoaded;
}

@end

@implementation PCUMainPresenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageInteractor = [[PCUMessageInteractor alloc] init];
        _messageInteractor.delegate = self;
    }
    return self;
}

- (void)updateView {
    isViewDidLoaded = YES;
    [self.userInterface reloadData];
}

#pragma mark - PCUMessageInteractorDelegate

- (void)messageInteractorItemsDidUpdated {
    if (isViewDidLoaded) {
        [self.userInterface reloadData];
    }
}

- (void)messageInteractorItemDidPushed {
    if (isViewDidLoaded) {
        [self.userInterface pushData];
    }
}

- (void)messageInteractorItemDidInserted {
    if (isViewDidLoaded) {
        [self.userInterface insertData];
    }
}

@end
