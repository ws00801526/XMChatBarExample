//
//  XMNChatBar.h
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YYText.h"

#import "XMNChatConfiguration.h"

@protocol XMNChatBarDelegate <NSObject>

@optional
- (void)chatBarShowingViewDidChanged:(XMNChatBarShowingView)viewType;

@end

@interface XMNChatBar : UIView

@property (nonatomic, weak)   id<XMNChatBarDelegate> delegate;

@property (weak, nonatomic) IBOutlet YYTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *voiceRecordButton;

- (void)resetButtonState;

@end

