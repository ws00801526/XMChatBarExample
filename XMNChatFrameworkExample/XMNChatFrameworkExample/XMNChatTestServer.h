//
//  XMNChatTestServer.h
//  XMNChatFrameworkExample
//
//  Created by XMFraker on 16/6/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XMNChat/XMNChatServer.h>

/**
 *  测试使用的 模拟XMNChatServer 
 *  重写此类 实现XMNChatServer
 *  实现你自己的与服务器沟通的功能
 *  此示例中 默认发送消息 1秒后发送成功,或者失败
 */
@interface XMNChatTestServer : NSObject <XMNChatServer>

@end
