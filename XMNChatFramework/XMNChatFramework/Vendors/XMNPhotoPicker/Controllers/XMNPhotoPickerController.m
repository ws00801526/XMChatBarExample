//
//  XMNPhotoPickerController.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/1/28.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoPickerController.h"
#import "XMNPhotoCollectionController.h"

#import "XMNPhotoManager.h"
#import "XMNAlbumModel.h"
#import "XMNAssetModel.h"
#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"

#import "XMNAlbumCell.h"

@interface XMNAlbumListController ()

- (void)loadAlbums;

@end

@interface XMNPhotoPickerController ()

@end

@implementation XMNPhotoPickerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#pragma mark - XMNPhotoPickerController Life Cycle

- (instancetype)initWithMaxCount:(NSUInteger)maxCount
                        delegate:(id<XMNPhotoPickerControllerDelegate>)delegate {
    
    XMNAlbumListController *albumListC = [[XMNAlbumListController alloc] init];
    if (self = [super initWithRootViewController:albumListC]) {
        _photoPickerDelegate = delegate;
        _maxCount = maxCount ? : NSUIntegerMax;
        _autoPushToPhotoCollection = YES;
        _pickingVideoEnable = NO;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupNavigationBarAppearance];
    
}

/**
 *  重写viewWillAppear方法
 *  判断是否需要自动push到第一个相册专辑内
 *  @param animated 是否需要动画
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self handleAuthorized];
}

- (void)dealloc {
    NSLog(@"photo picker dealloc");
}

#pragma mark - XMNPhotoPickerController Methods

- (void)handleAuthorized {
    
    if ([XMNPhotoManager sharedManager].authorizationStatus == PHAuthorizationStatusNotDetermined) {
        //未决定是否授权 -> 启动定时器
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

        }];
        [self performSelector:@selector(handleAuthorized) withObject:nil afterDelay:.1f];
        return;
    }
    
    if ([[XMNPhotoManager sharedManager] hasAuthorized]) {
        //已授权
        [self autoPushPhotoCollectionViewController];
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            if ([obj isKindOfClass:[XMNAlbumListController class]]) {
                
                [(XMNAlbumListController *)obj loadAlbums];
                *stop =  YES;
            }
        }];
    }else {
        //未授权
        [self showUnAuthorizedTips];
    }
}

/**
 *  自动前往照片列表页面
 */
- (void)autoPushPhotoCollectionViewController {
    
    if (self.autoPushToPhotoCollection) {
        XMNPhotoCollectionController *photoCollectionC = [[XMNPhotoCollectionController alloc] initWithCollectionViewLayout:[XMNPhotoPickerOption photoCollectionViewLayoutWithWidth:self.view.frame.size.width]];
        __weak typeof(*&self) wSelf = self;
        [[XMNPhotoManager sharedManager] getAlbumsPickingVideoEnable:self.pickingVideoEnable completionBlock:^(NSArray<XMNAlbumModel *> *albums) {
            __weak typeof(*&self) self = wSelf;
            photoCollectionC.album = [albums firstObject];
            [self pushViewController:photoCollectionC animated:NO];
        }];
    }
}

/**
 *  call photoPickerDelegate & didFinishPickingPhotosBlock
 *
 *  @param assets 具体回传的资源
 */
- (void)didFinishPickingPhoto:(NSArray<XMNAssetModel *> *)assets {
    
    NSMutableArray *images = [NSMutableArray array];
    [assets enumerateObjectsUsingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (obj.previewImage) {
            [images addObject:obj.previewImage];
        }else if (obj.originImage) {
            [images addObject:obj.originImage];
        }else if (obj.thumbnail) {
            [images addObject:obj.thumbnail];
        }
    }];
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:sourceAssets:)]) {
        [self.photoPickerDelegate photoPickerController:self didFinishPickingPhotos:images sourceAssets:assets];
    }
    self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,assets) : nil;
}

