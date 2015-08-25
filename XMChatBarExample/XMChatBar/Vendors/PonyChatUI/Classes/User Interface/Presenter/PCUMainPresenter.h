//
//  PCUMainPresenter.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCUMainViewController, PCUMessageInteractor;

@interface PCUMainPresenter : NSObject

@property (nonatomic, weak) PCUMainViewController *userInterface;

@property (nonatomic, strong) PCUMessageInteractor *messageInteractor;

- (void)updateView;

@end
