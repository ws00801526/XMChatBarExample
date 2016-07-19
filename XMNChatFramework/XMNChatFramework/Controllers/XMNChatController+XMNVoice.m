//
//  XMNChatController+XMNVoice.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatController+XMNVoice.h"
#import "XMNChatController_Private.h"

#import "XMNAudio.h"
#import "XMNChatRecordProgressHUD.h"

#import <objc/runtime.h>

@interface XMNChatController (XMNVoicePrivate)

@property (nonatomic, strong) XMNAudioPlayer *player;
@property (nonatomic, strong, readonly) XMNAudioRecorder *recorder;
@property (nonatomic, assign, getter=isCancel) BOOL cancel;

@end

@implementation XMNChatController (XMNVoice)



#pragma mark - Override Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(XMNAudioPlayer *)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    XMNChatVoiceMessage *voiceMessage = object.audioFile;
    switch (self.player.status) {
        case XMNAudioPlayerStatusBuffering:
            voiceMessage.substate = XMNMessageSubStateRecievingContent;
            break;
        case XMNAudioPlayerStatusPlaying:
            voiceMessage.substate = XMNMessageSubStatePlayingContent;
            break;
        case XMNAudioPlayerStatusError:
            voiceMessage.substate = XMNMessageSubStateRecieveContentFailed;
            voiceMessage.state = XMNMessageStateFailed;
            break;
        default:
            voiceMessage.substate = XMNMessageSubStateReadedContent;
            [self stopPlaying];
            break;
    }
}


#pragma mark - Methods

/// ========================================
/// @name   Public Methods
/// ========================================

- (void)setupVoiceUI {
    
    [self.chatBar.voiceRecordButton addTarget:self action:@selector(handleRecording:) forControlEvents:UIControlEventTouchDown];
    [self.chatBar.voiceRecordButton addTarget:self action:@selector(hanldeRecordFinished:) forControlEvents:UIControlEventTouchUpInside];
    [self.chatBar.voiceRecordButton addTarget:self action:@selector(handleRecordCanceled:) forControlEvents:UIControlEventTouchUpOutside];

    
    [self.chatBar.voiceRecordButton addTarget:self action:@selector(handleReleaseRecordState:) forControlEvents:UIControlEventTouchDragEnter];
    [self.chatBar.voiceRecordButton addTarget:self action:@selector(handleCancelRecordState:) forControlEvents:UIControlEventTouchDragExit];
}

- (void)playVoiceMessage:(XMNChatVoiceMessage *)aMessage {
    
    
    if (aMessage == self.player.audioFile) {
        [self stopPlaying];
        return;
    }
    [self stopPlaying];
    
    self.player = [XMNAudioPlayer playerWithAudioFile:(id<XMNAudioFile>)aMessage];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
}

- (void)stopPlaying {
    
    if (self.player) {
        [(XMNChatVoiceMessage *)self.player.audioFile setSubstate:XMNMessageSubStateReadedContent];
        [self.player stop];
        [self.player removeObserver:self forKeyPath:@"status"];
        self.player = nil;
    }
}

- (void)clean {
    
    objc_removeAssociatedObjects(self);
}

#pragma mark - Button Events

- (void)handleRecording:(UIButton *)button {
    
    [XMNChatRecordProgressHUD show];
    [self.recorder startRecording];
    button.backgroundColor = RGB(211, 211, 211);
    button.layer.borderColor = RGB(191, 191, 191).CGColor;
}

- (void)hanldeRecordFinished:(UIButton *)button {
    
    self.cancel = NO;
    [self.recorder stopRecording];
    button.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    button.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
}

- (void)handleRecordCanceled:(UIButton *)button {
    
    self.cancel = YES;
    [self.recorder stopRecording];
    button.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    button.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
}

- (void)handleReleaseRecordState:(UIButton *)button {
    
    [XMNChatRecordProgressHUD changeSubTitle:@"上滑取消录音"];
}

- (void)handleCancelRecordState:(UIButton *)button {
    
    [XMNChatRecordProgressHUD changeSubTitle:@"松开取消录音"];
}


#pragma mark - Setters

- (void)setCancel:(BOOL)cancel {
    
    if (self.isCancel != cancel) {
        objc_setAssociatedObject(self, &kXMNChatAudioRecorderCancelKey, @(cancel), OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)setPlayer:(XMNAudioPlayer *)player {
    
    objc_setAssociatedObject(self, &kXMNChatAudioPlayerKey, player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getters

static NSString *kXMNChatAudioPlayerKey;
- (XMNAudioPlayer *)player {
    
    return objc_getAssociatedObject(self, &kXMNChatAudioPlayerKey);
}

static NSString *kXMNChatAudioRecorderKey;
- (XMNAudioRecorder *)recorder {
    
    XMNAudioRecorder *recorder = objc_getAssociatedObject(self, &kXMNChatAudioRecorderKey);
    
    if (!recorder) {
        recorder = [[XMNAudioRecorder alloc] init];
        recorder.encoderType = XMNAudioEncoderTypeAMR;
        __weak typeof(*&self) wSelf = self;
        [recorder setRecordFinishBlock:^(XMNAudioRecorder * recorder) {
            
            __strong typeof(*&wSelf) self = wSelf;
            if (self.isCancel) {
                
                /** 取消录音,显示提示文字,删除录音好的文件 */
                [XMNChatRecordProgressHUD dismissWithMessage:@"已取消录音"];
                [[NSFileManager defaultManager] removeItemAtPath:[recorder.filePath stringByAppendingPathComponent:recorder.filename] error:nil];
            }else {
                XMNLog(@"recorder finish :%@",[recorder.filePath stringByAppendingPathComponent:recorder.filename]);

                [XMNChatRecordProgressHUD dismissWithProgressState:XMProgressSuccess];                
                XMNChatVoiceMessage *voiceMessage = [[XMNChatVoiceMessage alloc] initWithContent:[recorder.filePath stringByAppendingPathComponent:recorder.filename] state:XMNMessageStateSending owner:XMNMessageOwnerSelf];
                [self sendMessage:voiceMessage];
                [self scrollBottom:YES];
            }
            self.cancel = NO;
        }];
        
        [recorder setRecordErrorBlock:^(XMNAudioRecorder * recorder, NSError * error) {
            
            [XMNChatRecordProgressHUD dismissWithProgressState:XMProgressError];
            XMNLog(@"recorder error :%@",error);
        }];
        objc_setAssociatedObject(self, &kXMNChatAudioRecorderKey, recorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return recorder;
}

static NSString *kXMNChatAudioRecorderCancelKey;
- (BOOL)isCancel {
    
    if (objc_getAssociatedObject(self, &kXMNChatAudioRecorderCancelKey)) {
        return [objc_getAssociatedObject(self, &kXMNChatAudioRecorderCancelKey) boolValue];
    }
    return NO;
}

@end