- (void)didFinishPickingVideo:(XMNAssetModel *)asset {
    
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingVideo:sourceAssets:)]) {
        [self.photoPickerDelegate photoPickerController:self didFinishPickingVideo:asset.previewImage sourceAssets:asset];
    }
    
    self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(asset.previewImage , asset) : nil;
}

- (void)didCancelPickingPhoto {
    if (self.photoPickerDelegate && [self.photoPickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.photoPickerDelegate photoPickerControllerDidCancel:self];
    }
    self.didCancelPickingBlock ? self.didCancelPickingBlock() : nil;
}

/**
 *  显示用户拒绝授权提示
 */
- (void)showUnAuthorizedTips {
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.frame = CGRectMake(8, 64, self.view.frame.size.width - 16, 300);
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = [UIFont systemFontOfSize:16];
    tipsLabel.textColor = [UIColor blackColor];
    tipsLabel.userInteractionEnabled = YES;
    NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
    tipsLabel.text = [NSString stringWithFormat:@"请在%@的\"设置-隐私-照片\"选项中，\r允许%@访问你的手机相册。",[UIDevice currentDevice].model,appName];
    [self.view addSubview:tipsLabel];
    
    //!!! bug 用户前往设置后,修改授权会导致app崩溃
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTipsTapAction)];
    [tipsLabel addGestureRecognizer:tap];
}


/**
 *  处理当用户未授权访问相册时 tipsLabel的点击手势,暂时有bug
 */
- (void)handleTipsTapAction {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

/**
 *  设置navigationBar的样式
 */
- (void)setupNavigationBarAppearance {
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if (iOS7Later) {
        self.navigationBar.barTintColor = kXMNBarBackgroundColor;
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UINavigationBar *navigationBar;
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[XMNPhotoPickerController class]]];
        navigationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[XMNPhotoPickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[XMNPhotoPickerController class], nil];
        navigationBar = [UINavigationBar appearanceWhenContainedIn:[XMNPhotoPickerController class], nil];
    }
    [barItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f]}];
    [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}


@end

@implementation XMNAlbumListController

#pragma mark - XMNAlbumListController Life Cycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_handleCancelAction)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 70.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"XMNAlbumCell" bundle:[XMNPhotoPickerOption resourceBundle]] forCellReuseIdentifier:@"XMNAlbumCell"];
    

    [self loadAlbums];
}



#pragma mark - XMNAlbumListController Methods

/**
 *  获取相册
 */
- (void)loadAlbums {
    
    if ([XMNPhotoManager sharedManager].authorizationStatus == PHAuthorizationStatusNotDetermined) {
        return;
    }
    XMNPhotoPickerController *imagePickerVC = (XMNPhotoPickerController *)self.navigationController;
    __weak typeof(*&self) wSelf = self;
    [[XMNPhotoManager sharedManager] getAlbumsPickingVideoEnable:imagePickerVC.pickingVideoEnable completionBlock:^(NSArray<XMNAlbumModel *> *albums) {
        __strong typeof(*&wSelf) self = wSelf;
        self.albums = [NSArray arrayWithArray:albums];
        [self.tableView reloadData];
    }];
}

- (void)_handleCancelAction {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    XMNPhotoPickerController *photoPickerVC = (XMNPhotoPickerController *)self.navigationController;
    [photoPickerVC didCancelPickingPhoto];
    
}


#pragma mark - XMNAlbumListController UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNAlbumCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"XMNAlbumCell"];
    [albumCell configCellWithItem:self.albums[indexPath.row]];
    return albumCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoCollectionController *photoCollectionC = [[XMNPhotoCollectionController alloc] initWithCollectionViewLayout:[XMNPhotoPickerOption photoCollectionViewLayoutWithWidth:self.view.frame.size.width]];
    photoCollectionC.album = self.albums[indexPath.row];
    [self.navigationController pushViewController:photoCollectionC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


#pragma clang diagnostic pop

