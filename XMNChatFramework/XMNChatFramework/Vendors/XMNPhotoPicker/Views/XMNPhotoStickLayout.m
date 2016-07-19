//
//  XMNStickLayout.m
//  XMNStickLayoutExample
//
//  Created by XMFraker on 16/4/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoStickLayout.h"

#import <UIKit/UICollectionViewFlowLayout.h>

NSString *const kXMNStickSupplementaryViewKind = @"com.XMFraker.XMNStickLayout.kXMNStickSupplementaryViewKind";

@interface XMNPhotoStickLayout ()

@property (nonatomic, assign) CGFloat originX;

@property (nonatomic, assign) CGFloat originY;

/** 存储所有的itemAttributes */
@property (nonatomic, strong) NSMutableArray *itemAttributesArrayM;
/** 存储所有的supplementaryView的attributes */
@property (nonatomic, strong) NSMutableArray *supplementaryViewAttributesArrayM;


@end

@implementation XMNPhotoStickLayout


- (instancetype)init {
    
    if (self = [super init]) {
        
        self.itemAttributesArrayM = [NSMutableArray array];
        self.supplementaryViewAttributesArrayM = [NSMutableArray array];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    
    [super prepareLayout];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self updateAllAttributes];
    });
}

- (void)updateAllAttributes {
    
    self.originX = self.sectionInset.left;
    self.originY = self.sectionInset.top;
    
    NSUInteger cellCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    for (int i = 0; i < cellCount; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CGSize itemSize =  [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *cellAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        cellAttributes.frame = CGRectMake(self.originX, self.sectionInset.top, itemSize.width, itemSize.height);
        
        UICollectionViewLayoutAttributes *supplementaryViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kXMNStickSupplementaryViewKind withIndexPath:indexPath];
        supplementaryViewAttributes.frame = CGRectMake(self.originX, self.sectionInset.top, self.headerReferenceSize.width, self.headerReferenceSize.height);
        
        [self.itemAttributesArrayM addObject:cellAttributes];
        [self.supplementaryViewAttributesArrayM addObject:supplementaryViewAttributes];
        
        self.originX += itemSize.width;
        self.originX += self.minimumLineSpacing;
        
        self.originY = MAX(itemSize.height, self.originY);
    }
}


- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(self.originX + self.sectionInset.right, self.originY + self.sectionInset.bottom);
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
        
    [self.supplementaryViewAttributesArrayM enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes *cellAttributes = self.itemAttributesArrayM[idx];
        if (!CGRectContainsPoint(visibleRect, cellAttributes.frame.origin)) {
            attributes.frame = CGRectMake(cellAttributes.frame.origin.x + cellAttributes.frame.size.width - attributes.size.width, cellAttributes.frame.origin.y, attributes.size.width, attributes.size.height);
        }else if (!CGRectContainsPoint(visibleRect, CGPointMake(cellAttributes.frame.origin.x + cellAttributes.frame.size.width, cellAttributes.frame.origin.y))) {
            attributes.frame = CGRectMake(MAX(visibleRect.origin.x + visibleRect.size.width - attributes.size.width, cellAttributes.frame.origin.x), cellAttributes.frame.origin.y, attributes.size.width, attributes.size.height);
        }else {
            attributes.frame = CGRectMake(cellAttributes.frame.origin.x + cellAttributes.frame.size.width - attributes.size.width, cellAttributes.frame.origin.y, attributes.size.width, attributes.size.height);
        }
    }];

    return [self.itemAttributesArrayM arrayByAddingObjectsFromArray:self.supplementaryViewAttributesArrayM];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

@end
