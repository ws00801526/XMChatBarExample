//
//  XMNChatCollectionCell.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/4/26.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatExpressionCollectionCell.h"

#import "XMNChatExpressionManager.h"
#import "YYWebImage.h"


/**
 *  预览表情显示的View
 */
@interface XMExpressionPreviewView : UIView

@property (weak, nonatomic) YYAnimatedImageView *expressionImageView /**< 展示face表情的 */;
@property (weak, nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;

@property (nonatomic, copy)   NSString *expressionKey;


@end

@implementation XMExpressionPreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:XMNCHAT_LOAD_IMAGE(@"expression_preview_background")];
    [self addSubview:self.backgroundImageView = backgroundImageView];
    
    YYAnimatedImageView *expressionImageView = [[YYAnimatedImageView alloc] init];
    [self addSubview:self.expressionImageView = expressionImageView];
    
    self.bounds = self.backgroundImageView.bounds;
}

/**
 *  修改faceImageView显示的图片
 *
 *  @param image 需要显示的表情图片
 */
- (void)setExpression:(YYImage *)expressionImage {
    
    if (self.expressionImageView.image == expressionImage) {
        return;
    }
    self.expressionImageView.image = expressionImage;
    [self.expressionImageView sizeToFit];
    self.expressionImageView.center = self.backgroundImageView.center;
    [UIView animateWithDuration:.3 animations:^{
        self.expressionImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.expressionImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end

@interface XMNChatExpressionCell : UICollectionViewCell

@property (nonatomic, weak) YYAnimatedImageView *imageView;

@end

@implementation XMNChatExpressionCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
        [self.contentView addSubview:self.imageView = imageView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.imageView sizeToFit];
    self.imageView.center = self.contentView.center;
}

- (void)prepareForReuse {
    
    self.imageView.image = nil;
}

@end

@interface XMNChatExpressionCollectionCell () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) XMExpressionPreviewView *expressionPreviewView;

@end

@implementation XMNChatExpressionCollectionCell


#pragma mark - Overrid Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.collectionView.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    [self.collectionView registerClass:[XMNChatExpressionCell class] forCellWithReuseIdentifier:@"XMNChatExpressionCell"];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:.0f];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:.0f];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.contentView addGestureRecognizer:longPress];
    self.contentView.userInteractionEnabled = YES;
}


#pragma mark - Methods

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    
    CGPoint touchPoint = [longPress locationInView:self.collectionView];
    CGPoint windowPoint = [longPress locationInView:[UIApplication sharedApplication].keyWindow];

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.expressionPreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.expressionPreviewView setExpression:indexPath.row == self.emotions.count ? [YYImage imageWithContentsOfFile:[[XMNChatExpressionManager sharedManager].qqBundle pathForResource:[@"999" stringByAppendingString:@"@2x"] ofType:@"png"]] : [XMNChatExpressionManager sharedManager].qqGifMapper[((NSDictionary *)self.emotions[indexPath.row]).allKeys[0]]];
        self.expressionPreviewView.expressionKey = indexPath.row == self.emotions.count ? @"999" : ((NSDictionary *)self.emotions[indexPath.row]).allKeys[0];
        [[UIApplication sharedApplication].keyWindow addSubview:self.expressionPreviewView];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.expressionPreviewView setCenter:CGPointMake(windowPoint.x, windowPoint.y - 40)];
        [self.expressionPreviewView setExpression:indexPath.row == self.emotions.count ? [YYImage imageWithContentsOfFile:[[XMNChatExpressionManager sharedManager].qqBundle pathForResource:[@"999" stringByAppendingString:@"@2x"] ofType:@"png"]] : [XMNChatExpressionManager sharedManager].qqGifMapper[((NSDictionary *)self.emotions[indexPath.row]).allKeys[0]]];
        self.expressionPreviewView.expressionKey = indexPath.row == self.emotions.count ? @"999" : ((NSDictionary *)self.emotions[indexPath.row]).allKeys[0];
    }else if (longPress.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:.2 animations:^{
            self.expressionPreviewView.center = CGPointMake(self.expressionPreviewView.center.x, self.expressionPreviewView.center.y - 20);
        } completion:^(BOOL finished) {
            
            [self.expressionPreviewView removeFromSuperview];
            if ([self.expressionPreviewView.expressionKey isEqualToString:@"999"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatExpressionNotification object:@{@"type":@(XMNChatExpressionDelete)}];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatExpressionNotification object:@{@"type":@(XMNChatExpressionQQEmotion),kXMNChatExpressionNotificationDataKey:self.expressionPreviewView.expressionKey}];
            }
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (self.type) {
        case XMNChatExpressionGIF:
            return self.emotions.count;
        case XMNChatExpressionQQEmotion:
            /** qq表情 最后多加个删除按钮 */
            return self.emotions.count + 1;
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNChatExpressionCell *expressionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMNChatExpressionCell" forIndexPath:indexPath];
    /** 最后一行 直接显示删除按钮 */
    if (self.type == XMNChatExpressionQQEmotion && indexPath.row == self.emotions.count) {
        /** 显示删除按钮 */
        expressionCell.imageView.image = [YYImage imageWithContentsOfFile:[[XMNChatExpressionManager sharedManager].qqBundle pathForResource:[@"999" stringByAppendingString:@"@2x"] ofType:@"png"]];
    }else if (self.type == XMNChatExpressionQQEmotion) {
        /** 显示QQ表情 */
        expressionCell.imageView.image = [XMNChatExpressionManager sharedManager].qqMapper[((NSDictionary *)self.emotions[indexPath.row]).allKeys[0]];
    }else {
        /** 显示普通GIF表情 */
    }
    return expressionCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.type == XMNChatExpressionQQEmotion && indexPath.row == self.emotions.count) {
        /** 选择删除按钮 */
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatExpressionNotification object:@{@"type":@(XMNChatExpressionDelete)}];
    }else if (self.type == XMNChatExpressionQQEmotion) {
        /** 选择了QQ表情 */
        NSDictionary *dict = self.emotions[indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatExpressionNotification object:@{@"type":@(XMNChatExpressionQQEmotion),kXMNChatExpressionNotificationDataKey:[dict.allKeys firstObject]}];
    }else {
        /** 选择普通GIF消息 */
        
    }
}

#pragma mark - Setters

- (void)setEmotions:(NSArray *)emotions {
    
    _emotions = [emotions copy];
    [self.collectionView reloadData];
}

- (void)setType:(XMNChatExpressionType)type {
    
    _type = type;
    switch (type) {
        case XMNChatExpressionGIF:
            [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake((SCREEN_WIDTH - 32)/4, (self.bounds.size.height - 32)/2)];
            break;
        default:
            [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(((SCREEN_WIDTH - 32)/8), (self.bounds.size.height - 32)/3)];
            break;
    }
}

#pragma mark - Getters

- (XMExpressionPreviewView *)expressionPreviewView{
    if (!_expressionPreviewView) {
        _expressionPreviewView = [[XMExpressionPreviewView alloc] initWithFrame:CGRectZero];
    }
    return _expressionPreviewView;
}

@end
