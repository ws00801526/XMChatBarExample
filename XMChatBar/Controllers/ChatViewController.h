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

@property (copy, nonatomic) NSString *chatterName /**< 正在聊天的用户昵称 */;
@property (copy, nonatomic) NSString *chatterThumb /**< 正在聊天的用户头像 */;

- (instancetype)initWithChatType:(XMMessageChatType)messageChatType;

@end
