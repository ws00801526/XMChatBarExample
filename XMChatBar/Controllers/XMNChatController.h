//
//  XMNChatController.h
//  XMChatBarExample
//
//  Created by shscce on 15/11/20.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMNChat.h"

@interface XMNChatController : UIViewController

@property (copy, nonatomic) NSString *chatterName /**< 正在聊天的用户昵称 */;
@property (copy, nonatomic) NSString *chatterThumb /**< 正在聊天的用户头像 */;

- (instancetype)initWithChatType:(XMNMessageChat)messageChatType;

@end
