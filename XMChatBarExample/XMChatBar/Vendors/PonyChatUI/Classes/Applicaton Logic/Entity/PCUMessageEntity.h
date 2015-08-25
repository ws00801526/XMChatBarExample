//
//  PCUMessageEntity.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/6.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef double PCUMessageOrder;

@interface PCUMessageEntity : NSObject

@property (nonatomic, assign) PCUMessageOrder messageOrder;

@property (nonatomic, assign) BOOL ownSender;

@property (nonatomic, copy) NSString *senderNicknameString;

@property (nonatomic, copy) NSString *senderAvatarURLString;

@end
