//
//  XMNChatVoiceMessageView.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatVoiceMessageView.h"
#import "XMNChatMessage.h"
@interface XMNChatVoiceMessageView ()

/** 显示播放语音时动画图片 */
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
/** 显示播放语音的加载动画 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;


@end

@implementation XMNChatVoiceMessageView

#pragma mark - Methods

- (void)setupViewWithMessage:(XMNChatVoiceMessage *)aMessage {
    
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
    self.voiceImageView.animationDuration = 1.5f;
    self.voiceImageView.animationRepeatCount = NSUIntegerMax;
    
    if (aMessage.owner == XMNMessageOwnerSelf) {
        self.voiceImageView.contentMode = UIViewContentModeRight;
        self.voiceImageView.image = XMNCHAT_LOAD_IMAGE(@"message_voice_sender_normal");
        
        [self.voiceImageView setHighlightedAnimationImages:@[XMNCHAT_LOAD_IMAGE(@"message_voice_sender_playing_1"),XMNCHAT_LOAD_IMAGE(@"message_voice_sender_playing_2"),XMNCHAT_LOAD_IMAGE(@"message_voice_sender_playing_3")]];
    }else if (aMessage.owner == XMNMessageOwnerOther) {
        
        self.voiceImageView.contentMode = UIViewContentModeLeft;
        self.voiceImageView.image = XMNCHAT_LOAD_IMAGE(@"message_voice_receiver_normal");
        [self.voiceImageView setHighlightedAnimationImages:@[XMNCHAT_LOAD_IMAGE(@"message_voice_receiver_playing_1"),XMNCHAT_LOAD_IMAGE(@"message_voice_receiver_playing_2"),XMNCHAT_LOAD_IMAGE(@"message_voice_receiver_playing_3")]];
    }
    
    self.contentSize = CGSizeMake(100, 50);
}

- (void)updateUIWithMessage:(XMNChatBaseMessage *)aMessage {
    
    self.voiceImageView.hidden = NO;
    self.voiceImageView.highlighted = NO;
    [self.voiceImageView stopAnimating];
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
    
    if (aMessage.substate == XMNMessageSubStateRecievingContent) {
        self.voiceImageView.hidden = YES;
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
    }
    if (aMessage.substate == XMNMessageSubStatePlayingContent) {
        self.voiceImageView.highlighted = YES;
        [self.voiceImageView startAnimating];
    }
}

@end
