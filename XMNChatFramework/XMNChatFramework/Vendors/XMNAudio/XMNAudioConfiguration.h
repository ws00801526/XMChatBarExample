//
//  XMNAudioConfiguration.h
//  XMNAudioRecorder
//
//  Created by XMFraker on 16/6/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#ifndef XMNAudioConfiguration_h
#define XMNAudioConfiguration_h

#pragma mark - 相关宏定义

/// ========================================
/// @name   个人使用的打印日志
/// ========================================

#ifndef XMNLog
    #if DEBUG
        #define XMNLog(FORMAT,...) fprintf(stderr,"==============================================================\n=           com.XMFraker.XMNLog                              =\n==============================================================\n\n\n%s %d :\n       %s\n\n\n==============================================================\n=           com.XMFraker.XMNLog End                          =\n==============================================================\n\n\n\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
    #else
        #define XMNLog(FORMAT,...);
    #endif
#endif

/// ========================================
/// @name   相关版本宏
/// ========================================

#ifndef iOS7Later
    #define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#endif

#ifndef iOS8Later
    #define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#endif

#ifndef iOS9Later
    #define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#endif

#ifndef iOS10Later
    #define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#endif

static NSString *kXMNAudioPlayerErrorDomain = @"com.XMFraker.XMNAudioRecorder.kXMNAudioPlayerErrorDomain";
static NSString *kXMNAudioRecorderErrorDomain = @"com.XMFraker.XMNAudioRecorder.kXMNAudioRecorderErrorDomain";

#endif /* XMNAudioConfiguration_h */
