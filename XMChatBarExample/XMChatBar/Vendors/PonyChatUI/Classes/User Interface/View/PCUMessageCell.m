//
//  PCUMessageCell.m
//  PonyChatUIV2
//
//  Created by 崔 明辉 on 15/7/7.
//  Copyright (c) 2015年 PonyCui. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "PCUMessageInteractor.h"
#import "PCUTextMessageItemInteractor.h"
#import "PCUSystemMessageItemInteractor.h"
#import "PCUImageMessageItemInteractor.h"
#import "PCUVoiceMessageItemInteractor.h"
#import "PCUMessageCell.h"
#import "PCUTextMessageCell.h"
#import "PCUSystemMessageCell.h"
#import "PCUImageMessageCell.h"
#import "PCUVoiceMessageCell.h"

@interface PCUMessageCell ()<ASImageCacheProtocol, ASImageDownloaderProtocol>

@property (nonatomic, strong) ASNetworkImageNode *avatarImageNode;

@property (nonatomic, copy) NSDictionary *avatarCacheObject;

@end

@implementation PCUMessageCell

+ (PCUMessageCell *)cellForMessageInteractor:(PCUMessageItemInteractor *)messageInteractor {
    if ([messageInteractor isKindOfClass:[PCUTextMessageItemInteractor class]]) {
        return [[PCUTextMessageCell alloc] initWithMessageInteractor:messageInteractor];
    }
    else if ([messageInteractor isKindOfClass:[PCUSystemMessageItemInteractor class]]) {
        return [[PCUSystemMessageCell alloc] initWithMessageInteractor:messageInteractor];
    }
    else if ([messageInteractor isKindOfClass:[PCUImageMessageItemInteractor class]]) {
        return [[PCUImageMessageCell alloc] initWithMessageInteractor:messageInteractor];
    }
    else if ([messageInteractor isKindOfClass:[PCUVoiceMessageItemInteractor class]]) {
        return [[PCUVoiceMessageCell alloc] initWithMessageInteractor:messageInteractor];
    }
    else {
        return [[PCUMessageCell alloc] initWithMessageInteractor:messageInteractor];
    }
}

- (instancetype)initWithMessageInteractor:(PCUMessageItemInteractor *)messageInteractor
{
    self = [super init];
    if (self) {
        [super setSelectionStyle:UITableViewCellSelectionStyleNone];
        _messageInteractor = messageInteractor;
        if (![self isKindOfClass:[PCUSystemMessageCell class]]) {
            [self addSubnode:self.avatarImageNode];
        }
    }
    return self;
}

#pragma mark - Node

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize {
    return CGSizeMake(constrainedSize.width, kAvatarSize + kCellGaps);
}

- (void)layout {
    if (self.actionType == PCUMessageActionTypeSend) {
        self.avatarImageNode.frame = CGRectMake(self.calculatedSize.width - 10 - kAvatarSize, 5, kAvatarSize, kAvatarSize);
    }
    else if (self.actionType == PCUMessageActionTypeReceive) {
        self.avatarImageNode.frame = CGRectMake(10, 5, kAvatarSize, kAvatarSize);
    }
    else {
        self.avatarImageNode.frame = CGRectZero;
    }
}

#pragma mark - Getter

- (ASNetworkImageNode *)avatarImageNode {
    if (_avatarImageNode == nil) {
        _avatarImageNode = [[ASNetworkImageNode alloc] initWithCache:self downloader:self];
        _avatarImageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
        _avatarImageNode.URL = [NSURL URLWithString:self.messageInteractor.avatarURLString];
    }
    return _avatarImageNode;
}

- (PCUMessageActionType)actionType {
    if (self.messageInteractor.ownSender) {
        return PCUMessageActionTypeSend;
    }
    else {
        return PCUMessageActionTypeReceive;
    }
}

#pragma mark - ASImage Cache and Downloader

- (void)fetchCachedImageWithURL:(NSURL *)URL callbackQueue:(dispatch_queue_t)callbackQueue completion:(void (^)(CGImageRef))completion {
    NSData *data = [self.avatarCacheObject valueForKey:URL.absoluteString];
    if (data != nil) {
        CGImageRef imageRef = [[UIImage imageWithData:data] CGImage];
        CFRetain(imageRef);
        if (imageRef != nil) {
            [self.avatarCacheObject setValue:data forKey:URL.absoluteString];
            dispatch_async(callbackQueue, ^{
                completion(imageRef);
            });
        }
        else {
            dispatch_async(callbackQueue, ^{
                completion(nil);
            });
        }
    }
    else {
        dispatch_async(callbackQueue, ^{
            completion(nil);
        });
    }
}

- (id)downloadImageWithURL:(NSURL *)URL callbackQueue:(dispatch_queue_t)callbackQueue downloadProgressBlock:(void (^)(CGFloat))downloadProgressBlock completion:(void (^)(CGImageRef, NSError *))completion {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil && [data isKindOfClass:[NSData class]]) {
            CGImageRef imageRef = [[UIImage imageWithData:data] CGImage];
            CFRetain(imageRef);
            if (imageRef != nil) {
                [self.avatarCacheObject setValue:data forKey:URL.absoluteString];
                dispatch_async(callbackQueue, ^{
                    completion(imageRef, nil);
                });
            }
            else {
                dispatch_async(callbackQueue, ^{
                    completion(nil, [NSError errorWithDomain:@"CGImage" code:-1 userInfo:nil]);
                });
                
            }
        }
        else {
            dispatch_async(callbackQueue, ^{
                completion(nil, connectionError);
            });
        }
    }];
    return nil;
}

- (void)cancelImageDownloadForIdentifier:(id)downloadIdentifier {
    
}

@end
