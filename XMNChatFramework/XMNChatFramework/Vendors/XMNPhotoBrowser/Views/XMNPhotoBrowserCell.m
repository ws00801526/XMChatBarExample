//
//  XMNPhotoBrowserCell.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoBrowserCell.h"
#import "XMNPhotoProgressView.h"

#import "XMNPhotoModel.h"

#import "YYWebImage.h"


CGFloat kXMNPhotoBrowserCellPadding = 16.f;

@interface XMNPhotoBrowserCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@property (nonatomic, weak)   XMNPhotoProgressView *progressView;

@end

@implementation XMNPhotoBrowserCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}


#pragma mark - Methods


/// ========================================
/// @name   Publis Methods
/// ========================================

- (void)configCellWithItem:(XMNPhotoModel *)item {
    
    __weak typeof(*&self) wSelf = self;
    
    self.progressView.hidden =  YES;
    [self.scrollView setZoomScale:1.0f];
    
    /** 如果已经下载完毕 直接显示图片 不再去下载 */
    if (item.image) {
        [self showImageWithFadeAnimation:item.image];
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:item.imagePath];
    if (!URL) {
        self.imageView.image = item.thumbnail;
        [self resizeSubviews];
        return;
    }
    
    [self.progressView setProgress:.0f animated:NO];
    self.progressView.hidden = NO;
    [self.imageView yy_setImageWithURL:URL
                           placeholder:item.thumbnail
                               options:YYWebImageOptionAvoidSetImage
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  
                                  __strong typeof(*&wSelf) self = wSelf;
                                  if (expectedSize > 0 && receivedSize > 0) {
                                      CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                      progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                                      if (self.progressView.hidden) {
                                          self.progressView.hidden = NO;
                                      }
                                      [self.progressView setProgress:progress];
                                  }
                              }
                             transform:nil
                            completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                if (!error && image) {
                                    /** 下载完图片后 再次重置imageView 大小 */
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        __strong typeof(*&wSelf) self = wSelf;
                                        if (stage == YYWebImageStageFinished) {
                                            
                                            self.progressView.progress = 1.1f;
                                            if (self.loadingMode == XMNPhotoBrowserLoadingCircle) {
                                                [self showImageWithFadeAnimation:image];
                                            }else {
                                                [self.progressView progressAnimiationDidStop:^{
                                                    self.imageView.image = image;
                                                    [self resizeSubviews];
                                                }];
                                            }
                                        }
                                    });
                                }
                            }];
    [self resizeSubviews];
}


- (void)cancelImageRequest {
    
    [self.imageView yy_cancelCurrentImageRequest];
    [self.imageView yy_cancelCurrentHighlightedImageRequest];
}


/// ========================================
/// @name   Private Methods
/// ========================================


- (void)showImageWithFadeAnimation:(UIImage *)image {
    
    [UIView animateWithDuration:.15
                     animations:^{
                         self.imageView.alpha = .0f;
                     } completion:^(BOOL finished) {
                         self.imageView.image = image;
                         [self resizeSubviews];
                         [UIView animateWithDuration:.2f animations:^{
                             self.imageView.alpha = 1.f;
                         }];
                     }];
}

- (void)setup {
    
    self.backgroundColor = self.contentView.backgroundColor = [UIColor blackColor];
    
    self.loadingMode = XMNPhotoBrowserLoadingProgress;
    
    [self.containerView addSubview:self.imageView];
    [self.scrollView addSubview:self.containerView];
    [self.contentView addSubview:self.scrollView];
    
    XMNPhotoProgressView *progressView = [[XMNPhotoProgressView alloc] initWithFrame:self.containerView.bounds];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    progressView.hidden = YES;
    progressView.backgroundView.backgroundColor = [UIColor clearColor];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.indeterminate = self.loadingMode == XMNPhotoBrowserLoadingCircle;
    progressView.showsText = self.loadingMode == XMNPhotoBrowserLoadingProgress;
//    progressView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self.containerView addSubview:self.progressView = progressView];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
    [self.contentView addGestureRecognizer:doubleTap];
}

- (void)resizeSubviews {
    
    self.containerView.frame = CGRectMake(0, 0, self.bounds.size.width - 16, self.bounds.size.height);
    UIImage *image = self.imageView.image;
    if (!image) {
        return;
    }
    
    CGSize size = [XMNPhotoModel adjustOriginSize:image.size
                                     toTargetSize:CGSizeMake(self.bounds.size.width - kXMNPhotoBrowserCellPadding, self.bounds.size.height)];
    self.containerView.frame = CGRectMake(0, 0, size.width, size.height);

    self.scrollView.contentSize = CGSizeMake(MAX(self.frame.size.width - kXMNPhotoBrowserCellPadding, self.containerView.bounds.size.width), MAX(self.frame.size.height, self.containerView.bounds.size.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.containerView.frame.size.height <= self.frame.size.height ? NO : YES;
    self.imageView.frame = self.containerView.bounds;
    self.progressView.frame = self.containerView.bounds;
    [self scrollViewDidZoom:self.scrollView];
    self.scrollView.maximumZoomScale = MAX(MAX(image.size.width/(self.bounds.size.width - kXMNPhotoBrowserCellPadding), image.size.height / self.bounds.size.height), 3.f);
}


- (void)handleSingleTap {
    
    __weak typeof(*&self) wSelf = self;
    self.singleTapBlock ? self.singleTapBlock(wSelf) : nil;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    
    if (self.scrollView.zoomScale > 1.0f) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }else {
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Setters

- (void)setLoadingMode:(XMNPhotoBrowserLoadingMode)loadingMode {
    
    _loadingMode = loadingMode;
    self.progressView.indeterminate = self.loadingMode == XMNPhotoBrowserLoadingCircle;
    self.progressView.showsText = self.loadingMode == XMNPhotoBrowserLoadingProgress;
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 16, self.bounds.size.height)];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3.0f;
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
    return _scrollView;
}


- (UIView *)containerView {
    
    if (!_containerView) {
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

@end
