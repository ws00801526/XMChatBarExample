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

@property (weak, nonatomic) UIButton *recentButton /**< 显示最近表情的button */;
@property (weak, nonatomic) UIButton *emojiButton /**< 显示emoji表情Button */;

@property (assign, nonatomic, readonly) NSUInteger maxPerLine; /**< 每行显示的表情数量,6,6plus可能相应多显示  默认emoji5s显示7个 最近表情显示4个  gif表情显示4个 */
@property (assign, nonatomic, readonly) NSUInteger maxLine; /**< 每页显示的行数 默认emoji3行  最近表情2行  gif表情2行 */
@property (assign, nonatomic) NSUInteger facePage /**< 当前显示的facePage */;

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
    self.facePage = self.pageControl.currentPage;
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

- (void)resetScrollView{
    [self.recentButton setSelected:self.faceViewType == XMShowRecentFace];
    [self.emojiButton setSelected:self.faceViewType == XMShowEmojiFace];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView setContentSize:CGSizeZero];
    [self.pageControl setNumberOfPages:0];
}

- (void)setupFaceView{
    [self resetScrollView];
    if (self.faceViewType == XMShowEmojiFace) {
        [self setupEmojiFaces];
    }else if (self.faceViewType == XMShowRecentFace){
        [self setupRecentFaces];
    }
}

/**
 *  初始化最近使用的表情view
 */
- (void)setupRecentFaces{

    
    NSMutableArray *recentFaces = [NSMutableArray arrayWithArray:[XMFaceManager recentFaces]];
    NSUInteger line = 0;
    NSUInteger column = 0;
    CGFloat itemWidth = (self.frame.size.width - 20) / 4;
    for (NSDictionary *faceDict in recentFaces) {
        if (column >= 4) {
            column = 0;
            line ++ ;
        }
        if (line >= 2) {
            break;
        }
        //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
        CGFloat startX = 10 + column * itemWidth;
        //计算每一个图片的起始Y位置  第几行*每行高度
        CGFloat startY = line * itemWidth;
        
        UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
        [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
        [self.scrollView addSubview:imageView];
        column ++ ;
    }
}

/**
 *  初始化所有的emoji表情
 */
- (void)setupEmojiFaces{
    

    [self resetScrollView];

    //计算每一页最多显示多少个表情 (每行显示数量)*3 - 1(删除按钮)
    NSInteger pageItemCount = (self.maxPerLine + 1) * self.maxLine - 1;
    
    //获取所有的face表情dict包含face_id,face_name两个key-value
    NSMutableArray *allFaces = [NSMutableArray arrayWithArray:[XMFaceManager emojiFaces]];
    
    //计算页数
    NSUInteger pageCount = [allFaces count] % pageItemCount == 0 ? [allFaces count] / pageItemCount : ([allFaces count] / pageItemCount) + 1;
    
    //配置pageControl的页数
    self.pageControl.numberOfPages = pageCount;
    
    //循环,给每一页末尾加上一个delete图片,如果是最后一页直接在最后一个加上delete图片
    for (int i = 0; i < pageCount; i++) {
        if (pageCount - 1 == i) {
            [allFaces addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
        }else{
            [allFaces insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * pageItemCount + i];
        }
    }
    
    //循环添加所有的imageView
    NSUInteger maxPerLine = self.maxPerLine;
    NSUInteger line = 0;   //行数
    NSUInteger column = 0; //列数
    NSUInteger page = 0;   //页数
    //每一行从0开始 显示maxPerLine+1个图片 计算每一个图片的宽度
    CGFloat itemWidth = (self.frame.size.width - 20) / (self.maxPerLine + 1);
    
    for (NSDictionary *faceDict in allFaces) {
        
        //判断是否超过每一行显示的最大数量,是则换行
        if (column > maxPerLine) {
            line ++ ;
            column = 0;
        }
        //判断是否超过每一行显示的最大数量,是则换下一页
        if (line > 2) {
            line = 0;
            column = 0;
            page ++ ;
        }
        //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
        CGFloat startX = 10 + column * itemWidth + page * self.frame.size.width;
        //计算每一个图片的起始Y位置  第几行*每行高度
        CGFloat startY = line * itemWidth;

        UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
        [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
        [self.scrollView addSubview:imageView];
        column ++ ;
    }
    //重新配置下scrollView的contentSize
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (page + 1), self.scrollView.frame.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.facePage * self.frame.size.width, 0)];
    self.pageControl.currentPage = self.facePage;
}

/**
 *  根据faceID获取一个imageView实例
 *
 *  @param faceID faceID
 *
 *  @return
 */
- (UIImageView *)faceImageViewWithID:(NSString *)faceID{
    
    NSString *faceImageName = [XMFaceManager faceImageNameWithFaceID:[faceID integerValue]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceImageName]];
    imageView.userInteractionEnabled = YES;
    imageView.tag = [faceID integerValue];
    imageView.contentMode = UIViewContentModeCenter;
    
    //添加图片的点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [imageView addGestureRecognizer:tap];

    return imageView;
}


/**
 *  处理每个图片对应的点击手势
 *  特殊处理下tag=999  这是一个删除图片
 *  @param tap
 */
- (void)handleTap:(UITapGestureRecognizer *)tap{
    NSString *faceName = [XMFaceManager faceNameWithFaceID:tap.view.tag];
    if (tap.view.tag != 999) {
        [XMFaceManager saveRecentFace:@{@"face_id":[NSString stringWithFormat:@"%ld",tap.view.tag],@"face_name":faceName}];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

/**
 *  处理scrollView的长按手势
 *
 *  @param longPress
 */
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

- (void)changeFaceType:(UIButton *)button{
    self.faceViewType = button.tag;
    [self setupFaceView];
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
        
        
        UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_normal"] forState:UIControlStateNormal];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateHighlighted];
        [recentButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateSelected];
        recentButton.tag = XMShowRecentFace;
        [recentButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [recentButton sizeToFit];
        [_bottomView addSubview:self.recentButton = recentButton];
        [recentButton setFrame:CGRectMake(0, _bottomView.frame.size.height/2-recentButton.frame.size.height/2, recentButton.frame.size.width, recentButton.frame.size.height)];
        
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_normal"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateHighlighted];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateSelected];
        emojiButton.tag = XMShowEmojiFace;
        [emojiButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [emojiButton sizeToFit];
        [_bottomView addSubview:self.emojiButton = emojiButton];
        [emojiButton setFrame:CGRectMake(recentButton.frame.size.width, _bottomView.frame.size.height/2-emojiButton.frame.size.height/2, emojiButton.frame.size.width, emojiButton.frame.size.height)];
        
    }
    return _bottomView;
}

- (NSUInteger)maxPerLine{
//    return 6;  //iphone5s 返回6 ,6plus 返回7个合适
    return 7;
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
    