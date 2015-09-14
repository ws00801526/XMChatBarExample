//
//  ChatViewController.h
//  XMChatControllerExample
//
//  Created by shscce on 15/9/3.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMMessage.h"

@interface ChatViewController : UIViewController

@property (copy, nonatomic) NSString *chatterName;
@property (copy, nonatomic) NSString *chatterThumb;

- (instancetype)initWithChatType:(XMMessageChatType)messageChatType;

@end
