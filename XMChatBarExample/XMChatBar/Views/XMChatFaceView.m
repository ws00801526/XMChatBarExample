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

@interface XMChatFaceView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *sendFaces; /**< 已选的faces */

@property (assign, nonatomic, readonly) NSUInteger maxPerLine; /**< 每行显示的表情数量 */


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
    
    self.sendFaces = [NSMutableArray array];
    
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    
    [self setupFaces];
    
    self.userInteractionEnabled = YES;
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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = .3f;
    [imageView addGestureRecognizer:longPress];
    
    return imageView;
}


- (void)handleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"click is %ld  name is %@",tap.view.tag,[XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]]);
    NSString *faceName = [XMFaceManager faceNameWithFaceImageName:[NSString stringWithFormat:@"%ld",tap.view.tag]];
    [self.sendFaces addObject:faceName];
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"this is long tap");
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

- (NSUInteger)maxPerLine{
    return 6;
}
@end
    