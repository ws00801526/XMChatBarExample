//
//  XMFaceManager.h
//  XMChatBarExample
//
//  Created by shscce on 15/8/25.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#define kFaceIDKey      @"face_id"
#define kFaceNameKey    @"face_name"

#define kFaceRankKey    @"face_rank"
#define kFaceClickKey   @"face_click"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *  表情管理类,可以获取所有的表情名称
 *  TODO 直接获取所有的表情Dict,添加排序功能,对表情进行排序,常用表情排在前面
 */
@interface XMFaceManager : NSObject

+ (instancetype)shareInstance;



#pragma mark - emoji表情相关

/**
 *  获取所有的表情图片名称
 *
 *  @return 所有的表情图片名称
 */
+ (NSArray *)emojiFaces;


/**
 *  根据表情名称获取图片名称
 *
 *  @param faceName 表情名称
 *
 *  @return 表情的图片名
 */
+ (NSString *)faceImageNameWithFaceName:(NSString *)faceName;

/**
 *  根据表情的图片名 获取表情名称
 *
 *  @param faceImageName 表情图片名
 *
 *  @return 表情名称
 */
+ (NSString *)faceNameWithFaceImageName:(NSString *)faceImageName;

/**
 *  将文字中带表情的字符处理换成图片显示
 *
 *  @param text 未处理的文字
 *
 *  @return 处理后的文字
 */
+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text;


#pragma mark - 最近表情相关处理

/**
 *  获取最近使用的表情图片
 *
 *  @return
 */
+ (NSArray *)recentFaces;

/**
 *  存储一个最近使用的face
 *
 *  @param dict 包含以下key-value键值对
 *  face_id     表情id
 *  face_name   表情名称
 *  @return 是否存储成功
 */
+ (BOOL)saveRecentFace:(NSDictionary *)dict;


@end
