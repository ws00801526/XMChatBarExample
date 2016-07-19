//
//  XMNVideoPreviewController.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNVideoPreviewController.h"
#import "XMNPhotoPickerController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "XMNBottomBar.h"

#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"
#import "XMNAssetModel.h"
#import "XMNPhotoManager.h"

#import "UIView+Animations.h"

@interface XMNVideoPreviewController ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, weak)   UIButton *playButton;
@property (nonatomic, weak)   XMNBottomBar *bottomBar;
@property (nonatomic, strong) UIView *topBar;

@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, weak)   NSLayoutConstraint *bottomBarShowConstraint;
@property (nonatomic, weak)   NSLayoutConstraint *bottomBarHideConstraint;


@end

@implementation XMNVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"视频预览";
    [self _setupPlayer];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    NSLog(@"video preview dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController ? [self.navigationController setNavigationBarHidden:YES] : nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController ? [self.navigationController setNavigationBarHidden:NO] : nil;
}

#pragma mark - Methods


/**
 *  初始化player
 *  1.获取asset对应的AVPlayerItem
 *  2.初始化AVPlayer
 *  3.添加AVPlayerLayer
 *  4.chu
 */
- (void)_setupPlayer {
    
    __weak typeof(*&self) wSelf = self;
    
    [[XMNPhotoManager sharedManager] getPreviewImageWithAsset:self.asset.asset completionBlock:^(UIImage *image) {
        __weak typeof(*&self) self = wSelf;
        self.coverImage = image;
    }];
    
    [[XMNPhotoManager sharedManager] getVideoInfoWithAsset:self.asset.asset completionBlock:^(AVPlayerItem *playerItem, NSDictionary *playetItemInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(*&self) self = wSelf;
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            playerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:playerLayer];
            [self _setupPlayButton];
            [self _setupBottomBar];
            [self _setupConstraints];
            [self.view addSubview:self.topBar];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pausePlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        });
    }];
    
}

- (void)_setupPlayButton {
    
    UIButton *playButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 44);
    [playButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"video_preview_play_normal@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"video_preview_play_highlight@2x" ofType:@"png"]] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(_handlePlayAciton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton = playButton];
}

- (void)_setupBottomBar {
    
    XMNBottomBar *bottomBar = [[XMNBottomBar alloc] initWithBarType:XMNPreviewBottomBar];
    __weak typeof(*&self) wSelf = self;
    self.selectedVideoEnable ? [bottomBar setConfirmBlock:^{
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingVideo ? self.didFinishPickingVideo(self.asset.previewImage , self.asset) : nil;
    }] : nil;
    [bottomBar updateBottomBarWithAssets:self.selectedVideoEnable ? @[self.asset] : @[]];
    [self.view addSubview:self.bottomBar = bottomBar];
}

- (void)_handlePlayAciton {
    CMTime currentTime = self.player.currentItem.currentTime;
    CMTime durationTime = self.player.currentItem.duration;
    if (self.player.rate == 0.0f) {
        [self.playButton setImage:nil forState:UIControlStateNormal];
        if (currentTime.value == durationTime.value) [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
        [self.player play];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:.2 animations:^{
            [self.bottomBar setFrame:CGRectMake(0, self.view.frame.size.height, self.bottomBar.frame.size.width, self.bottomBar.frame.size.height)];
            [self.topBar setFrame:CGRectMake(0, -self.topBar.frame.size.height, self.topBar.frame.size.width, self.topBar.frame.size.height)];
        }];
    } else {
        [self _pausePlayer];
    }
}

- (void)_pausePlayer {
    
    [self.playButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"video_preview_play_normal@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.player pause];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:.2 animations:^{
        [self.bottomBar setFrame:CGRectMake(0, self.view.frame.size.height-self.bottomBar.frame.size.height, self.bottomBar.frame.size.width, self.bottomBar.frame.size.height)];
        [self.topBar setFrame:CGRectMake(0, 0, self.topBar.frame.size.width, self.topBar.frame.size.height)];
    }];
}

- (void)_handleBackAction {
    
    self.didFinishPreviewBlock ? self.didFinishPreviewBlock() : nil;
    self.navigationController ? [self.navigationController popViewControllerAnimated:YES] : [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_setupConstraints {
    self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:self.bottomBarShowConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
//    [self.view addConstraint:self.bottomBarHideConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50.0f]];
}

#pragma mark - Getters

- (UIView *)topBar {
    if (!_topBar) {
        
        CGFloat originY = iOS7Later ? 20 : 0;
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, originY + 44)];
        _topBar.backgroundColor = [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:.7f];
        
        UILabel *label = [[UILabel alloc] init];
        [label setAttributedText:[[NSAttributedString alloc] initWithString:@"视频预览" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor whiteColor]}]];
        [label sizeToFit];
        label.center = _topBar.center;
        [_topBar addSubview:label];
        
        UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"navigation_back@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [backButton sizeToFit];
        backButton.frame = CGRectMake(12, _topBar.frame.size.height/2 - backButton.frame.size.height/2 + originY/2, backButton.frame.size.width, backButton.frame.size.height);
        [backButton addTarget:self action:@selector(_handleBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:backButton];
    }
    return _topBar;
}


@end
