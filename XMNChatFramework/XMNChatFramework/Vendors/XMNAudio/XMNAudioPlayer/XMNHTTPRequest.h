//
//  XMNHTTPRequest.h
//  XMNAudio
//
//  Created by XMFraker on 16/7/6.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMNHTTPRequest : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/** 更新progress,downloadSpeed的频率  默认.5f */
@property (nonatomic, assign) NSTimeInterval updateFrequency;

@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *host;

@property (nonatomic, readonly) NSData *responseData;
@property (nonatomic, readonly) NSString *responseString;

@property (nonatomic, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSUInteger responseContentLength;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSString *statusMessage;

@property (nonatomic, readonly) double downloadSpeed;
@property (nonatomic, readonly, getter=isFailed) BOOL failed;

@property (copy) void(^completedBlock)(NSError *error);
@property (copy) void(^progressBlock)(double progress);
@property (copy) void(^didReceiveResponseBlock)();
@property (copy) void(^didReceiveDataBlock)(NSData *data);

+ (instancetype)requestWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

- (void)start;
- (void)cancel;

+ (NSTimeInterval)defaultTimeoutInterval;
+ (NSString *)defaultUserAgent;
+ (NSTimeInterval)defaultUpdateFrequency;

@end
