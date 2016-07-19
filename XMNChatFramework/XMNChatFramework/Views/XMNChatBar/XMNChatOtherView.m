//
//  XMNChatOtherView.m
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatOtherView.h"
#import "XMNChatOtherCollectionCell.h"

#import "XMNChatConfiguration.h"



@interface XMNChatOtherView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation XMNChatOtherView

#pragma mark - Life Cycle

- (instancetype)init {
    
    NSArray *views = [kXMNChatBundle loadNibNamed:@"XMNChatOtherView" owner:nil options:nil];
    return [views firstObject];
}

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [self setupUI];
}

#pragma mark - Methods

- (void)setupUI {
    
    self.collectionView.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    
    self.pageControl.pageIndicatorTintColor = RGB(177, 177, 177);
    self.pageControl.currentPageIndicatorTintColor = RGB(113, 113, 113);
    
    [self.collectionView registerClass:[XMNChatOtherCollectionCell class] forCellWithReuseIdentifier:@"XMNChatOtherCollectionCell"];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:.0f];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:.0f];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(SCREEN_WIDTH, self.bounds.size.height - 35)];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNChatOtherCollectionCell *itemView = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMNChatOtherCollectionCell" forIndexPath:indexPath];
    return itemView;
}


#pragma mark - UIScrollViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.pageControl.numberOfPages = [self.collectionView numberOfItemsInSection:indexPath.section];
    self.pageControl.currentPage = indexPath.row;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    self.pageControl.numberOfPages = [self.collectionView numberOfItemsInSection:indexPath.section];
    self.pageControl.currentPage = indexPath.row;
}

@end
