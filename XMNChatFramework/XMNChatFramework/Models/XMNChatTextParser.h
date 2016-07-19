//
//  XMNChatTextEmotionParser.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/6/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYText.h"

@interface XMNChatTextParser : NSObject <YYTextParser>


@property (nullable, copy) NSDictionary<NSString *, __kindof UIImage *> *emoticonMapper;

@property (nonatomic, assign) CGSize emotionSize;
@property (nonatomic, copy, nonnull)   UIFont *alignFont;

/** 是否解析link */
@property (nonatomic, assign) BOOL parseLinkEnabled;

@property (nonatomic, assign) YYTextVerticalAlignment alignment;


@end
