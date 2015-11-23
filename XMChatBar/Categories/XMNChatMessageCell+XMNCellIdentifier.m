//
//  UITableViewCell+XMNCellIdentifier.m
//  XMChatBarExample
//
//  Created by shscce on 15/11/23.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatMessageCell+XMNCellIdentifier.h"

@implementation XMNChatMessageCell (XMNCellIdentifier)

/**
 *  用来获取cellIdentifier
 *
 *  @param messageConfiguration 消息类型,需要传入两个key
 *  kXMNMessageConfigurationTypeKey     代表消息的类型
 *  kXMNMessageConfigurationOwnerKey    代表消息的所有者
 */
+ (NSString *)cellIdentifierForMessageConfiguration:(NSDictionary *)messageConfiguration {
    XMNMessageType messageType = [messageConfiguration[kXMNMessageConfigurationTypeKey] integerValue];
    XMNMessageOwner messageOwner = [messageConfiguration[kXMNMessageConfigurationOwnerKey] integerValue];
    XMNMessageChat messageChat = [messageConfiguration[kXMNMessageConfigurationGroupKey] integerValue];
    NSString *identifierKey = @"XMNChatMessageCell";
    NSString *ownerKey;
    NSString *typeKey;
    NSString *groupKey;
    switch (messageOwner) {
        case XMNMessageOwnerSystem:
            ownerKey = @"OwnerSystem";
            break;
        case XMNMessageOwnerOther:
            ownerKey = @"OwnerOther";
            break;
        case XMNMessageOwnerSelf:
            ownerKey = @"OwnerSelf";
            break;
        default:
            NSAssert(NO, @"Message Owner Unknow");
            break;
    }
    switch (messageType) {
        case XMNMessageTypeVoice:
            typeKey = @"VoiceMessage";
            break;
        case XMNMessageTypeImage:
            typeKey = @"ImageMessage";
            break;
        case XMNMessageTypeLocation:
            typeKey = @"LocationMessage";
            break;
        case XMNMessageTypeSystem:
            typeKey = @"SystemMessage";
            break;
        case XMNMessageTypeText:
            typeKey = @"TextMessage";
            break;
        default:
            NSAssert(NO, @"Message Type Unknow");
            break;
    }
    switch (messageChat) {
        case XMNMessageChatGroup:
            groupKey = @"GroupCell";
            break;
        case XMNMessageChatSingle:
            groupKey = @"SingleCell";
            break;
        default:
            groupKey = @"";
            break;
    }
    
    return [NSString stringWithFormat:@"%@_%@_%@_%@",identifierKey,ownerKey,typeKey,groupKey];
}


@end
