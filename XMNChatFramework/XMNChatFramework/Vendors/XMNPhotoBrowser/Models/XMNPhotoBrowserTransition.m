//
//  XMNPhotoBrowserTransition.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/6/14.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoBrowserTransition.h"
#import "XMNPhotoBrowserController.h"

#import "YYAnimatedImageView.h"
#import "XMNPhotoBrowserCell.h"


#import "XMNPhotoModel.h"

@implementation XMNPhotoBrowserPresentTransition


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return .4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    XMNPhotoBrowserController *toVC   = (XMNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    
    if (toVC.sourceView) {
        
        /** 判断sourceview 是否设置了 */
        UIView * snapShotView = [toVC.sourceView snapshotViewAfterScreenUpdates:NO];
        snapShotView.contentMode = UIViewContentModeScaleAspectFill;
        snapShotView.frame = [containerView convertRect:toVC.sourceView.frame fromView:toVC.sourceView.superview ? : fromVC.view];
        toVC.sourceView.hidden = YES;
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        toVC.collectionView.hidden = YES;

        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.0;
            
            XMNPhotoModel *photo = [toVC.photos objectAtIndex:toVC.currentItemIndex];
            
            CGSize size = [XMNPhotoModel adjustOriginSize:photo.imageSize
                                             toTargetSize:toVC.view.bounds.size];
            snapShotView.frame = CGRectMake(0, 0, size.width, size.height);
            snapShotView.center = containerView.center;
        } completion:^(BOOL finished) {
            
            //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
            toVC.sourceView.hidden = NO;
            toVC.collectionView.hidden = NO;
            [snapShotView removeFromSuperview];
            //告诉系统动画结束
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }else {
        /** sourceview 未设置 ,使用另外种转场方式 */
        [self normalPresentTranistionWithContext:transitionContext];
    }
}


- (void)normalPresentTranistionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //获取两个VC 和 动画发生的容器
    XMNPhotoBrowserController *toVC   = (XMNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    /** 创建一个snapShotView  */
    UIImageView *snapShotView = [[UIImageView alloc] init];
    snapShotView.contentMode = UIViewContentModeScaleAspectFill;
    snapShotView.layer.masksToBounds = YES;
    XMNPhotoModel *photo = [toVC.photos objectAtIndex:toVC.currentItemIndex];
    snapShotView.image =   photo.image ? : photo.thumbnail;

    CGSize size = [XMNPhotoModel adjustOriginSize:photo.imageSize
                                     toTargetSize:toVC.view.bounds.size];
    snapShotView.frame = CGRectMake(0, 0, size.width, size.height);
    snapShotView.center = containerView.center;
    
    snapShotView.center = containerView.center;
    snapShotView.transform = CGAffineTransformMakeScale(.1f, .1f);

    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    toVC.collectionView.hidden = YES;
    
    //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
  
        [containerView layoutIfNeeded];
        toVC.view.alpha = 1.0;
        snapShotView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
        toVC.collectionView.hidden = NO;
        [snapShotView removeFromSuperview];
        //告诉系统动画结束
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


@end


@implementation XMNPhotoBrowserDismissTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    //获取两个VC 和 动画发生的容器
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    XMNPhotoBrowserController *fromVC   = (XMNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (fromVC.sourceView) {
        /** 判断sourceview 是否设置了 */
        
        if (fromVC.currentItemIndex != fromVC.firstBrowserItemIndex) {
            
            [self normalDismissTranistionWithContext:transitionContext];
            return;
        }
        
        /** 如果当前index == firstBrowserIndex 使用返回到之前页面的动画 */
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentItemIndex inSection:0];
        
        XMNPhotoBrowserCell *browserCell = (XMNPhotoBrowserCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];

        UIView *snapShotView = [browserCell.imageView snapshotViewAfterScreenUpdates:NO];
        snapShotView.contentMode = UIViewContentModeScaleAspectFill;
        snapShotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : fromVC.view];
        
        /** 隐藏 返回的view */
        fromVC.sourceView.hidden = YES;

        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha = 0;
        
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapShotView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            [containerView layoutIfNeeded];
            toVC.view.alpha = 1.f;
            snapShotView.frame = [containerView convertRect:fromVC.sourceView.frame fromView:fromVC.sourceView.superview ? : toVC.view];
        } completion:^(BOOL finished) {
            
            fromVC.sourceView.hidden = NO;
            [snapShotView removeFromSuperview];
            //告诉系统动画结束
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }else {
        /** sourceview 未设置 ,使用另外种转场方式 */
        [self normalDismissTranistionWithContext:transitionContext];
    }
}

- (void)normalDismissTranistionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    NSLog(@"browser will dismiss normal");
    //获取两个VC 和 动画发生的容器
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    XMNPhotoBrowserController *fromVC   = (XMNPhotoBrowserController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    /** 如果当前index == firstBrowserIndex 使用返回到之前页面的动画 */
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:fromVC.currentItemIndex inSection:0];
    
    XMNPhotoBrowserCell *browserCell = (XMNPhotoBrowserCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *snapShotView = [browserCell.imageView snapshotViewAfterScreenUpdates:NO];
    snapShotView.contentMode = UIViewContentModeScaleAspectFill;
    snapShotView.frame = [containerView convertRect:browserCell.imageView.frame fromView:browserCell.imageView.superview ? : fromVC.view];
    
    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        [containerView layoutIfNeeded];
        toVC.view.alpha = 1.f;
        snapShotView.alpha = .0f;
        snapShotView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        
        [snapShotView removeFromSuperview];
        //告诉系统动画结束
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}


@end
