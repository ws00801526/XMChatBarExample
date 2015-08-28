//
//  XMChatFaceView.m
//  XMChatBarExample
//
//  Created by shscce on 15/8/21.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//


#define kFaceWidth 28   //默认表情宽度 
#define kLeftPadding 10 //表情距离左右边框间距
#define kFacePadding 6  //表情之间间距

#import "XMChatFaceView.h"
#import "XMFaceManager.h"

/**
 *  预览表情显示的View
 */
@interface XMFacePreviewView : UIView

@property (weak, nonatomic) UIImageView *faceImageView /**< 展示face表情的 */;
@property (weak, nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;

@end

@implementation XMFacePreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"preview_background"]];
    [self addSubview:self.backgroundImageView = backgroundImageView];
    
    UIImageView *faceImageView = [[UIImageView alloc] init];
    [self addSubview:self.faceImageView = faceImageView];
    
    self.bounds = self.backgroundImageView.bounds;
}

/**
 *  修改faceImageView显示的图片
 *
 *  @param image 需要显示的表情图片
 */
- (void)setFaceImage:(UIImage *)image{
    if (self.faceImageView.image == image) {
        return;
    }
    [self.faceImageView setImage:image];
    [self.faceImageView sizeToFit];
    self.faceImageView.center = self.backgroundImageView.center;
    [UIView animateWithDuration:.3 animations:^{
        self.faceImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.faceImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end


@interface XMChatFaceView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) XMFacePreviewView *facePreviewView;

@property (assign, nonatomic, readonly) NSUInteger maxPerLine; /**< 每行显示的表情数量,6,6plus可能相应多显示 */



@end

@implementation XMChatFaceView

- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / scrollView.frame.size.width];
}

#pragma mark - Private Methods

- (void)setup{
    
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    
    [self setupFaces];
    
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
    
}

- (void)setupFaces{
    
    NSUInteger maxPerLine = self.maxPerLine;
    NSUInteger line = 0;   //行数
    NSUInteger column = 0; //列数
    NSUInteger page = 0;   //页数
    CGFloat itemWidth = (self.frame.size.width - 20) / 7;
    for (NSDictionary *faceDict in [XMFaceManager allFaces]) {
        if (column > maxPerLine) {
            line ++ ;
            column = 0;
        }
        if (line > 2) {
            line = 0;
            column = 0;
            page ++ ;
        }
        CGFloat startX = 10 + column * itemWidth + page * self.frame.size.width;
        CGFloat startY = line * itemWidth;

        UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
        [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
        [self.scrollView addSubview:imageView];
        column ++ ;
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (page + 1), self.scrollView.frame.size.height)];
    self.pageControl.numberOfPages = page + 1;
}


- (UIImageView *)faceImageViewWithID:(NSString *)faceID{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceID]];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    longPress.minimumPressDuration = .3f;
//    [imageView addGestureRecognizer:longPress];
    
    return imageView;
}


- (void)handleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"click is %ld  name is %@",tap.view.tag,[XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]]);
    NSString *faceName = [XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    CGPoint touchPoint = [longPress locationInView:self];
    UIImageView *touchFaceView = [self faceViewWitnInPoint:touchPoint];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 15)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
        [self addSubview:self.facePreviewView];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 15)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
    }else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self.facePreviewView removeFromSuperview];
    }
}


/**
 *  根据点击位置获取点击的imageView
 *
 *  @param point 点击的位置
 *
 *  @return 被点击的imageView
 */
- (UIImageView *)faceViewWitnInPoint:(CGPoint)point{
    
//    NSUInteger page = self.pageControl.currentPage;
//    NSUInteger faceNumberPerPage = 3 * (self.maxPerLine + 1);
//    int currentFaceIndex = page * faceNumberPerPage;
//    for (int i = currentFaceIndex; i < faceNumberPerPage * page; i ++ ) {
//        UIImageView *imageView = self.scrollView.subviews[i];
//        if (CGRectContainsPoint(imageView.frame, CGPointMake(self.pageControl.currentPage * self.frame.size.width + point.x, point.y))) {
//            return imageView;
//        }
//    }
    for (UIImageView *imageView in self.scrollView.subviews) {
        if (CGRectContainsPoint(imageView.frame, CGPointMake(self.pageControl.currentPage * self.frame.size.width + point.x, point.y))) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - Getters

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 60)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height, self.frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (XMFacePreviewView *)facePreviewView{
    if (!_facePreviewView) {
        _facePreviewView = [[XMFacePreviewView alloc] initWithFrame:CGRectZero];
    }
    return _facePreviewView;
}

- (NSUInteger)maxPerLine{
    return 6;
}
@end
    