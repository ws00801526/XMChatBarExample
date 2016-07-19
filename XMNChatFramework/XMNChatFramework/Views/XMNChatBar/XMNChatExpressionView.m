//
//  XMNChatFaceView.m
//  XMNChatFrameworkDemo
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatExpressionView.h"

#import "XMNChatExpressionCollectionCell.h"

#import "XMNChatExpressionManager.h"

@interface XMNChatExpressionView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonTConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation XMNChatExpressionView

#pragma mark - Life Cycle 

- (instancetype)init {
    
    NSArray *views = [kXMNChatBundle loadNibNamed:@"XMNChatExpressionView" owner:nil options:nil];
    
    return [views firstObject];
}

#pragma mark - Override Methods

- (void)awakeFromNib {
    
    [self setupUI];
}

#pragma mark - Methods

- (void)setupUI {
    
    self.collectionView.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
    
    //初始化senderButton的阴影
    self.sendButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.sendButton.layer.shadowOffset = CGSizeMake(-2, 0);
    self.sendButton.layer.shadowOpacity = .6f;
    [self.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    //初始化bottomView的边框
    self.bottomView.layer.borderColor = XMNVIEW_BORDER_COLOR.CGColor;
    self.bottomView.layer.borderWidth = 1.0f;
    self.bottomView.layer.masksToBounds = YES;
    
    self.pageControl.pageIndicatorTintColor = RGB(177, 177, 177);
    self.pageControl.currentPageIndicatorTintColor = RGB(113, 113, 113);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"XMNChatExpressionCollectionCell" bundle:kXMNChatBundle] forCellWithReuseIdentifier:@"XMNChatExpressionCollectionCell"];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:.0f];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:.0f];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(SCREEN_WIDTH, self.bounds.size.height - 35)];
}

- (void)sendAction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatExpressionNotification object:@{@"type":@(XMNChatExpressionSend)}];
}

- (void)setSendButtonHidden:(BOOL)hidden {
    
    if (!hidden) {
        self.sendButtonTConstraint.constant = -3;
    }else {
        self.sendButtonTConstraint.constant = -63;
    }
    [UIView animateWithDuration:.3 animations:^{
        [self.sendButton layoutIfNeeded];
    }];
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [XMNChatExpressionManager sharedManager].qqEmotions.count % 23 == 0 ? [XMNChatExpressionManager sharedManager].qqEmotions.count / 23 : [XMNChatExpressionManager sharedManager].qqEmotions.count / 23 + 1;
    }
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    XMNChatExpressionCollectionCell *faceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMNChatExpressionCollectionCell" forIndexPath:indexPath];
    [faceCell setType:indexPath.section == 0 ? XMNChatExpressionQQEmotion : XMNChatExpressionGIF];
    [faceCell setEmotions:[[XMNChatExpressionManager sharedManager] emotionsAtIndexPath:indexPath]];
    return faceCell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    XMNLog(@"end drag %.2f",targetContentOffset->x);
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(targetContentOffset->x, targetContentOffset->y)];
    [self setSendButtonHidden:indexPath.section != 0];
    XMNLog(@"%ld",indexPath.row);
    
    self.pageControl.numberOfPages = [self.collectionView numberOfItemsInSection:indexPath.section];
    self.pageControl.currentPage = indexPath.row;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNLog(@"will display :%@",indexPath);
    [self setSendButtonHidden:indexPath.section != 0];
    
    self.pageControl.numberOfPages = [self.collectionView numberOfItemsInSection:indexPath.section];
    self.pageControl.currentPage = indexPath.row;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    XMNLog(@"will display :%@",indexPath);
    [self setSendButtonHidden:indexPath.section != 0];
    
    self.pageControl.numberOfPages = [self.collectionView numberOfItemsInSection:indexPath.section];
    self.pageControl.currentPage = indexPath.row;
}

@end
