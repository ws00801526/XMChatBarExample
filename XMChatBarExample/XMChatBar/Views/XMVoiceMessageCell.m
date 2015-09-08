//
//  XMVoiceMessageCell.m
//  XMChatControllerExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMVoiceMessageCell.h"

#import "XMVoiceMessage.h"

@interface XMVoiceMessageCell ()

@property (strong, nonatomic) UIImageView *voiceReadStateImageView /**< 显示voice是否已读 */;
@property (strong, nonatomic) UIImageView *voiceStateImageView;
@property (strong, nonatomic) UILabel *voiceSecondsLabel;
@property (strong, nonatomic) dispatch_source_t timer;
@property (assign, nonatomic) BOOL isVoicePlaying;

@end

@implementation XMVoiceMessageCell


#pragma mark - XMVoiceMessageStatus

- (void)startPlaying{
    self.isVoicePlaying = YES;
    self.voiceReadStateImageView.hidden = YES; //已读,隐藏未读标签
    [self startPlayingAnimation];
}

- (void)stopPlaying{
    [self stopPlayingAnimation];
}

- (BOOL)isPlaying{
    return self.isVoicePlaying;
}

#pragma mark - Overrids Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches allObjects][0];
    CGPoint touchPoint = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(self.messageContentView.frame, touchPoint)) {
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(XMVoiceMessageTapped:voiceStatus:)]) {
            [self.messageDelegate XMVoiceMessageTapped:(XMVoiceMessage *)self.message voiceStatus:self];
        }
    }
}

#pragma mark - Public Methods

- (void)setup{
    [super setup];
    self.isVoicePlaying = NO;
    [self.messageBackgroundImageView addSubview:self.voiceStateImageView];
    
    [self.messageContentView addSubview:self.messageBackgroundImageView];
    [self.messageContentView addSubview:self.voiceSecondsLabel];
    [self.messageContentView addSubview:self.voiceReadStateImageView];

}

- (void)updateConstraints{
    [super updateConstraints];

    CGFloat width = MIN(([(XMVoiceMessage *)self.message voiceSeconds]/3 + 1) * 80, 190);
    [self.messageBackgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
        make.width.mas_equalTo(width);
    }];
    
    if (self.message.messageOwner == XMMessageOwnerTypeSelf) {
        
        [self.voiceStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.messageBackgroundImageView.mas_centerY);
            make.right.equalTo(self.messageBackgroundImageView.mas_right).with.offset(-16);
        }];
        
        [self.voiceSecondsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.messageBackgroundImageView.mas_bottom).with.offset(-4);
            make.right.equalTo(self.messageBackgroundImageView.mas_left).with.offset(-4);
        }];
        
        [self.voiceReadStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageBackgroundImageView.mas_top).with.offset(4);
            make.right.equalTo(self.messageBackgroundImageView.mas_left).with.offset(-4);
            make.width.equalTo(@8);
            make.height.equalTo(@8);
        }];
        
    }else if (self.message.messageOwner == XMMessageOwnerTypeOther) {
        
        [self.voiceStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.messageBackgroundImageView.mas_centerY);
            make.left.equalTo(self.messageBackgroundImageView.mas_left).with.offset(16);
        }];
        
        [self.voiceSecondsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.messageBackgroundImageView.mas_bottom).with.offset(-4);
            make.left.equalTo(self.messageBackgroundImageView.mas_right).with.offset(4);
        }];
        
        [self.voiceReadStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageBackgroundImageView.mas_top).with.offset(4);
            make.left.equalTo(self.messageBackgroundImageView.mas_right).with.offset(4);
            make.width.equalTo(@8);
            make.height.equalTo(@8);
        }];
        
    }
        
}

- (void)setMessage:(XMMessage *)message{
    XMVoiceMessage *voiceMessage = (XMVoiceMessage *)message;
    
    [self.voiceSecondsLabel setText:[NSString stringWithFormat:@"%ld''",voiceMessage.voiceSeconds]];
    if (voiceMessage.messageOwner == XMMessageOwnerTypeOther) {
        [self.voiceStateImageView setImage:[UIImage imageNamed:@"message_voice_receiver_normal"]];
    }else if (voiceMessage.messageOwner == XMMessageOwnerTypeSelf){
        [self.voiceStateImageView setImage:[UIImage imageNamed:@"message_voice_sender_normal"]];
    }
    
    [super setMessage:message];

}

#pragma mark - Private Methods

- (void)startPlayingAnimation{

    __weak __typeof(&*self) wself = self;
    dispatch_queue_t queue = dispatch_get_global_queue  (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    __block NSUInteger currentFrame = 0;
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),.5*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (currentFrame < 1 || currentFrame > 3) {
                    currentFrame = 1;
                }
                if (wself.message.messageOwner == XMMessageOwnerTypeSelf) {
                    wself.voiceStateImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"message_voice_sender_playing_%ld",currentFrame]];
                }
                else if (wself.message.messageOwner == XMMessageOwnerTypeOther) {
                    wself.voiceStateImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"message_voice_receiver_playing_%ld",currentFrame]];
                }
                currentFrame++;
            });
    });
    dispatch_resume(self.timer);

}

- (void)stopPlayingAnimation {
    if (self.isVoicePlaying) {
        if (self.timer) {
            dispatch_source_cancel(self.timer);
            self.timer = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.message.messageOwner == XMMessageOwnerTypeOther) {
                [self.voiceStateImageView setImage:[UIImage imageNamed:@"message_voice_receiver_normal"]];
            }else if (self.message.messageOwner == XMMessageOwnerTypeSelf){
                [self.voiceStateImageView setImage:[UIImage imageNamed:@"message_voice_sender_normal"]];
            }
        });
        
    }
    self.isVoicePlaying = NO;
}

#pragma mark - Getters

- (UIImageView *)voiceStateImageView{
    if (!_voiceStateImageView) {
        _voiceStateImageView = [[UIImageView alloc] init];
    }
    return _voiceStateImageView;
}

- (UIImageView *)voiceReadStateImageView{
    if (!_voiceReadStateImageView) {
        _voiceReadStateImageView = [[UIImageView alloc] init];
        _voiceReadStateImageView.layer.cornerRadius = 4.0f;
        _voiceReadStateImageView.backgroundColor = [UIColor redColor];
    }
    return _voiceReadStateImageView;
}

- (UILabel *)voiceSecondsLabel{
    if (!_voiceSecondsLabel) {
        _voiceSecondsLabel = [[UILabel alloc] init];
        _voiceSecondsLabel.textColor = [UIColor lightGrayColor];
        _voiceSecondsLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _voiceSecondsLabel;
}

@end
