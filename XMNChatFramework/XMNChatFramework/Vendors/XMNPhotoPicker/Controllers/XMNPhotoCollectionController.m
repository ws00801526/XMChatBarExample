//
//  XMNPhotoCollectionController.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoCollectionController.h"
#import "XMNPhotoPickerController.h"
#import "XMNPhotoPreviewController.h"
#import "XMNVideoPreviewController.h"


#import "XMNAlbumModel.h"
#import "XMNAssetModel.h"
#import "XMNPhotoManager.h"
#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"

#import "XMNAssetCell.h"
#import "XMNBottomBar.h"

#import "UIViewController+XMNPhotoHUD.h"

@interface XMNPhotoCollectionController ()

/** 底部状态栏 */
@property (nonatomic, weak)   XMNBottomBar *bottomBar;

/** 相册内所有的资源 */
@property (nonatomic, copy)   NSArray<XMNAssetModel *> *assets;
/** 选择的所有资源 */
@property (nonatomic, strong) NSMutableArray *selectedAssets;

/** 第一次进入时,自动滚动到底部 */
@property (nonatomic, assign) BOOL autoScrollToBottom;

@end

@implementation XMNPhotoCollectionController

static NSString * const kXMNAssetCellIdentifier = @"XMNAssetCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    
    
    self.navigationItem.title = self.album.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_handleCancelAction)];
    
    self.autoScrollToBottom = YES;
    self.selectedAssets = [NSMutableArray array];
    
    // 初始化collectionView的一些属性
    [self _setupCollectionView];
    [self _setupConstraints];
    
    //从相册中获取所有的资源model
    __weak typeof(*&self) wSelf = self;
    [[XMNPhotoManager sharedManager] getAssetsFromResult:self.album.fetchResult pickingVideoEnable:[(XMNPhotoPickerController *)self.navigationController pickingVideoEnable] completionBlock:^(NSArray<XMNAssetModel *> *assets) {
        __weak typeof(*&self) self = wSelf;
        self.assets = [NSArray arrayWithArray:assets];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __weak typeof(*&self) self = wSelf;
           [self.assets enumerateObjectsUsingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               [obj thumbnail];
           }];
        });
        [self.collectionView reloadData];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.autoScrollToBottom ?  [self.collectionView setContentOffset:CGPointMake(0, (self.assets.count / 4) * kXMNThumbnailWidth)] : nil;
    self.autoScrollToBottom = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"photo collection dealloc ");
}

#pragma mark - Methods

- (void)_setupCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(4, 4, 54, 4);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    self.collectionView.contentSize = CGSizeMake(self.view.frame.size.width, ((self.assets.count + 3) / 4) * self.view.frame.size.width);
    [self.collectionView registerNib:[UINib nibWithNibName:kXMNAssetCellIdentifier bundle:[XMNPhotoPickerOption resourceBundle]] forCellWithReuseIdentifier:kXMNAssetCellIdentifier];
    
    XMNBottomBar *bottomBar = [[XMNBottomBar alloc] initWithBarType:XMNCollectionBottomBar];
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;

    __weak typeof(*&self) wSelf = self;
    [bottomBar setConfirmBlock:^{
        __weak typeof(*&self) self = wSelf;
        [(XMNPhotoPickerController *)self.navigationController didFinishPickingPhoto:self.selectedAssets];
    }];
    [self.view addSubview:self.bottomBar = bottomBar];
}

- (void)_setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50.0f]];
}

- (void)_handleCancelAction {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    XMNPhotoPickerController *photoPickerVC = (XMNPhotoPickerController *)self.navigationController;
    [photoPickerVC didCancelPickingPhoto];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    XMNAssetCell *assetCell = [collectionView dequeueReusableCellWithReuseIdentifier:kXMNAssetCellIdentifier forIndexPath:indexPath];
    [assetCell configCellWithItem:self.assets[indexPath.row]];
    __weak typeof(*&self) wSelf = self;
    
    // 设置assetCell willChangeBlock
    [assetCell setWillChangeSelectedStateBlock:^BOOL(XMNAssetModel *asset) {
        __weak typeof(*&self) self = wSelf;
        if (!asset.selected) {
            XMNPhotoPickerController *photoPickerC = (XMNPhotoPickerController *)self.navigationController;
            if (asset.type == XMNAssetTypeVideo && self.selectedAssets.count > 0) {
                NSLog(@"同时选择视频和图片,视频将作为图片发送");
                [self showAlertWithMessage:@"同时选择视频和图片,视频将作为图片发送"];
                return YES;
            }else if (self.selectedAssets.count >= photoPickerC.maxCount) {
                [self showAlertWithMessage:[NSString stringWithFormat:@"最多只能选择%ld张照片",(unsigned long)photoPickerC.maxCount]];
                return NO;
            }
            return YES;
        }else {
            return NO;
        }
    }];
    
    // 设置assetCell didChangeBlock
    [assetCell setDidChangeSelectedStateBlock:^(BOOL selected, XMNAssetModel *asset) {
        __weak typeof(*&self) self = wSelf;
        if (selected) {
            [self.selectedAssets containsObject:asset] ? nil : [self.selectedAssets addObject:asset];
            asset.selected = YES;
        }else {
            [self.selectedAssets containsObject:asset] ? [self.selectedAssets removeObject:asset] : nil;
            asset.selected = NO;
        }
        [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
    }];
    
    return assetCell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XMNAssetModel *assetModel = self.assets[indexPath.row];
    if (assetModel.type == XMNAssetTypeVideo) {
        XMNVideoPreviewController *videoPreviewC = [[XMNVideoPreviewController alloc] init];
        videoPreviewC.selectedVideoEnable = self.selectedAssets.count == 0;
        videoPreviewC.asset = assetModel;
        __weak typeof(*&self) wSelf = self;
        [videoPreviewC setDidFinishPickingVideo:^(UIImage *coverImage, XMNAssetModel *asset) {
            __weak typeof(*&self) self = wSelf;
            [(XMNPhotoPickerController *)self.navigationController didFinishPickingVideo:asset];
        }];
        [self.navigationController pushViewController:videoPreviewC animated:YES];
    }else {
        XMNPhotoPreviewController *previewC = [[XMNPhotoPreviewController alloc] initWithCollectionViewLayout:[XMNPhotoPreviewController photoPreviewViewLayoutWithSize:[UIScreen mainScreen].bounds.size]];
        previewC.assets = self.assets;
        previewC.selectedAssets = self.selectedAssets;
        previewC.currentIndex = indexPath.row;
        previewC.maxCount = [(XMNPhotoPickerController *)self.navigationController maxCount];
        __weak typeof(*&self) wSelf = self;
        [previewC setDidFinishPreviewBlock:^(NSArray<XMNAssetModel *> *selectedAssets) {
            __weak typeof(*&self) self = wSelf;
            [self.bottomBar updateBottomBarWithAssets:self.selectedAssets];
            [self.collectionView reloadData];
        }];
        
        [previewC setDidFinishPickingBlock:^(NSArray<UIImage *> *images, NSArray<XMNAssetModel *> *selectedAssets) {
           __weak typeof(*&self) self = wSelf;
            [(XMNPhotoPickerController *)self.navigationController didFinishPickingPhoto:selectedAssets];
        }];
        
        [self.navigationController pushViewController:previewC animated:YES];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


@end
