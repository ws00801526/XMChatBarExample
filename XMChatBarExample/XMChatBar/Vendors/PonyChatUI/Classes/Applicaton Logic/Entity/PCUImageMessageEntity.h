//
//  PCUImageMessageEntity.h
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

//  Update by XMFraker on 15/8/20
//  增加了image字段,默认显示的image

#import "PCUMessageEntity.h"

@interface PCUImageMessageEntity : PCUMessageEntity

@property (strong, nonatomic) UIImage *image;

@property (nonatomic, copy) NSString *imageURLString;

@property (nonatomic, assign) CGSize imageSize;

@end
