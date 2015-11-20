//
//  UIImageView+XMWebImage.m
//  XMChatBarExample
//
//  Created by shscce on 15/9/14.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "UIImageView+XMWebImage.h"

@interface XMNWebImageCache : NSObject

@property (nonatomic, copy, readonly) NSString *cachePath;
@property (nonatomic, strong) NSCache *memoryCache;

+ (instancetype)shareCache;

@end

@implementation XMNWebImageCache
@synthesize cachePath = _cachePath;

+ (instancetype)shareCache {
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if ([super init]) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = 100;
        _memoryCache.totalCostLimit = 1024 * 1024 * 10;
    }
    return self;
}

#pragma mark - Getters

- (NSString *)cachePath {
    if (!_cachePath) {
        _cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"com.XMFraker.XMNChat.imageCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _cachePath;
}

@end


@implementation UIImageView (XMWebImage)

- (void)setImageWithUrlString:(NSString *)urlString{
    if (!urlString) {
        return;
    }
    dispatch_async(dispatch_queue_create("pic", nil), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = [UIImage imageWithData:data];
        });
    });
}

@end
