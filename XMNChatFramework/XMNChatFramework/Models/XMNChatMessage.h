//
//  XMNChatMessage.h
//  XMNChatFramework
//
//  Created by XMFraker on 16/5/5.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatConfiguration.h"

/**
 *  基础消息类型
 */
@interface XMNChatBaseMessage : NSObject

/** 消息的状态 */
@property (nonatomic, assign) XMNMessageState state;

/** 消息的附加状态 */
@property (nonatomic, assign) XMNMessageSubState substate;

/** 消息的类型 只读 */
@property (nonatomic, assign, readonly) XMNMessageType type;

/** 消息发送者 */
@property (nonatomic, assign) XMNMessageOwner owner;

/** 消息发送的时间 时间戳格式 */
@property (nonatomic, assign) NSTimeInterval time;

/** 消息的内容 */
@property (nonatomic, strong, readonly) id content;

/** 消息拥有者昵称 */
@property (nonatomic, copy)   NSString *nickname;
/** 消息拥有者的头像地址 */
@property (nonatomic, copy)   NSString *avatarUrl;

/**
 *  实例化XMNChatMessage实例
 *
 *  使用此方法初始化 会将time属性 -> 自动设置为当前时间的时间戳
 *  @param aContent 消息内容
 *  @param aState   消息状态
 *  @param aOwner   消息发送者
 *
 *  @return 实例
 */
- (instancetype)initWithContent:(id)aContent
                          state:(XMNMessageState)aState
                          owner:(XMNMessageOwner)aOwner;

/**
 *  实例化XMNChatMessage实例
 *
 *  @param aContent 消息内容
 *  @param aState   消息状态
 *  @param aOwner   消息发送者
 *  @param aTime    消息时间
 *
 *  @return 实例
 */
- (instancetype)initWithContent:(id)aContent
                          state:(XMNMessageState)aState
                          owner:(XMNMessageOwner)aOwner
                           time:(NSTimeInterval)aTime;

@end

@interface XMNChatSystemMessage : XMNChatBaseMessage

/** 消息内容 */
@property (nonatomic, strong, readonly) NSString *content;

@end

@interface XMNChatTextMessage : XMNChatBaseMessage

/** 消息内容 */
@property (nonatomic, strong, readonly) NSString *content;

@end

@interface XMNChatVoiceMessage : XMNChatBaseMessage

/** 语音消息的nsdata */
@property (nonatomic, strong, readonly) NSData *content;
/** 语音消息的路径, 本地 或者网络路径 */
@property (nonatomic, copy)   NSString *voicePath;
/** 语音的时长 */
@property (nonatomic, assign) NSInteger voiceLength;

@end

@interface XMNChatImageMessage : XMNChatBaseMessage

/** 图片消息,NSString or UIImage or NSURL*/
@property (nonatomic, strong, readonly) id content;

/** 图片地址 */
@property (nonatomic, copy, readonly)   NSString *imagePath;

/** 图片 */
@property (nonatomic, strong, readonly) UIImage *image;

/** 图片的大小 默认1:1图片显示  CGSizeMake(kXMNMessageViewMaxWidth,kXMNMessageViewMaxWidth)*/
@property (nonatomic, assign) CGSize imageSize;

@end

@interface XMNChatLocationMessage : XMNChatBaseMessage

/** location的位置 */
@property (nonatomic, strong, readonly) NSString *content;

/** 经度 */
@property (nonatomic, assign) double lat;
/** 纬度 */
@property (nonatomic, assign) double lng;


@end