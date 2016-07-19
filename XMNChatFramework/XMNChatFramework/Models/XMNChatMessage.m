//
//  XMNChatMessage.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/5/5.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatMessage.h"

#import "YYWebImage.h"
#import "XMNAudioFile.h"

@implementation XMNChatBaseMessage

- (instancetype)initWithContent:(id)aContent
                          state:(XMNMessageState)aState
                          owner:(XMNMessageOwner)aOwner {
    
    return [self initWithContent:aContent
                           state:aState
                           owner:aOwner
                            time:[[NSDate date] timeIntervalSince1970]];
}

- (instancetype)initWithContent:(id)aContent
                          state:(XMNMessageState)aState
                          owner:(XMNMessageOwner)aOwner
                           time:(NSTimeInterval)aTime {
    if (self = [super init]) {
        
        _content = aContent;
        _state = aState;
        _owner = aOwner;
        _time = aTime;
    }
    return self;
}

- (XMNMessageState)state {
    
    switch (_substate) {
        case XMNMessageSubStateSendingContent:
            return XMNMessageStateSending;
        case XMNMessageSubStateRecievingContent:
            return XMNMessageStateRecieving;
        case XMNMessageSubStatePlayContentFailed:
        case XMNMessageSubStateRecieveContentFailed:
        case XMNMessageSubStateSendContentFaield:
            return XMNMessageStateFailed;
        default:
            return _state;
            break;
    }
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"--------XMNChatMessage Start-------\nowner : %@\ntype:%ld\nstate:%ld\ncontent:%@\n--------XMNChatMessage End---------",self.nickname,self.type,self.state,self.content];
}

@end

@implementation XMNChatSystemMessage
@dynamic content;

- (XMNMessageType)type {
    
    return XMNMessageSystem;
}

@end

@implementation XMNChatTextMessage
@dynamic content;

- (XMNMessageType)type {
    
    return XMNMessageTypeText;
}

@end

@implementation XMNChatVoiceMessage
@dynamic content;

- (XMNMessageType)type {
    
    return XMNMessageTypeVoice;
}

- (NSString *)voicePath {
    
    if (_voicePath) {
        return _voicePath;
    }
    if ([self.content isKindOfClass:[NSString class]]) {
        return (NSString *)self.content;
    }else if ([self.content isKindOfClass:[NSURL class]]) {
        
        return [(NSURL *)self.content absoluteString];
    }
    return nil;
}

- (NSURL *)audioFileURL {
    
    if (!self.voicePath) {
        return nil;
    }
    if ([self.voicePath hasPrefix:@"http"]) {
        return [NSURL URLWithString:self.voicePath];
    }
    return [NSURL fileURLWithPath:self.voicePath];
}


- (AudioFileTypeID)fileTypeID {
    
    if (![self audioFileURL]) {
        return 0;
    }
    if ([[[self audioFileURL] pathExtension] isEqualToString:@"mp3"]) {
        return kAudioFileMP3Type;
    }else if ([[[self audioFileURL] pathExtension] isEqualToString:@"amr"]) {
        return kAudioFileAMRType;
    }
    return 0;
}

@end

@implementation XMNChatImageMessage
@dynamic content;


- (XMNMessageType)type {
    
    return XMNMessageTypeImage;
}

- (NSString *)imagePath {
    
    if ([self.content isKindOfClass:[NSString class]]) {
        return self.content;
    }else if ([self.content isKindOfClass:[NSURL class]]) {
        
        return [(NSURL *)self.content absoluteString];
    }
    return nil;
}


- (UIImage *)image {
    
    if ([self.content isKindOfClass:[UIImage class]]) {
        
        return self.content;
    }else if ([self.content isKindOfClass:[NSString class]]) {
        
        return [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:self.content]]];
    }else if ([self.content isKindOfClass:[NSURL class]]) {
        
        return [[YYWebImageManager sharedManager].cache getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:self.content]];
    }
    return nil;
}

- (CGSize)imageSize {
    
    if (CGSizeEqualToSize(_imageSize, CGSizeZero) || CGSizeEqualToSize(_imageSize, CGSizeMake(kXMNMessageViewMaxWidth/2, kXMNMessageViewMaxWidth/2))) {
        if (self.image) {
            _imageSize  = self.image.size;
        }else {
            return CGSizeMake(kXMNMessageViewMaxWidth/2, kXMNMessageViewMaxWidth/2);
        }
    }
    return _imageSize;
}

@end

@implementation XMNChatLocationMessage
@dynamic content;


- (XMNMessageType)type {
    
    return XMNMessageTypeLocation;
}

@end

