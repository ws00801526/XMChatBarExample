//
//  XMNFacePageView.m
//  XMFaceItemExample
//
//  Created by shscce on 15/11/12.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNFacePageView.h"
#import "XMFaceManager.h"

@interface XMNFacePageView ()

@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@implementation XMNFacePageView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.imageViews = [NSMutableArray array];
        [self setup];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setup {
    
    if (self.imageViews && self.imageViews.count == self.datas.count) {
        for (NSDictionary *faceDict in self.datas) {
            NSUInteger index = [self.datas indexOfObject:faceDict];
            UIImageView *imageView = self.imageViews[index];
            NSString *faceImageName = [XMFaceManager faceImageNameWithFaceID:[faceDict[kFaceIDKey] integerValue]];
            imageView.tag = [faceDict[kFaceIDKey] integerValue];
            imageView.image = [UIImage imageNamed:faceImageName];
        }
    } else {
        //计算每个item的大小
        CGFloat itemWidth = (self.frame.size.width - 20) / (self.columnsPerRow);
        NSUInteger currentColumn = 0;
        NSUInteger currentRow = 0;
        for (NSDictionary *faceDict in self.datas) {
            if (currentColumn >= self.columnsPerRow) {
                currentRow ++ ;
                currentColumn = 0;
            }
            //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
            CGFloat startX = 10 + currentColumn * itemWidth;
            //计算每一个图片的起始Y位置  第几行*每行高度
            CGFloat startY = currentRow * itemWidth;
            
            UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
            [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            currentColumn ++ ;
        }
    }
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

#pragma mark - Response Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"this is tap :%@",tap);
}

#pragma mark - Setters

- (void)setDatas:(NSArray *)datas {
    _datas = [datas copy];
    [self setup];
}

- (void)setColumnsPerRow:(NSUInteger)columnsPerRow {
    if (_columnsPerRow != columnsPerRow) {
        _columnsPerRow = columnsPerRow;
        [self.imageViews removeAllObjects];
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
}

@end
