//
//  XMMessage.h
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息拥有者类型
 */
typedef NS_ENUM(NSUInteger, XMMessageOwnerType){
    XMMessageOwnerTypeUnknown = 0 /**< 未知的消息拥有者 */,
    XMMessageOwnerTypeSystem /**< 系统消息 */,
    XMMessageOwnerTypeSelf /**< 自己发送的消息 */,
    XMMessageOwnerTypeOther /**< 接收到的他人消息 */,
};


/**
 *  消息聊天类型
 */
typedef NS_ENUM(NSUInteger, XMMessageChatType){
    XMMessageChatSingle = 0 /**< 单人聊天,不显示nickname */,
    XMMessageChatGroup /**< 群组聊天,显示nickname */,
};

/**
 *  消息类型
 */
typedef NS_ENUM(NSUInteger, XMMessageType){
    XMMessageTypeUnknow = 0 /**< 未知的消息类型 */,
    XMMessageTypeSystem /**< 系统消息 */,
    XMMessageTypeText /**< 文本消息 */,
    XMMessageTypeImage /**< 图片消息 */,
    XMMessageTypeVoice /**< 语音消息 */,
    XMMessageTypeLocation /**< 地理位置消息 */,
};

/**
 *  消息发送状态,自己发送的消息时有
 */
typedef NS_ENUM(NSUInteger, XMMessageSendState){
    XMMessageSendSuccess = 0 /**< 消息发送成功 */,
    XMMessageSendFail /**< 消息发送失败 */,
};

/**
 *  消息读取状态,接收的消息时有
 */
typedef NS_ENUM(NSUInteger, XMMessageReadState) {
    XMMessageUnRead = 0 /**< 消息未读 */,
    XMMessageReaded /**< 消息已读 */,
};



@class XMSystemMessage,XMTextMessage,XMImageMessage,XMLocationMessage,XMVoiceMessage;
@interface XMMessage : NSObject

@property (copy, nonatomic) NSString *messageText /**< 消息文字 */;
@property (assign, nonatomic) XMMessageOwnerType messageOwner /**< 消息发送者 */;
@property (assign, nonatomic) XMMessageType messageType /**< 消息类型 */;
@property (assign, nonatomic) XMMessageSendState messageSendState /**< 消息状态 */;
@property (assign, nonatomic) XMMessageReadState messageReadState /**< 消息状态 */;

@property (assign, nonatomic) XMMessageChatType messageChatType /**< 聊天类型,单人聊天信息,群组聊天信息 */;

@property (assign, nonatomic) NSTimeInterval messageTime /**< 消息发送时间 */;

@property (copy, nonatomic) NSString *senderNickName /**< 消息发送者昵称 */;
@property (copy, nonatomic) NSString *senderAvatarThumb /**< 消息发送者头像 */;


#pragma mark - Class Methods


/**
 *  获取一个message实例
 *
 *  @param messageInfo                          消息内容,包括以下key
 *  @param messageOwner(XMMessageOwnerType)     消息拥有者      必须
 *  @param messageTime(NSTimeInterval)          消息事件        必须
 *  @param messageText(NSString)                消息内容        必须
 *  @param senderNickName(NSString)             发送者昵称      必须
 *  @param senderAvatarThumb(NSString)          发送者头像      必须
 *  @param messageSendState(XMMessageSendState) 消息发送状态    非必须
 *
 *  @return XMTextMessage类型实例
 */
+ (XMTextMessage *)textMessage:(NSDictionary *)messageInfo;

/**
 *  获取一个message实例
 *
 *  @param messageInfo                          消息内容,包括以下key
 *  @param messageOwner(XMMessageOwnerType)     消息拥有者       必须
 *  @param messageTime(NSTimeInterval)          消息事件        必须
 *  @param image(NSData,NSString)               消息图片        必须
 *  @param messageText                          消息内容        非必须
 *  @param senderNickName(NSString)             发送者昵称      必须
 *  @param senderAvatarThumb(NSString)          发送者头像      必须
 *  @param messageSendState(XMMessageSendState) 消息发送状态    非必须
 *
 *  @return XMImageMessage类型实例
 */
+ (XMImageMessage *)imageMessage:(NSDictionary *)messageInfo;

/**
 *  获取一个message实例
 *
 *  @param messageInfo                          消息内容,包括以下key
 *  @param messageTime(NSTimeInterval)          消息事件        必须
 *  @param messageText(NSString)                消息内容        非必须
 *  @return XMSystemMessage类型实例
 */
+ (XMSystemMessage *)systemMessage:(NSDictionary *)messageInfo;

/**
 *  获取一个message实例
 *
 *  @param messageInfo                          消息内容,包括以下key
 *  @param messageOwner(XMMessageOwnerType)     消息拥有者       必须
 *  @param messageTime(NSTimeInterval)          消息事件        必须
 *  @param lat(double)                          消息经度        必须
 *  @param lng(double)                          消息纬度        必须
 *  @param address(NSString)                    消息地址        非必须
 *  @param messageText(NSString)                消息内容        非必须
 *  @param senderNickName(NSString)             发送者昵称      必须
 *  @param senderAvatarThumb(NSString)          发送者头像      必须
 *  @param messageSendState(XMMessageSendState) 消息发送状态    非必须
 *
 *  @return XMImageMessage类型实例
 */
+ (XMLocationMessage *)locationMessage:(NSDictionary *)messageInfo;

/**
 *  获取一个message实例
 *
 *  @param messageInfo                          消息内容,包括以下key
 *  @param messageOwner(XMMessageOwnerType)     消息拥有者       必须
 *  @param messageTime(NSTimeInterval)          消息时间        必须
 *  @param voiceData(NSData,NSString)           消息录音        必须
 *  @param messageText(NSString)                消息内容        非必须
 *  @param senderNickName(NSString)             发送者昵称      必须
 *  @param senderAvatarThumb(NSString)          发送者头像      必须
 *  @param messageSendState(XMMessageSendState) 消息发送状态    非必须
 *  @param messageReadState(XMMessageReadState) 消息读取状态    非必须
 *
 *  @return XMImageMessage类型实例
 */
+ (XMVoiceMessage *)voiceMessage:(NSDictionary *)messageInfo;

@end


@class XMImageMessage,XMVoiceMessage;


@protocol XMVoiceMessageStatus <NSObject>

@required
- (void)startPlaying;
- (void)stopPlaying;
- (BOOL)isPlaying;
@end

@protocol XMMessageDelegate <NSObject>

/**
 *  图片消息被点击
 *
 *  @param imageMessage 被点击的图片消息
 */
- (void)XMImageMessageTapped:(XMImageMessage *)imageMessage;

/**
 *  语音消息呗点击
 *
 *  @param voiceMessage 被点击的语音消息
 *  @param voiceStatus  语音消息时长
 */
- (void)XMVoiceMessageTapped:(XMVoiceMessage *)voiceMessage voiceStatus:(id<XMVoiceMessageStatus>)voiceStatus;

/**
 *  头像被点击了
 *
 *  @param message 被点击的消息
 */
- (void)XMMessageAvatarTapped:(XMMessage *)message;

/**
 *  空白区域被点击了
 *
 *  @param message 被点击的消息
 */
- (void)XMMessageBankTapped:(XMMessage *)message;

@end
