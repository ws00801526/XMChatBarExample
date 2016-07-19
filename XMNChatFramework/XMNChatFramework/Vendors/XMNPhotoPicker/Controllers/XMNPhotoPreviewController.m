//
//  XMNPhotoPreviewController.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoPreviewController.h"
#import "XMNPhotoPickerController.h"

#import "XMNAssetModel.h"
#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"

#import "XMNBottomBar.h"
#import "XMNPhotoPreviewCell.h"


#import "UIView+Animations.h"
#import "UIViewController+XMNPhotoHUD.h"

@interface XMNPhotoPreviewController ()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, weak)   UIButton *stateButton;

@property (nonatomic, strong) XMNBottomBar *bottomBar;

@end

@implementation XMNPhotoPreviewController

static NSString * const kXMNPhotoPreviewIdentifier = @"XMNPhotoPreviewCell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _setup];
    [self _setupCollectionView];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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

#pragma mark - Methods

- (void)_setup {
    
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
    [self _updateTopBarStatus];
    [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
    [self _setupConstraints];
}

- (void)_setupCollectionView {
    
    [self.collectionView registerClass:[XMNPhotoPreviewCell class] forCellWithReuseIdentifier:kXMNPhotoPreviewIdentifier];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentSize = CGSizeMake((self.view.frame.size.width + [XMNPhotoPickerOption previewPadding]) * self.assets.count, self.view.frame.size.height);
    self.collectionView.pagingEnabled = YES;
    self.collectionView.frame = CGRectMake(0, 0, (self.view.frame.size.width + [XMNPhotoPickerOption previewPadding]), self.view.frame.size.height);
}

- (void)_setupConstraints {
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50.0f]];
}

- (void)_handleBackAction {
    
    self.didFinishPreviewBlock ? self.didFinishPreviewBlock(self.selectedAssets) : nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_handleStateChangeAction {
    
    if (self.stateButton.selected) {
        [self.selectedAssets removeObject:self.assets[self.currentIndex]];
        self.assets[self.currentIndex].selected = NO;
        [self _updateTopBarStatus];
    }else {
        if (self.selectedAssets.count < self.maxCount) {
            self.assets[self.currentIndex].selected = YES;
            [self.selectedAssets addObject:self.assets[self.currentIndex]];
            [self _updateTopBarStatus];
            [UIView animationWithLayer:self.stateButton.layer type:XMNAnimationTypeBigger];
        }else {
            //TODO 超过最大数量
            [self showAlertWithMessage:[NSString stringWithFormat:@"最多只能选择%ld张照片",(unsigned long)self.maxCount]];
        }
    }
    [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
}

- (void)_updateTopBarStatus {
    
    XMNAssetModel *asset = self.assets[self.currentIndex];
    self.stateButton.selected = asset.selected;
}

- (void)_setBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!animated) {
        self.topBar.hidden = self.bottomBar.hidden = hidden;
        return;
    }
    [UIView animateWithDuration:.15 animations:^{
        self.topBar.alpha = self.bottomBar.alpha = hidden ? .0f : 1.0f;
    } completion:^(BOOL finished) {
        self.topBar.hidden = self.bottomBar.hidden = hidden;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offSet = scrollView.contentOffset;
    self.currentIndex = offSet.x / self.view.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _updateTopBarStatus];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoPreviewCell *previewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kXMNPhotoPreviewIdentifier forIndexPath:indexPath];
    [previewCell configCellWithItem:self.assets[indexPath.row]];
    __weak typeof(*&self) wSelf = self;
    [previewCell setSingleTapBlock:^{
        __weak typeof(*&self) self = wSelf;
        [self _setBarHidden:!self.topBar.hidden animated:YES];
    }];
    return previewCell;
}


/// ========================================
/// @name   重写了collection的两个代理方法,通过预加载
/// 释放 previewImage 来节约内存
/// ========================================

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNAssetModel *model = self.assets[indexPath.row];
    model.previewImage = nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNAssetModel *model = self.assets[indexPath.row];
    [model previewImage];
}

#pragma mark - Getters

- (UIView *)topBar {
    if (!_topBar) {
        
        CGFloat originY = iOS7Later ? 20 : 0;
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, originY + 44)];
        _topBar.backgroundColor = [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:.7f];
        
        UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"navigation_back@2x" ofType:@"png"]] forState:UIControlStateNormal];
        
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [backButton sizeToFit];
        backButton.frame = CGRectMake(12, _topBar.frame.size.height/2 - backButton.frame.size.height/2 + originY/2, backButton.frame.size.width, backButton.frame.size.height);
        [backButton addTarget:self action:@selector(_handleBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:backButton];
        
        UIButton *stateButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [stateButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"photopicker_state_normal@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [stateButton setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"photopicker_state_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];
        
        [stateButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [stateButton sizeToFit];
        stateButton.frame = CGRectMake(_topBar.frame.size.width - 12 - stateButton.frame.size.width, _topBar.frame.size.height/2 - stateButton.frame.size.height/2 + originY/2, stateButton.frame.size.width, stateButton.frame.size.height);

        [stateButton addTarget:self action:@selector(_handleStateChangeAction) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:self.stateButton = stateButton];
        
    }
    return _topBar;
}

- (XMNBottomBar *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[XMNBottomBar alloc] initWithBarType:XMNPreviewBottomBar];
        _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomBar updateBottomBarWithAssets:self.selectedAssets];
        
        __weak typeof(*&self) wSelf = self;
        [_bottomBar setConfirmBlock:^{
            __weak typeof(*&self) self = wSelf;
            NSMutableArray *images = [NSMutableArray array];
            [self.selectedAssets enumerateObjectsUsingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [images addObject:obj];
            }];
            self.didFinishPickingBlock ? self.didFinishPickingBlock(images,self.selectedAssets) : nil;
        }];
    }
    return _bottomBar;
}


+ (UICollectionViewLayout *)photoPreviewViewLayoutWithSize:(CGSize)size {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(size.width + [XMNPhotoPickerOption previewPadding], size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    return layout;
}


@end
