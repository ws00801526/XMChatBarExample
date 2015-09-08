//
//  XMMessage.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMMessage.h"

#import "XMSystemMessage.h"
#import "XMTextMessage.h"
#import "XMImageMessage.h"
#import "XMVoiceMessage.h"
#import "XMLocationMessage.h"

@implementation XMMessage

- (instancetype)init{
    if ([super init]) {
        self.messageType = XMMessageTypeUnknow;
    }
    return self;
}



+ (XMTextMessage *)textMessage:(NSDictionary *)messageInfo{
    XMTextMessage *textMessage = [[XMTextMessage alloc] init];
    textMessage.messageOwner = [messageInfo[@"messageOwner"] integerValue];
    textMessage.messageText = messageInfo[@"messageText"];
    textMessage.messageTime = [messageInfo[@"messageTime"] doubleValue];
    textMessage.senderAvatarThumb = messageInfo[@"senderAvatarThumb"];
    textMessage.senderNickName = messageInfo[@"senderNickName"];
    return textMessage;
}


+ (XMImageMessage *)imageMessage:(NSDictionary *)messageInfo{
    XMImageMessage *imageMessage = [[XMImageMessage alloc] init];
    imageMessage.messageOwner = [messageInfo[@"messageOwner"] integerValue];
    imageMessage.messageText = messageInfo[@"messageText"];
    imageMessage.messageTime = [messageInfo[@"messageTime"]doubleValue];
    imageMessage.senderAvatarThumb = messageInfo[@"senderAvatarThumb"];
    imageMessage.senderNickName = messageInfo[@"senderNickName"];
    id image = messageInfo[@"image"];
    if ([image isKindOfClass:[UIImage class]]) {
        imageMessage.image = image;
    }else if ([image isKindOfClass:[NSString class]]){
        if ([image hasPrefix:@"http://"]) {
            imageMessage.imageUrlString = image;
        }else{
            imageMessage.image = [UIImage imageNamed:image];
        }
    }
    return imageMessage;
}

+ (XMSystemMessage *)systemMessage:(NSDictionary *)messageInfo{
    XMSystemMessage *systemMessage = [[XMSystemMessage alloc] init];
    systemMessage.messageTime = [messageInfo[@"messageTime"] doubleValue];
    NSString *messageText = messageInfo[@"messageText"];
    if (messageText) {
        systemMessage.messageText = messageText;
    }else{
        systemMessage.messageText = [[NSDate dateWithTimeIntervalSince1970:systemMessage.messageTime] description];
    }
    return systemMessage;
}

+ (XMLocationMessage *)locationMessage:(NSDictionary *)messageInfo{
    XMLocationMessage *locationMesssage = [[XMLocationMessage alloc] init];
    locationMesssage.messageOwner = [messageInfo[@"messageOwner"] integerValue];;
    locationMesssage.messageTime = [messageInfo[@"messageTime"] doubleValue];
    locationMesssage.address = messageInfo[@"address"];
    locationMesssage.senderAvatarThumb = messageInfo[@"senderAvatarThumb"];
    locationMesssage.senderNickName = messageInfo[@"senderNickName"];
    return locationMesssage;
}

+ (XMVoiceMessage *)voiceMessage:(NSDictionary *)messageInfo{
    XMVoiceMessage *voiceMessage = [[XMVoiceMessage alloc] init];
    voiceMessage.voiceSeconds = [messageInfo[@"voiceSeconds"] integerValue];
    voiceMessage.messageOwner = [messageInfo[@"messageOwner"] integerValue];;
    voiceMessage.messageTime = [messageInfo[@"messageTime"] doubleValue];
    voiceMessage.senderAvatarThumb = messageInfo[@"senderAvatarThumb"];
    voiceMessage.senderNickName = messageInfo[@"senderNickName"];
    id voice = messageInfo[@"voiceData"];
    if ([voice isKindOfClass:[NSData class]]) {
        voiceMessage.voiceData = voice;
    }else{
        voiceMessage.voiceUrlString = voice;
    }
    return voiceMessage;
}

@end
