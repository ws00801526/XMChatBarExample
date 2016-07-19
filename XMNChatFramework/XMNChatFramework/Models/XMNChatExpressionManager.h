//
//  XMNChatExpressionManager.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/5/31.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYImage.h"
#import "YYText.h"
#import "XMNChatConfiguration.h"
#import "XMNChatTextParser.h"

/**
 *  表情管理
 */
@interface XMNChatExpressionManager : NSObject

/** 所有的qq表情图片 @{@"表情对应中文文字":@"表情图片地址"} */
@property (nonatomic, copy, readonly)   NSArray *qqEmotions;

/** qq表情存放bundle资源文件夹 */
@property (nonatomic, strong, readonly) NSBundle *qqBundle;

/** qq表情解析  普通png格式表情 格式如下
 @{
    @"/撇嘴" : [UIImage imageWithFile:@"xxx.png"],
    ...
 }
 */
@property (nonatomic, copy, readonly)   NSDictionary *qqMapper;

/** qq Gif 表情解析  普通gif格式表情 格式如下
 @{
 @"/撇嘴" : [UIImage imageWithFile:@"xxx.gif"],
 ...
 }
 */
@property (nonatomic, copy, readonly)   NSDictionary *qqGifMapper;

+ (instancetype)sharedManager;

- (NSArray *)emotionsAtIndexPath:(NSIndexPath *)aIndexPath;

@end
