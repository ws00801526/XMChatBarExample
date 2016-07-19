//
//  XMNHTTPRequest.m
//  XMNAudio
//
//  Created by XMFraker on 16/7/6.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNHTTPRequest.h"
//#import "XMNAudioConfiguration.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <pthread.h>

#import <UIKit/UIDevice.h>

static  NSURLSession *kXMNAudioDownloadSession;

@interface XMNHTTPRequest () <NSURLSessionDataDelegate> {
    
    CFAbsoluteTime _lastTime;
    NSMutableData *_responseData;
    NSMutableData *_bufferData;
    NSUInteger    _receivedLength;
    NSUInteger    _lastReceivedLength;
    NSTimeInterval   _updateFrequency;
    NSURLSession *_session;
}

@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation XMNHTTPRequest
@synthesize timeoutInterval = _timeoutInterval;
@synthesize updateFrequency = _updateFrequency;
@synthesize userAgent = _userAgent;

@synthesize responseData = _responseData;
@synthesize responseString = _responseString;

@synthesize responseHeaders = _responseHeaders;
@synthesize responseContentLength = _responseContentLength;
@synthesize statusCode = _statusCode;
@synthesize statusMessage = _statusMessage;

@synthesize downloadSpeed = _downloadSpeed;
@synthesize failed = _failed;

@synthesize completedBlock = _completedBlock;
@synthesize progressBlock = _progressBlock;
@synthesize didReceiveResponseBlock = _didReceiveResponseBlock;
@synthesize didReceiveDataBlock = _didReceiveDataBlock;

#pragma mark - Life Cycle
+ (instancetype)requestWithURL:(NSURL *)url {
    
    if (url == nil) {
        return nil;
    }
    return [[[self class] alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    
    
    if (self = [super init]) {
        
        _URL = url;
        _userAgent = [[self class] defaultUserAgent];
        _timeoutInterval = [[self class] defaultTimeoutInterval];
        _updateFrequency = [[self class] defaultUpdateFrequency];
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            
//        });
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = _timeoutInterval;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
    [self cancel];
}


#pragma mark - Methods

- (void)start {
    
    if (!_session) {
        return;
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeoutInterval];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    if (self.host) {
        [request setValue:self.host forHTTPHeaderField:@"Host"];
    }
    
    if (_responseData == nil) {
        _responseData = [NSMutableData data];
    }
    
    if (_bufferData == nil) {
        _bufferData = [NSMutableData data];
    }
    
    self.task = [_session dataTaskWithRequest:request];
    [self.task resume];
    _lastTime = CFAbsoluteTimeGetCurrent();
    _downloadSpeed = _receivedLength = _lastReceivedLength = 0;
}


- (void)cancel {
    
    if (_failed) {
        return;
    }
    if (self.task) {
        [self.task cancel];
    }
}


- (void)updateProgressAndSpeed {
    
    if ((CFAbsoluteTimeGetCurrent() - _lastTime) >= _updateFrequency) {
        double downloadProgress;
        if (_responseContentLength == 0) {
            if (_responseHeaders != nil) {
                downloadProgress = 1.0;
            }
            else {
                downloadProgress = 0.0;
            }
        } else {
            downloadProgress = (double)_receivedLength / _responseContentLength;
        }
        _downloadSpeed = _lastReceivedLength / (CFAbsoluteTimeGetCurrent() - _lastTime);
        _lastTime = CFAbsoluteTimeGetCurrent();
        _lastReceivedLength = .0f;
        NSLog(@"current down load progress %.2f\nspeed :%.2f b/s",downloadProgress,_downloadSpeed / 1024.f);
        
        @synchronized (self) {
            _progressBlock ? _progressBlock(downloadProgress) : nil;
        }
    }
}

#pragma mark - NSURLSessionDataTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    if (_responseData == nil) {
        _responseData = [NSMutableData data];
    }

    [_responseData appendData:data];
    _receivedLength += data.length;
    _lastReceivedLength += data.length;
    
    //    NSLog(@"length :%lu",data.length);
    [self updateProgressAndSpeed];
    
//    if (_bufferData.length >= 16384 || _receivedLength >= _responseContentLength) {
//        
//    }
//    if (_bufferData == nil) {
//        _bufferData = [NSMutableData data];
//    }
//    [_bufferData appendData:data];

    NSData *blockData = [NSData dataWithBytesNoCopy:(void *)[data bytes] length:[data length] freeWhenDone:NO];
    @synchronized (self) {
        self.didReceiveDataBlock ? self.didReceiveDataBlock(blockData) : nil;
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    
    if (dataTask.error) {
        _failed = YES;
        return;
    }
    NSLog(@"get response");
    _statusCode = response.statusCode;
    _statusMessage = [NSHTTPURLResponse localizedStringForStatusCode:_statusCode];
    _responseHeaders = response.allHeaderFields;
    _responseContentLength = response.allHeaderFields[@"Content-Length"] ? [response.allHeaderFields[@"Content-Length"] integerValue] : 0;
    completionHandler(NSURLSessionResponseAllow);
    
    @synchronized (self) {
        _didReceiveResponseBlock ? _didReceiveResponseBlock() : nil;
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    NSLog(@"finish request");
    if (error) {
        _failed = YES;
    }
    @synchronized (self) {
        _completedBlock ? _completedBlock(error) : nil;
    }
}
#pragma mark - Getters

- (NSString *)responseString {
    
    if (_responseData == nil) {
        return nil;
    }
    if (_responseString == nil) {
        _responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    }
    return _responseString;
}

- (BOOL)isFailed {
    
    return _failed;
}

#pragma mark - Class Methods

+ (NSTimeInterval)defaultTimeoutInterval {
    
    return 20.0;
}

+ (NSTimeInterval)defaultUpdateFrequency {
    
    return .5f;
}

+ (NSString *)defaultUserAgent {
    
    static NSString *defaultUserAgent = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [infoDict objectForKey:@"CFBundleName"];
        NSString *shortVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        NSString *bundleVersion = [infoDict objectForKey:@"CFBundleVersion"];
        
        NSString *deviceName = nil;
        NSString *systemName = nil;
        NSString *systemVersion = nil;
        
#if TARGET_OS_IPHONE
        
        UIDevice *device = [UIDevice currentDevice];
        deviceName = [device model];
        systemName = [device systemName];
        systemVersion = [device systemVersion];
        
#else /* TARGET_OS_IPHONE */
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        SInt32 versionMajor, versionMinor, versionBugFix;
        Gestalt(gestaltSystemVersionMajor, &versionMajor);
        Gestalt(gestaltSystemVersionMinor, &versionMinor);
        Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
#pragma clang diagnostic pop
        
        int mib[2] = { CTL_HW, HW_MODEL };
        size_t len = 0;
        sysctl(mib, 2, NULL, &len, NULL, 0);
        char *hw_model = malloc(len);
        sysctl(mib, 2, hw_model, &len, NULL, 0);
        deviceName = [NSString stringWithFormat:@"Macintosh %s", hw_model];
        free(hw_model);
        
        systemName = @"Mac OS X";
        systemVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
        
#endif /* TARGET_OS_IPHONE */
        
        NSString *locale = [[NSLocale currentLocale] localeIdentifier];
        defaultUserAgent = [NSString stringWithFormat:@"%@ %@ build %@ (%@; %@ %@; %@)", appName, shortVersion, bundleVersion, deviceName, systemName, systemVersion, locale];
    });
    
    return defaultUserAgent;
}

@end
