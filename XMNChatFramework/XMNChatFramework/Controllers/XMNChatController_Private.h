//
//  XMNChatController_Private.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <XMNChat/XMNChat.h>

#import "XMNChatBar.h"
#import "XMNChatExpressionView.h"
#import "XMNChatOtherView.h"

@interface XMNChatController () <UITableViewDelegate,YYTextViewDelegate,XMNChatBarDelegate>

@property (nonatomic, weak)   XMNChatBar *chatBar;
@property (nonatomic, strong)   XMNChatExpressionView *faceView;
@property (nonatomic, strong)   XMNChatOtherView *otherView;

@property (nonatomic, strong)   UITableView *tableView;

@property (nonatomic, weak)   NSLayoutConstraint *chatBarBConstraint;
@property (nonatomic, weak)   NSLayoutConstraint *chatBarHConstraint;

@property (nonatomic, assign) XMNChatBarShowingView showingViewType;

@end
