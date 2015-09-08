//
//  XMChatFaceView.m
//  XMChatBarExample
//
//  Created by shscce on 15/8/21.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

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

@property (strong, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *sendButton;

@property (assign, nonatomic, readonly) NSUInteger maxPerLine; /**< 每行显示的表情数量,6,6plus可能相应多显示  默认emoji5s显示7个 最近表情显示4个  gif表情显示4个 */
@property (assign, nonatomic, readonly) NSUInteger maxLine; /**< 每页显示的行数 默认emoji3行  最近表情2行  gif表情2行 */

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
    [self addSubview:self.bottomView];
    
    [self setupEmojiFaces];
    
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
    
}

- (void)setupEmojiFaces{
    
    //计算每一页最多显示多少个表情 (每行显示数量)*3 - 1(删除按钮)
    NSInteger pageItemCount = (self.maxPerLine + 1) * 3 - 1;
    
    NSMutableArray *allFaces = [NSMutableArray arrayWithArray:[XMFaceManager emojiFaces]];
    NSUInteger pageCount = [allFaces count] % pageItemCount == 0 ? [allFaces count] / pageItemCount : ([allFaces count] / pageItemCount) + 1;
    
    self.pageControl.numberOfPages = pageCount;
    
    for (int i = 0; i < pageCount; i++) {
        if (pageCount - 1 == i) {
            [allFaces addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
        }else{
            [allFaces insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * pageItemCount + i];
        }
    }
    
    NSUInteger maxPerLine = self.maxPerLine;
    NSUInteger line = 0;   //行数
    NSUInteger column = 0; //列数
    NSUInteger page = 0;   //页数
    CGFloat itemWidth = (self.frame.size.width - 20) / 7;
    for (NSDictionary *faceDict in allFaces) {
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
}


- (UIImageView *)faceImageViewWithID:(NSString *)faceID{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceID]];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];

    return imageView;
}


- (void)handleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"click is %ld  name is %@",tap.view.tag,[XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]]);
    NSString *faceName = [XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]];
    if (tap.view.tag == 999) {
        faceName = @"[删除]";
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    CGPoint touchPoint = [longPress locationInView:self];
    UIImageView *touchFaceView = [self faceViewWitnInPoint:touchPoint];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
        [self addSubview:self.facePreviewView];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 40)];
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

    for (UIImageView *imageView in self.scrollView.subviews) {
        if (CGRectContainsPoint(imageView.frame, CGPointMake(self.pageControl.currentPage * self.frame.size.width + point.x, point.y))) {
            return imageView;
        }
    }
    return nil;
}


- (void)sendAction:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:@"发送"];
    }
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

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        
        UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, 1.0f)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 70, 40)];
        sendButton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:70.0f/255.0f blue:1.0f alpha:1.0f];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:self.sendButton = sendButton];
    }
    return _bottomView;
}

- (NSUInteger)maxPerLine{
    return 6;
}

- (NSUInteger)maxLine{
    if (self.faceViewType == XMShowEmojiFace) {
        return 3;
    }else if (self.faceViewType == XMShowRecentFace || self.faceViewType == XMShowGifFace){
        return 2;
    }
    return 0;
}

@end
    