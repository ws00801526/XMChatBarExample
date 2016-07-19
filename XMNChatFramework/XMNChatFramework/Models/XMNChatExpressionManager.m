//
//  XMNChatExpressionManager.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/5/31.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatExpressionManager.h"
#import "XMNChatConfiguration.h"

#import "YYWebImage.h"

@interface XMNChatExpressionManager ()

@property (nonatomic, copy)   NSArray *qqEmotions;
@property (nonatomic, strong) NSBundle *qqBundle;

/** qq表情每页显示的数量 23个 */
@property (nonatomic, assign, readonly) NSInteger countPerPage;

@end

@implementation XMNChatExpressionManager

#pragma mark - Life Cycle

- (instancetype)init {
    
    if (self = [super init]) {
        
        //获取QQ表情解析格式
        
        /** 使用旧版QQ表情 */
        self.qqBundle = [NSBundle bundleWithPath:[kXMNChatBundle pathForResource:@"QQIcon" ofType:@"bundle"]];
        
        /** 使用最新版QQ表情 */
        self.qqBundle = [NSBundle bundleWithPath:[kXMNChatBundle pathForResource:@"QQIconNew" ofType:@"bundle"]];

        self.qqEmotions =  [NSArray arrayWithContentsOfFile:[self.qqBundle pathForResource:@"info" ofType:@"plist"]];
        NSMutableDictionary *mapper = [NSMutableDictionary dictionary];
        NSMutableDictionary *gifMapper = [NSMutableDictionary dictionary];
        __weak typeof(*&self) wSelf = self;
        [self.qqEmotions enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            __strong typeof(*&wSelf) self = wSelf;
            mapper[obj.allKeys[0]] = [YYImage imageWithContentsOfFile:[self.qqBundle pathForResource:[obj.allValues[0] stringByAppendingString:@"@2x"] ofType:@"png"]];
            /** 添加如果GIF表情不存在 使用PNG表情 */
            gifMapper[obj.allKeys[0]] = [YYImage imageWithContentsOfFile:[self.qqBundle pathForResource:[obj.allValues[0] stringByAppendingString:@"@2x"] ofType:@"gif"]] ? : mapper[obj.allKeys[0]];
        }];
        
        _qqMapper = [mapper copy];
        _qqGifMapper = [gifMapper copy];
    }
    return self;
}

+ (instancetype)sharedManager {
    
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

#pragma mark - Methods

- (NSArray *)emotionsAtIndexPath:(NSIndexPath *)aIndexPath {
    
    if (aIndexPath.section == 0) {
        NSInteger index = MAX(aIndexPath.row * self.countPerPage, 0);
        if (index + self.countPerPage >= self.qqEmotions.count) {
            NSInteger count =  self.qqEmotions.count -  index;            
            return [self.qqEmotions subarrayWithRange:NSMakeRange(index, count)];
        }else {
            return [self.qqEmotions subarrayWithRange:NSMakeRange(index, self.countPerPage)];
        }
    }
    return nil;
}

#pragma mark - Getters

- (NSInteger)countPerPage {
    
    return 23;
}

@end
