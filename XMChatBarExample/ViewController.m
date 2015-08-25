//
//  ViewController.m
//  XMChatBarExample
//
//  Created by shscce on 15/8/17.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "ViewController.h"
#import "PonyChatUI.h"

#import "XMChatBar.h"

#import "XMAVAudioPlayer.h"

@interface ViewController ()<PCUDelegate,XMChatBarDelegate,XMAVAudioPlayerDelegate>

@property (nonatomic, strong) PCUCore *core;
@property (nonatomic, strong) UIView *chatView;
@property (strong, nonatomic) XMChatBar *chatBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[XMAVAudioPlayer sharedInstance] setDelegate:self];
    self.core = [[PCUCore alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    self.chatView = [self.core.wireframe addMainViewToViewController:self
                                                  withMessageManager:self.core.messageManager];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.chatView addGestureRecognizer:tap];
    
    self.chatBar = [[XMChatBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kMinHeight, self.view.frame.size.width, kMinHeight)];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    
    
    [self receiveSystemMessage];
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(receiveVoiceMessage) userInfo:nil repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(receiveTextMessage) userInfo:nil repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(receivePreviousTextMessage) userInfo:nil repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(receiveImageMessage) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UITapGestureRecognizer *)tap{
    [self.chatBar endInputing];
}

#pragma mark - Private Methods

- (void)receiveSystemMessage {
    PCUSystemMessageEntity *systemMessageItem = [[PCUSystemMessageEntity alloc] init];
    systemMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    systemMessageItem.messageText = @"Hello, World!";
    [self.core.messageManager didReceiveMessageItem:systemMessageItem];
}

- (void)receiveTextMessage {
    PCUTextMessageEntity *textMessageItem = [[PCUTextMessageEntity alloc] init];
    textMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    textMessageItem.messageText = [NSString stringWithFormat:@"这只是一堆用来测试的文字，谢谢！Post:%@",
                                   [[NSDate date] description]];
    textMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    textMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    [self.core.messageManager didReceiveMessageItem:textMessageItem];
}

- (void)receivePreviousTextMessage {
    PCUTextMessageEntity *textMessageItem = [[PCUTextMessageEntity alloc] init];
    textMessageItem.messageOrder = -[[NSDate date] timeIntervalSince1970];
    textMessageItem.messageText = [NSString stringWithFormat:@"这段文字来自很多年前，谢谢！Post:%@",
                                   [[NSDate date] description]];
    textMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    textMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    [self.core.messageManager didReceiveMessageItem:textMessageItem];
}

- (void)receiveImageMessage {
    PCUImageMessageEntity *imageMessageItem = [[PCUImageMessageEntity alloc] init];
    imageMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    imageMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    imageMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    imageMessageItem.imageURLString = @"http://ww1.sinaimg.cn/mw1024/4923db2bjw1etpf22s9mbj20xr1o0e82.jpg";
    imageMessageItem.imageSize = CGSizeMake(1024, 1820);
    [self.core.messageManager didReceiveMessageItem:imageMessageItem];
}

- (void)receiveVoiceMessage {
    PCUVoiceMessageEntity *voiceMessageItem = [[PCUVoiceMessageEntity alloc] init];
    voiceMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    voiceMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    voiceMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    voiceMessageItem.voiceURLString = @"";
    voiceMessageItem.voiceDuration = arc4random() % 60;
    [self.core.messageManager didReceiveMessageItem:voiceMessageItem];
}

#pragma mark - PCUDelegate

- (void)PCUImageMessageItemTapped:(PCUImageMessageEntity *)messageItem {
    NSLog(@"Image Tapped, Do Something.");
    /* PonyChatUI希望做到的是，把更多的控制权交回给开发者手上，因此，PonyChatUI并不会将Gallery类集成到里面，你可以自行响应这个方法。
     * 你可以子类化PCUImageMessageEntity，PCU将原封不动的将你的子类返回给你。
     */
}

- (void)PCUVoiceMessageItemTapped:(PCUVoiceMessageEntity *)messageItem
                      voiceStatus:(id<PCUVoiceStatus>)voiceStatus {
    NSLog(@"Voice Tapped, Do Something.");
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    /* 你可以自行获取对应音频文件或本地已经缓存好的文件，并播放，使用voiceStatus控制cell的UI状态。*/
    if (![voiceStatus isPlaying]) {
        [voiceStatus setPlay];
        [[XMAVAudioPlayer sharedInstance] playSongWithVoiceMessage:messageItem playStatus:voiceStatus];
    }else {
        [[XMAVAudioPlayer sharedInstance] stopSound];
    }
}

#pragma mark - XMChatBarDelegate
- (void)chatBar:(XMChatBar *)chatBar sendMessage:(NSString *)message{
    PCUTextMessageEntity *textMessageItem = [[PCUTextMessageEntity alloc] init];
    textMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    textMessageItem.messageText = [NSString stringWithFormat:@"%@！Post:%@",message,[[NSDate date] description]];
    textMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    textMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    [self.core.messageManager didReceiveMessageItem:textMessageItem];
}

- (void)chatBar:(XMChatBar *)chatBar sendVoice:(NSData *)voiceData seconds:(NSTimeInterval)seconds{
    PCUVoiceMessageEntity *voiceMessageItem = [[PCUVoiceMessageEntity alloc] init];
    voiceMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    voiceMessageItem.ownSender = YES;
    voiceMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
    voiceMessageItem.voiceURLString = @"";
    voiceMessageItem.voiceData = voiceData;
    voiceMessageItem.voiceDuration = seconds;
    [self.core.messageManager didReceiveMessageItem:voiceMessageItem];
}

- (void)chatBar:(XMChatBar *)chatBar sendPictures:(NSArray *)pictures{
    PCUImageMessageEntity *imageMessageItem = [[PCUImageMessageEntity alloc] init];
    imageMessageItem.image = [pictures firstObject];
    imageMessageItem.messageOrder = [[NSDate date] timeIntervalSince1970];
    imageMessageItem.ownSender = arc4random() % 5 == 0 ? YES : NO;
    imageMessageItem.senderAvatarURLString = @"http://tp4.sinaimg.cn/1651799567/180/1290860930/1";
//    imageMessageItem.imageURLString = @"http://ww1.sinaimg.cn/mw1024/4923db2bjw1etpf22s9mbj20xr1o0e82.jpg";
//    imageMessageItem.imageSize = CGSizeMake(60, 60);
    [self.core.messageManager didReceiveMessageItem:imageMessageItem];
}

- (void)chatBarFrameDidChange:(XMChatBar *)chatBar{
    [self.chatView setFrame:CGRectMake(0, 0, self.view.frame.size.width, chatBar.frame.origin.y)];
}

#pragma mark - XMAVAudioPlayerDelegate

- (void)audioPlayerBeginLoadVoice{
    
}

- (void)audioPlayerBeginPlay{
    
}

- (void)audioPlayerDidFinishPlay{
    
}

@end
