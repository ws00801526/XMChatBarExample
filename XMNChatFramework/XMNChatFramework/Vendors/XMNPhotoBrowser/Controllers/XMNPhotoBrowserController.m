//
//  XMNPhotoBrowserController.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/13.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoBrowserController.h"

#import "XMNPhotoBrowserCell.h"

#import "XMNPhotoModel.h"
#import "XMNPhotoBrowserTransition.h"

static NSString * const kXMNPhotoBrowserCellIdentifier = @"com.XMFraker.XMNPhotoBrowser.kXMNPhotoBrowserCellIdentifier";

@interface XMNPhotoBrowserController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, copy)   NSArray<XMNPhotoModel *> *photos;

@property (nonatomic, assign) NSInteger firstBrowserItemIndex;
@property (nonatomic, assign) BOOL hasFirstBrowserItemIndex;


@end

@implementation XMNPhotoBrowserController

#pragma mark - Life Cycle

- (instancetype)initWithPhotos:(NSArray <XMNPhotoModel *> *)photos {
    
    if (self = [super initWithCollectionViewLayout:[[self class] photoPreviewViewLayoutWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)]]) {
        
        _photos = [photos copy];
        _firstBrowserItemIndex = 0;
        _currentItemIndex = 0;
    }
    return self;
}

#pragma mark - Override Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.transitioningDelegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupCollectionView];
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width + kXMNPhotoBrowserCellPadding, self.view.bounds.size.height);
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    /** 出现时 滚到到指定的index */
    if (self.photos && self.photos.count > self.currentItemIndex) {
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentItemIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
}




/// ========================================
/// @name   支持屏幕旋转功能
/// ========================================

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    
    NSInteger index = [[self.collectionView indexPathsForVisibleItems] firstObject].row;
    NSLog(@"屏幕旋转 :%@ index :%d",NSStringFromCGSize(size), (int)index);
    [self.collectionView setCollectionViewLayout:[[self class] photoPreviewViewLayoutWithSize:size] animated:NO];
    [self.collectionView reloadData];
    if (self.photos && self.photos.count > index) {
        self.collectionView.contentOffset = CGPointMake((size.width + kXMNPhotoBrowserCellPadding) * index, 0);
    }
}

#pragma mark - Methods

/// ========================================
/// @name   Private Methods
/// ========================================

- (void)setupCollectionView {
    
    [self.collectionView registerClass:[XMNPhotoBrowserCell class] forCellWithReuseIdentifier:kXMNPhotoBrowserCellIdentifier];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentSize = CGSizeMake(self.view.frame.size.width * self.photos.count, self.view.frame.size.height);
    self.collectionView.pagingEnabled = YES;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    if (presented == self) {
        
        return [[XMNPhotoBrowserPresentTransition alloc] init];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if (dismissed == self) {
        
        return [[XMNPhotoBrowserDismissTransition alloc] init];
    }
    return nil;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoBrowserCell *browserCell = [collectionView dequeueReusableCellWithReuseIdentifier:kXMNPhotoBrowserCellIdentifier forIndexPath:indexPath];
    browserCell.loadingMode = self.loadingMode;
    [browserCell configCellWithItem:self.photos[indexPath.row]];
    __weak typeof(*&self) wSelf = self;
    [browserCell setSingleTapBlock:^(XMNPhotoBrowserCell *__weak _Nonnull browserCell) {
        
        __strong typeof(*&wSelf) self = wSelf;
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    return browserCell;
}

/// ========================================
/// @name   重写了collection的两个代理方法,通过预加载
/// 释放 previewImage 来节约内存
/// ========================================

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoBrowserCell *browserCell = (XMNPhotoBrowserCell *)cell;
    [browserCell cancelImageRequest];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoBrowserCell *browserCell = (XMNPhotoBrowserCell *)cell;
    browserCell.loadingMode = self.loadingMode;
    [browserCell configCellWithItem:self.photos[indexPath.row]];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger currentItemIndex = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
    if (currentItemIndex == self.photos.count - 2) {
        currentItemIndex = roundf((scrollView.contentOffset.x) / (scrollView.frame.size.width));
    }
    
    self.currentItemIndex = currentItemIndex;
}

#pragma mark - Setters

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex {
    
    if (_currentItemIndex == currentItemIndex) {
        return;
    }
    _currentItemIndex = currentItemIndex;
    
    if (!self.hasFirstBrowserItemIndex) {
        self.hasFirstBrowserItemIndex = YES;
        self.firstBrowserItemIndex = currentItemIndex;
    }
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)photoPreviewViewLayoutWithSize:(CGSize)size {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(size.width + kXMNPhotoBrowserCellPadding, size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    return layout;
}

@end
