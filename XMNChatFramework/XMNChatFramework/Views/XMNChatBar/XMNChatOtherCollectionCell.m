//
//  XMNChatOtherCollectionCell.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/18.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatOtherCollectionCell.h"

#import "XMNChatConfiguration.h"

@interface XMNChatOtherItemView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet  UIImageView *imageView;
@property (weak, nonatomic)  IBOutlet UILabel   *titleLabel;

@end

@implementation XMNChatOtherItemView

- (void)setHighlighted:(BOOL)highlighted {
    
    self.imageView.highlighted = highlighted;
}

@end


@interface XMNChatOtherCollectionCell () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation XMNChatOtherCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Methods

- (void)setup {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    [flowLayout setItemSize:CGSizeMake((SCREEN_WIDTH - 48)/4, (self.bounds.size.height - 16)/2)];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.scrollEnabled = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.contentInset = UIEdgeInsetsMake(8, 24, 0, 24);
    [self addSubview:self.collectionView = collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"XMNChatOtherItemView" bundle:kXMNChatBundle] forCellWithReuseIdentifier:@"XMNChatOtherItemView"];
    
    self.collectionView.backgroundColor = XMNVIEW_BACKGROUND_COLOR;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNChatOtherItemView *itemView = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMNChatOtherItemView" forIndexPath:indexPath];
    itemView.imageView.image = XMNCHAT_LOAD_IMAGE(@"aio_icons_pic");
    return itemView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatOtherItemNotification object:@{kXMNChatOtherItemNotificationDataKey:@"相册"}];

}

@end
