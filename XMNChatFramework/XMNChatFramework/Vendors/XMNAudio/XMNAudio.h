//
//  XMNAudio.h
//  XMNAudio
//
//  Created by XMFraker on 16/6/23.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for XMNAudio.
FOUNDATION_EXPORT double XMNAudioVersionNumber;

//! Project version string for XMNAudio.
FOUNDATION_EXPORT const unsigned char XMNAudioVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XMNAudio/PublicHeader.h>


#if __has_include(<XMNAudio/XMNAudio.h>)
    #import <XMNAudio/XMNAudioPlayer.h>
    #import <XMNAudio/XMNAudioFile.h>
    #import <XMNAudio/XMNAudioRecorder.h>
#else
    #import "XMNAudioRecorder.h"
    #import "XMNAudioPlayer.h"
    #import "XMNAudioFile.h"
#endif
