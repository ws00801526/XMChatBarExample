//
//  PCUWireframe.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import "PCUWireframe.h"
#import "PCUMainViewController.h"
#import "PCUMainPresenter.h"
#import "PCUMessageInteractor.h"

@implementation PCUWireframe

- (UIView *)addMainViewToViewController:(UIViewController<PCUDelegate> *)viewController
                     withMessageManager:(PCUMessageManager *)messageManager {
    PCUMainViewController *mainViewController = [[PCUMainViewController alloc] init];
    mainViewController.delegate = viewController;
    mainViewController.eventHandler.messageInteractor.messageManager = messageManager;
    [viewController addChildViewController:mainViewController];
    [viewController.view addSubview:mainViewController.view];
    return mainViewController.view;
}

@end
