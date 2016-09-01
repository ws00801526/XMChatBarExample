//
//  XMNChatBar.m
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatBar.h"

#import "XMNAudio.h"
#import "XMNChatExpressionManager.h"

@interface XMNChatBar () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;
@property (weak, nonatomic) IBOutlet UIButton *faceButton;

@property (nonatomic, copy)   NSString *inputText;

@end

@implementation XMNChatBar

- (instancetype)init {
    
    NSArray *views = [[NSBundle bundleWithIdentifier:@"com.XMFraker.XMNChatFramework"] loadNibNamed:@"XMNChatBar" owner:nil options:nil];
    return [views firstObject];
}

- (void)awakeFromNib {
    
    self.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
    self.layer.borderWidth = 1.0f;
    self.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    
    self.textView.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.cornerRadius = 4.0f;
    
    self.textView.textContainerInset =  UIEdgeInsetsMake( 4, 4, 4, 4);
    
    self.voiceRecordButton.hidden = YES;
    self.voiceRecordButton.layer.cornerRadius = 4.0f;
    self.voiceRecordButton.layer.borderWidth = 1.0f;
    self.voiceRecordButton.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
    
    //设置textView 解析表情
    XMNChatTextParser *parser = [[XMNChatTextParser alloc] init];
    parser.emoticonMapper = [XMNChatExpressionManager sharedManager].qqMapper;
    parser.emotionSize = CGSizeMake(18.f, 18.f);
    parser.alignFont = [UIFont systemFontOfSize:16.f];
    parser.alignment = YYTextVerticalAlignmentBottom;
    self.textView.textParser = parser;
    
    //设置textView 固定行高
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = 20.f;
    self.textView.linePositionModifier = mod;
        
    self.textView.font = [UIFont systemFontOfSize:16.f];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
}

#pragma mark - Methods

- (void)resetButtonState {
    
    self.faceButton.selected = self.otherButton.selected = self.voiceButton.selected = NO;
}

- (IBAction)handleButtonAction:(UIButton *)aButton {
    
    XMNChatBarShowingView viewType = XMNChatShowingNoneView;
    BOOL selected = aButton.selected;
    [self resetButtonState];
    
    aButton.selected = !selected;
    
    if (aButton == self.voiceButton) {
        self.textView.hidden = self.voiceButton.selected;
        self.voiceRecordButton.hidden = !self.voiceButton.selected;
        viewType = !aButton.selected ? XMNChatShowingKeyboard : XMNChatShowingVoiceView;
    }
    
    if (aButton == self.faceButton) {
        self.voiceRecordButton.hidden = YES;
        self.textView.hidden = NO;
        viewType = !aButton.selected ? XMNChatShowingKeyboard: XMNChatShowingFaceView;
    }
    
    if (aButton == self.otherButton) {
        self.voiceRecordButton.hidden = YES;
        self.textView.hidden = NO;
        viewType = !aButton.selected ? XMNChatShowingKeyboard: XMNChatShowingOtherView;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarShowingViewDidChanged:)]) {
        [self.delegate chatBarShowingViewDidChanged:viewType];
    }
}

@end
