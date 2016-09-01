//
//  XMNChatConfiguration.h
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#ifndef XMNChatConfiguration_h
#define XMNChatConfiguration_h

#import <UIKit/UIKit.h>

#pragma mark - 相关常量定义

/** 定义view的通用背景色 */
#define XMNVIEW_BACKGROUND_COLOR [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0f]

/** 定义view的border.color */
#define XMNVIEW_BORDER_COLOR [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0f]


#define kXMNChatBundle [NSBundle bundleWithIdentifier:@"com.XMFraker.XMNChatFramework"]

#define kXMNMessageViewMaxWidth (SCREEN_WIDTH - 45 - 32 - 16 - 20 - 32)

#pragma mark - 相关常量定义


static CGFloat const kXMNChatViewHeight = 215.0f;
static CGFloat const kXMNChatViewBottomHeight = 35.0f;
static CGFloat const kXMNChatViewBottomButtonWidth = 60.0f;

/** chatBar最大高度 */
static CGFloat const kXMNChatBarMaxHeight = 117.f;
/** chatBar默认高度 */
static CGFloat const kXMNChatBarHeight = 46.f;

/// ========================================
/// @name   UITableViewCell Identifier
/// ========================================

static NSString *const kXMNChatSystemCellIdentifier = @"com.XMFraker.XMNChat.kXMNChatSystemCellIdentifier";

static NSString *const kXMNChatOwnSingleCellIdentifier = @"com.XMFraker.XMNChat.kXMNChatOwnSingleCellIdentifier";
static NSString *const kXMNChatOwnGroupCellIdentifier = @"com.XMFraker.XMNChat.kXMNChatOwnGroupCellIdentifier";

static NSString *const kXMNChatOtherSingleCellIdentifier = @"com.XMFraker.XMNChat.kXMNChatOtherSingleCellIdentifier";
static NSString *const kXMNChatOtherGroupCellIdentifier = @"com.XMFraker.XMNChat.kXMNChatOtherGroupCellIdentifier";

/// ========================================
/// @name   相关通知定义
/// ========================================

/** 表情相关的通知,删除输入表情,选择表情时发送 */
static NSString *const kXMNChatExpressionNotification = @"com.XMFraker.XMNChat.kXMNChatExpressionNotification";
/** QQEmotion 则为QQ表情对应的文字, GIF表情则为GIF的路径 */
static NSString *const kXMNChatExpressionNotificationDataKey = @"com.XMFraker.XMNChat.kXMNChatExpressionNotificationDataKey";

/** 选择其他的item发出的notification*/
static NSString *const kXMNChatOtherItemNotification = @"com.XMFraker.XMNChat.kXMNChatOtherItemNotification";
/** 发出的notification带有的值 */
static NSString *const kXMNChatOtherItemNotificationDataKey = @"com.XMFraker.XMNChat.kXMNChatOtherItemNotificationDataKey";

/** 点击了文字message区域相关解析区域后的通知 */
static NSString *const kXMNChatMessageClickedNotification = @"com.XMFraker.XMNChat.kXMNChatMessageClickedNotification";
static NSString *const kXMNChatMessageClickedNotificationTextKey = @"com.XMFraker.XMNChat.kXMNChatMessageClickedNotificationTextKey";

#pragma mark - 相关枚举定义

/**
 *  聊天消息的类型
 */
typedef NS_ENUM(NSUInteger, XMNChatMode){
    XMNChatSingle = 0 /**< 单人聊天,不显示nickname */,
    XMNChatGroup /**< 群组聊天,显示nickname */,
};

/** XMNChatExpression 动作类型类型 */
typedef NS_ENUM(NSUInteger, XMNChatExpressionType) {
    /** 发送普通QQ表情 */
    XMNChatExpressionQQEmotion = 0,
    /** 发送GIF表情 */
    XMNChatExpressionGIF,
    /** 删除按钮 执行删除功能 */
    XMNChatExpressionDelete,
    /** 发送按钮 执行发送功能 */
    XMNChatExpressionSend,
};

/** XMNChatBar显示的view类型 */
typedef NS_ENUM(NSUInteger, XMNChatBarShowingView) {
    /** 默认不显示任何view */
    XMNChatShowingNoneView = 0,
    
    /** 新增显示 录音界面 */
    XMNChatShowingVoiceView,
    
    /** 显示了表情选择视图 */
    XMNChatShowingFaceView,
    /** 显示了其他视图 */
    XMNChatShowingOtherView,
    /** 显示了键盘 */
    XMNChatShowingKeyboard,
};

/**
 *  消息拥有者类型
 */
typedef NS_ENUM(NSUInteger, XMNMessageOwner){
    XMNMessageOwnerUnknown = 0 /**< 未知的消息拥有者 */,
    XMNMessageOwnerSystem /**< 系统消息 */,
    XMNMessageOwnerSelf /**< 自己发送的消息 */,
    XMNMessageOwnerOther /**< 接收到的他人消息 */,
};


/**
 *  消息类型
 */
typedef NS_ENUM(NSUInteger, XMNMessageType){
    XMNMessageTypeUnknow = 0 /**< 未知的消息类型 */,
    XMNMessageSystem /**< 系统消息 */,
    XMNMessageTypeText = 100 /**< 文本消息 */,
    XMNMessageTypeImage /**< 图片消息 */,
    XMNMessageTypeVoice /**< 语音消息 */,
    XMNMessageTypeLocation /**< 地理位置消息 */,
};


typedef NS_ENUM(NSUInteger, XMNMessageState) {
    /** 未知的消息装填 */
    XMNMessageUnknown = 0,
    /** 正在发送消息中 */
    XMNMessageStateSending = 10,
    /** 正在接受消息中 */
    XMNMessageStateRecieving,
    /** 消息成功 */
    XMNMessageStateSuccess = 20,
    /** 消息失败 */
    XMNMessageStateFailed,
};

typedef NS_ENUM(NSUInteger, XMNMessageSubState) {
    
    XMNMessageSubStateSendingContent = 30,
    /** 发送消息内容失败 */
    XMNMessageSubStateSendContentFaield,
    /** 发送消息内容成功 */
    XMNMessageSubStateSendContentSuccess,
    /** 接收的消息的内容还没有下载*/
    XMNMessageSubStateUnRecievedContent = 40,
    /** 正在接收消息的内容 */
    XMNMessageSubStateRecievingContent,
    /** 接收消息内容失败 */
    XMNMessageSubStateRecieveContentFailed,
    /** 已成功接收消息的内容 */
    XMNMessageSubStateRecieveContentSuccess,
    /** 正在播放接收的消息内容 */
    XMNMessageSubStatePlayingContent,
    /** 无法播放消息的具体内容 */
    XMNMessageSubStatePlayContentFailed,
    /** 可以播放消息的具体内容 */
    XMNMessageSubStatePlayContentSuccess,
    /** 消息已读 */
    XMNMessageSubStateReadedContent
};

#endif /* XMNChatConfiguration_h */
