//
//  XMVoiceMessage.h
//  XMChatControllerExample
//
//  Created by shscce on 15/9/2.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMMessage.h"

@interface XMVoiceMessage : XMMessage

@property (assign, nonatomic) NSUInteger voiceSeconds /**< 录音时间 */;
@property (copy, nonatomic) NSString *voiceUrlString /**< 录音地址 */;
@property (strong, nonatomic) NSData *voiceData /**< 录音data */;

@end
