//
//  XMNPhotoPicker.m
//  XMNPhotoPickerFrameworkExample
//
//  Created by XMFraker on 16/2/1.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNPhotoPickerSheet.h"
#import "XMNAssetCell.h"

#import "XMNPhotoPickerController.h"
#import "XMNPhotoPreviewController.h"
#import "XMNVideoPreviewController.h"

#import "XMNPhotoManager.h"
#import "XMNAlbumModel.h"
#import "XMNAssetModel.h"
#import "XMNPhotoPickerOption.h"
#import "XMNPhotoPickerDefines.h"
#import "XMNPhotoStickLayout.h"

#import "UIImage+XMNResize.h"
#import "UIView+Animations.h"
#import "UIViewController+XMNPhotoHUD.h"

/** 手势发送图片的状态 */
typedef NS_ENUM(NSUInteger, XMNPhotoPickerSendState) {
    
    /** 即将发送图片，隐藏选择状态按钮 */
    XMNPhotoPickerWillSend,
    /** 手势发送完毕，不发送图片，显示状态按钮 */
    XMNPhotoPickerUnSend,
    /** 手势选择完毕，发送图片，显示状态按钮 */
    XMNPhotoPickerSended,
};

@interface XMNPhotoPickerCell : UICollectionViewCell;

@property (nonatomic, weak)   UIImageView *imageView;

@property (nonatomic, strong) UIView *tempView;

@property (nonatomic, weak)   UILabel *tempTipsLabel;
@property (nonatomic, weak)   UIImageView *tempImageView;

@property (nonatomic, assign) CGPoint startCenter;

@property (nonatomic, weak, readonly)   UIWindow *keyWindow;


@property (nonatomic, copy)   void(^sendAssetStateDidChange)(XMNPhotoPickerCell * _Nullable pickerCell, __weak UIView *originView, XMNPhotoPickerSendState state);


@end

@implementation XMNPhotoPickerCell


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

        NSLog(@"photopicker cell");
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.imageView = imageView];
        
        if ([XMNPhotoPickerOption isPanGestureEnabled]) {
            
            UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
            longPressGes.numberOfTouchesRequired =1;
            longPressGes.minimumPressDuration = .3f;
            [self.imageView addGestureRecognizer:longPressGes];
            self.imageView.userInteractionEnabled = YES;
        }

    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (void)prepareForReuse {
    
    self.sendAssetStateDidChange = nil;
}


/// ========================================
/// @name   Private Methods
/// ========================================


//
- (void)_handleLongPress:(UILongPressGestureRecognizer *)longPressGes {
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        //开始手势,显示tempView,隐藏tipsLabel,photoImageView,photoStateButton
        self.tempView.alpha = 1.f;
        self.tempView.hidden = NO;
        self.tempTipsLabel.hidden = YES;
        
        //记录起始center
        self.startCenter = [self.imageView convertPoint:self.imageView.center toView:self.keyWindow];
        CGRect startFrame = [self.imageView convertRect:self.imageView.frame toView:self.keyWindow];
        [self.tempView setFrame:startFrame];
        [self.tempImageView setFrame:CGRectMake(0, 0, startFrame.size.width, startFrame.size.height)];
        self.tempImageView.image = self.imageView.image;
        self.tempTipsLabel.center = CGPointMake(self.tempView.frame.size.width/2, 12);
        [self.keyWindow addSubview:self.tempView];
        
        self.sendAssetStateDidChange ? self.sendAssetStateDidChange(self, self.tempView, XMNPhotoPickerWillSend) : nil;
        
    }else if (longPressGes.state == UIGestureRecognizerStateChanged) {
        self.tempView.center = CGPointMake(self.tempView.center.x, MIN([longPressGes locationInView:self.keyWindow].y, self.startCenter.y));
        CGRect convertRect = [self.superview convertRect:self.superview.frame toView:self.keyWindow];
        if (CGRectContainsPoint(CGRectMake(0, convertRect.origin.y - self.tempView.bounds.size.height / 2, convertRect.size.width, convertRect.size.height + self.tempView.bounds.size.height / 2), self.tempView.center)) {

            self.tempTipsLabel.alpha = .0f;
            self.tempTipsLabel.hidden = YES;
        }else {
            self.tempTipsLabel.hidden = NO;
            [UIView animateWithDuration:[XMNPhotoPickerOption sendingPictureAnimationDuration] animations:^{
                self.tempTipsLabel.alpha = 1.f;
            }];
        }
    }else {
        if (!self.tempTipsLabel.hidden) {
            self.tempTipsLabel.hidden = YES;
            /** 确定发送图片 */
            self.sendAssetStateDidChange ? self.sendAssetStateDidChange(self, self.tempView, XMNPhotoPickerSended) : nil;
        }else {
            
            [UIView animateWithDuration:[XMNPhotoPickerOption sendingPictureAnimationDuration] delay:CGFLOAT_MIN options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                self.tempView.center = self.startCenter;
            } completion:^(BOOL finished) {
                self.startCenter = CGPointZero;
                [self.tempView removeFromSuperview];
                self.sendAssetStateDidChange ? self.sendAssetStateDidChange(self, self.tempView, XMNPhotoPickerUnSend) : nil;
            }];
        }
    }
}


#pragma mark - Getter

- (UIView *)keyWindow {
    return [[UIApplication sharedApplication] keyWindow];
}

- (UIView *)tempView {
    if (!_tempView) {
        _tempView = [[UIView alloc] init];
        _tempView.clipsToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.masksToBounds = YES;
        imageView.tag = [XMNPhotoPickerOption sendingImageViewTag];
        [_tempView addSubview:self.tempImageView = imageView];
        
        UILabel *tipsLabel = [[UILabel alloc] init];
        [tipsLabel setText:@"松开选择"];
        tipsLabel.font = [UIFont systemFontOfSize:10.0f];
        tipsLabel.backgroundColor = [UIColor darkGrayColor];
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.hidden = YES;
        tipsLabel.layer.cornerRadius = 10.0f;
        tipsLabel.layer.masksToBounds = YES;
        tipsLabel.frame = CGRectMake(0, 4, 55, 20);
        [_tempView addSubview:self.tempTipsLabel = tipsLabel];
    }
    return _tempView;
}

@end

@interface XMNPhotoPickerReusableView : UICollectionReusableView

@property (nonatomic, weak)   UIButton *button;

@end


@implementation XMNPhotoPickerReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"photopicker_state_normal@2x" ofType:@"png"]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageWithContentsOfFile:[[XMNPhotoPickerOption resourceBundle] pathForResource:@"photopicker_state_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];

        [button sizeToFit];
        [self addSubview:self.button = button];
    }
    return self;
}

@end



@interface XMNPhotoPickerSheet   () <UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraButtonHConstarint;
@property (weak, nonatomic) IBOutlet UIView *cameraLineView;
@property (weak, nonatomic) IBOutlet UIButton *photoLibraryButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) XMNAlbumModel *displayAlbum;
@property (nonatomic, copy) NSArray <XMNAssetModel *>* assets;
@property (nonatomic, strong) NSMutableArray <XMNAssetModel *> *selectedAssets;

@property (nonatomic, assign, readonly) CGFloat contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBConstraint;

@end

@implementation XMNPhotoPickerSheet

+ (instancetype)sharePhotoPicker {
    static id photoPicker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoPicker = [[[self class] alloc] initWithMaxCount:9];
    });
    return photoPicker;
}

- (instancetype)initWithMaxCount:(NSUInteger)maxCount {
    
    NSArray *array = [[XMNPhotoPickerOption resourceBundle] loadNibNamed:@"XMNPhotoPickerSheet" owner:nil options:nil];
    if ((self = (XMNPhotoPickerSheet *)[array firstObject])) {
        self.frame = [UIScreen mainScreen].bounds;
        [self setup];
        self.maxCount = maxCount ? : self.maxCount;
        self.autoFixImageOrientation = YES;
    }
    return self;
}

- (void)awakeFromNib {
    
    self.frame = [UIScreen mainScreen].bounds;
    [self layoutIfNeeded];
}


- (void)dealloc {
    
    NSLog(@"%@  dealloc",NSStringFromClass([self class]));
}

#pragma mark - Methods

- (void)showAnimated:(BOOL)animated {
    
    self.selectedAssets ? [self.selectedAssets removeAllObjects] : nil;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if ([self.parentController.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *parentView = (UIScrollView *)self.parentController.view;
        self.contentViewBConstraint.constant = .0f;
        parentView.scrollEnabled = NO;
    }else {
        self.contentViewBConstraint.constant = .0f;
    }
    
    if (animated) {
        [self.collectionView layoutIfNeeded];
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        }];
    }else {
        [self layoutIfNeeded];
    }
    [self.collectionView reloadData];
}

- (void)hideAnimated:(BOOL)animated {
    
    self.contentViewBConstraint.constant = - self.contentViewHeight;
    if (animated) {
        
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if ([self.parentController.view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *parentView = (UIScrollView *)self.parentController.view;
                parentView.scrollEnabled = YES;
            }
            [self removeFromSuperview];
        }];
        
    }else {
        [self layoutIfNeeded];
        [self removeFromSuperview];
    }
}

- (void)showPhotoPickerwithController:(UIViewController *)controller
                             animated:(BOOL)animated {
    
    [self.selectedAssets removeAllObjects];
    [self.assets makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    [self updatePhotoLibraryButton];
    [self.collectionView setContentOffset:CGPointZero];
    [self.collectionView reloadData];
    self.hidden = NO;
    self.parentController = controller;
    self.assets ? nil : [self loadAssets];
    [self showAnimated:animated];
}

- (void)setup {
    
    self.pickingVideoEnable = NO;
    self.maxPreviewCount = 20;
    self.maxCount = MIN(self.maxPreviewCount, NSUIntegerMax);
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.contentViewHeight);
    cancelButton.tag = kXMNCancel;
    [cancelButton addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:cancelButton belowSubview:self.contentView];
    
    iOS8Later ? [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self] : nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraButtonHConstarint.constant = 40;
        self.cameraButton.hidden = NO;
        self.cameraLineView.hidden = NO;
    }else {
        self.cameraButton.hidden = YES;
        self.cameraLineView.hidden = YES;
        self.cameraButtonHConstarint.constant = 0;
    }
    
    XMNPhotoStickLayout *stickLayout = [[XMNPhotoStickLayout alloc] init];
    stickLayout.headerReferenceSize = CGSizeMake(30, 30);
    stickLayout.minimumLineSpacing = 5.0f;
    stickLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"XMNAssetCell" bundle:[XMNPhotoPickerOption resourceBundle]] forCellWithReuseIdentifier:@"XMNAssetCell"];
    self.collectionView.collectionViewLayout = stickLayout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerClass:[XMNPhotoPickerCell class] forCellWithReuseIdentifier:@"XMNPhotoPickerCell"];
    [self.collectionView registerClass:[XMNPhotoPickerReusableView class] forSupplementaryViewOfKind:kXMNStickSupplementaryViewKind withReuseIdentifier:@"XMNPhotoPickerReusableView"];
    
    self.selectedAssets = [NSMutableArray array];
    
    self.assets ? nil : [self loadAssets];
}

- (void)loadAssets {
    
 
    if ([XMNPhotoManager sharedManager].authorizationStatus == PHAuthorizationStatusNotDetermined) {
        [self performSelector:@selector(loadAssets) withObject:nil afterDelay:.1f];
        return;
    }
    __weak typeof(*&self) wSelf = self;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[XMNPhotoManager sharedManager] getAlbumsPickingVideoEnable:self.pickingVideoEnable completionBlock:^(NSArray<XMNAlbumModel *> *albums) {
            
            __strong typeof(*&wSelf) self = wSelf;
            if (albums && [albums firstObject]) {
                self.displayAlbum = [albums firstObject];
                [[XMNPhotoManager sharedManager] getAssetsFromResult:[[albums firstObject] fetchResult] pickingVideoEnable:self.pickingVideoEnable completionBlock:^(NSArray<XMNAssetModel *> *assets) {
                    __weak typeof(*&self) self = wSelf;
                    NSMutableArray *tempAssets = [NSMutableArray array];
                    [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        __weak typeof(*&self) self = wSelf;
                        [tempAssets addObject:obj];
                        *stop = (tempAssets.count > self.maxPreviewCount);
                    }];
                    self.assets = [NSArray arrayWithArray:tempAssets];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __weak typeof(*&self) self = wSelf;
                        self.loadingView.hidden = YES;
                        [self.loadingView stopAnimating];
                        [self.collectionView reloadData];
                        [(XMNPhotoStickLayout *)self.collectionView.collectionViewLayout updateAllAttributes];
                    });
                }];
            }
        }];
    });
}

- (IBAction)handleButtonAction:(UIButton *)sender {
    switch (sender.tag) {
        case kXMNCancel:
            [self hideAnimated:YES];
            break;
        case kXMNConfirm:
        {
            if (self.selectedAssets.count == 1 && [self.selectedAssets firstObject].type == XMNAssetTypeVideo) {
                self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock([self.selectedAssets firstObject].previewImage,[self.selectedAssets firstObject]) : nil;
            }else {
                NSMutableArray *images = [NSMutableArray array];
                [self.selectedAssets enumerateObjectsUsingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    if (obj.previewImage) {
                        [images addObject:obj.previewImage];
                    }else if (obj.originImage) {
                        [images addObject:obj.originImage];
                    }else if (obj.thumbnail) {
                        [images addObject:obj.thumbnail];
                    }
                }];
                self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,self.selectedAssets) : nil;
            }
            [self hideAnimated:YES];
        }
            
            break;
        case kXMNCamera:
        {
            [self hideAnimated:NO];
            [self showImageCameraController];
        }
            break;
        case kXMNPhotoLibrary:
        {
            [self hideAnimated:NO];
            [self showPhotoPickerController];
        }
            break;
        default:
            break;
    }
}

- (void)updatePhotoLibraryButton {
    
    if (self.selectedAssets.count == 0) {
        self.photoLibraryButton.tag = kXMNPhotoLibrary;
        [self.photoLibraryButton setTitle:[NSString stringWithFormat:@"相册"] forState:UIControlStateNormal];
        [self.photoLibraryButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    }else {
        self.photoLibraryButton.tag = kXMNConfirm;
        [self.photoLibraryButton setTitle:[NSString stringWithFormat:@"确定(%d)",(int)self.selectedAssets.count] forState:UIControlStateNormal];
        [self.photoLibraryButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

- (void)showPhotoPickerController {
    
    XMNPhotoPickerController *photoPickerController = [[XMNPhotoPickerController alloc] initWithMaxCount:self.maxCount delegate:nil];
    __weak typeof(*&self) wSelf = self;
    [photoPickerController setDidFinishPickingPhotosBlock:^(NSArray<UIImage *> *images, NSArray<XMNAssetModel *> *assets) {
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingPhotosBlock ?self.didFinishPickingPhotosBlock(images,assets) : nil;
        [self.parentController dismissViewControllerAnimated:YES completion:nil];
        [self hideAnimated:YES];
    }];
    [photoPickerController setDidFinishPickingVideoBlock:^(UIImage *coverImage, id asset) {
        __weak typeof(*&self) self = wSelf;
        self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(coverImage,asset) : nil;
        [self.parentController dismissViewControllerAnimated:YES completion:nil];
        [self hideAnimated:YES];
    }];
    [self.parentController presentViewController:photoPickerController animated:YES completion:nil];
}

- (void)showImageCameraController {
    
    UIImagePickerController *imagePickerC = [[UIImagePickerController alloc] init];
    imagePickerC.delegate = self;
    imagePickerC.allowsEditing = NO;
    imagePickerC.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.parentController presentViewController:imagePickerC animated:YES completion:nil];
}


- (void)handleStateButtonAction:(UIButton *)button {
    
    XMNAssetModel *assetModel = self.assets[button.tag];
    if (!assetModel.selected) {
        if (assetModel.type == XMNAssetTypeVideo) {
            if ([self.selectedAssets firstObject] && [self.selectedAssets firstObject].type != XMNAssetTypeVideo) {
                [self.parentController showAlertWithMessage:@"不能同时选择照片和视频"];
            }else if ([self.selectedAssets firstObject]){
                [self.parentController showAlertWithMessage:@"一次只能发送1个视频"];
            }
            return;
        }else if (self.selectedAssets.count >= self.maxCount) {
            [self.parentController showAlertWithMessage:[NSString stringWithFormat:@"一次最多只能选择%d张图片",(int)self.maxCount]];
            return;
        }
        [UIView animationWithLayer:button.layer type:XMNAnimationTypeBigger];
        assetModel.selected = YES;
        [self.selectedAssets addObject:assetModel];
    }else {
        
        assetModel.selected = NO;
        [self.selectedAssets removeObject:assetModel];
    }
    button.selected = assetModel.selected;
    [self updatePhotoLibraryButton];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:MIN(self.assets.count - 1, button.tag+1) inSection:0];
    if (![self.collectionView.indexPathsForVisibleItems containsObject:nextIndexPath]) {
        [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoPickerCell *pickerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XMNPhotoPickerCell" forIndexPath:indexPath];
    pickerCell.imageView.image = self.assets[indexPath.row].previewImage;
    
    
    if ([XMNPhotoPickerOption isPanGestureEnabled]) {

        __weak typeof(*&self) wSelf = self;
        /** 配置手势发送图片功能 */
        [pickerCell setSendAssetStateDidChange:^(XMNPhotoPickerCell * cell, UIView *originView, XMNPhotoPickerSendState state) {
            
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            
            XMNPhotoPickerReusableView *reusableView = (XMNPhotoPickerReusableView *)[self.collectionView supplementaryViewForElementKind:kXMNStickSupplementaryViewKind atIndexPath:indexPath];
            if (self.assets.count > indexPath.row) {
                switch (state) {
                    case XMNPhotoPickerSended:
                    {
                        
                        void(^completedBlock)() = ^{
                            
                            __strong typeof(*&wSelf) self = wSelf;
                            cell.imageView.image = self.assets[indexPath.row].previewImage;
                            cell.imageView.transform = CGAffineTransformMakeScale(.7f, .7f);
                            originView.hidden = YES;
                            [UIView animateWithDuration:.3f animations:^{
                                cell.imageView.transform = CGAffineTransformIdentity;
                            } completion:^(BOOL finished) {
                                reusableView.button.hidden = NO;
                            }];
                        };
                        
                        self.didSendAsset ? self.didSendAsset(self.assets[indexPath.row], originView , completedBlock) : completedBlock();
                    }
                        break;
                    case XMNPhotoPickerWillSend:
                    {
                        reusableView.button.hidden = YES;
                        cell.imageView.image = nil;
                    }
                        break;
                    default:
                    {
                        reusableView.button.hidden = NO;
                        cell.imageView.image = self.assets[indexPath.row].previewImage;
                    }
                        break;
                }
            }
        }];
    }
    return pickerCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNAssetModel *asset = self.assets[indexPath.row];
    
    /** 感谢QQ上的独兄弟 提出的建议 */
    CGSize size = CGSizeZero;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if ([asset.asset isKindOfClass:[PHAsset class]]) {
        size = CGSizeMake([asset.asset pixelWidth], [asset.asset pixelHeight]);
    }else if ([asset.asset isKindOfClass:[ALAsset class]]){
        size = [[asset.asset defaultRepresentation] dimensions];
    }
#pragma clang diagnostic pop
    
    /** 增加默认scale  防止size为CGSizeZero 导致的崩溃问题 */
    CGFloat scale;
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        scale = .5f;
    }else {
        scale = (MAX(0, size.width - 10))/size.height;
    }
    return CGSizeMake(scale * (self.collectionView.frame.size.height),self.collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNAssetModel *assetModel = self.assets[indexPath.row];
    if (assetModel.type == XMNAssetTypeVideo) {
        XMNVideoPreviewController *videoPreviewC = [[XMNVideoPreviewController alloc] init];
        videoPreviewC.selectedVideoEnable = self.selectedAssets.count == 0;
        videoPreviewC.asset = assetModel;
        __weak typeof(*&self) wSelf = self;
        [videoPreviewC setDidFinishPickingVideo:^(UIImage *coverImage, XMNAssetModel *asset) {
            __weak typeof(*&self) self = wSelf;
            self.hidden = NO;
            self.didFinishPickingVideoBlock ? self.didFinishPickingVideoBlock(coverImage,asset) : nil;
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [videoPreviewC setDidFinishPreviewBlock:^{
            __strong typeof(*&wSelf) self = wSelf;
            self.hidden = NO;
        }];
        self.hidden = YES;
        [self.parentController presentViewController:videoPreviewC animated:YES completion:nil];
    }else {
        
        XMNPhotoPreviewController *previewC = [[XMNPhotoPreviewController alloc] initWithCollectionViewLayout:[XMNPhotoPreviewController photoPreviewViewLayoutWithSize:[UIScreen mainScreen].bounds.size]];
        previewC.assets = self.assets;
        previewC.maxCount = self.maxCount;
        previewC.selectedAssets = [NSMutableArray arrayWithArray:self.selectedAssets];
        previewC.currentIndex = indexPath.row;
        __weak typeof(*&self) wSelf = self;
        [previewC setDidFinishPreviewBlock:^(NSArray<XMNAssetModel *> *selectedAssets) {
            
            __weak typeof(*&self) self = wSelf;
            self.hidden = NO;
            self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
            [self updatePhotoLibraryButton];
            [self.collectionView reloadData];
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [previewC setDidFinishPickingBlock:^(NSArray<UIImage *> *images, NSArray<XMNAssetModel *> *assets) {
            
            __weak typeof(*&self) self = wSelf;
            self.hidden = NO;
            [self.selectedAssets removeAllObjects];
            self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(images,assets) : nil;
            [self hideAnimated:NO];
            [self.parentController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        self.hidden = YES;
        [self.parentController presentViewController:previewC animated:YES completion:nil];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    XMNPhotoPickerReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kXMNStickSupplementaryViewKind withReuseIdentifier:@"XMNPhotoPickerReusableView" forIndexPath:indexPath];
    reusableView.button.selected = self.assets[indexPath.row].selected;
    reusableView.button.tag = indexPath.row;
    [reusableView.button removeTarget:self action:@selector(handleStateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [reusableView.button addTarget:self action:@selector(handleStateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return reusableView;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.hidden = YES;
    [self removeFromSuperview];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
    [self hideAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.autoFixImageOrientation ?  image = [image xmn_fixImageOrientation] : nil;
    self.didFinishPickingPhotosBlock ? self.didFinishPickingPhotosBlock(@[image], nil) : nil;
    [self.parentController dismissViewControllerAnimated:YES completion:nil];
    [self hideAnimated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver


- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    __weak typeof(*&self) wSelf = self;
    // Photos may call this method on a background queue;
    // switch to the main queue to update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check for changes to the list of assets (insertions, deletions, moves, or updates).
        PHFetchResultChangeDetails *collectionChanges = [changeInfo changeDetailsForFetchResult:self.displayAlbum.fetchResult];
        if (collectionChanges) {
            // Get the new fetch result for future change tracking.
            XMNAlbumModel *changeAlbumModel = [XMNAlbumModel albumWithResult:collectionChanges.fetchResultAfterChanges name:@"afterChange"];
            self.displayAlbum = changeAlbumModel;
            if (collectionChanges.hasIncrementalChanges)  {
                [[XMNPhotoManager sharedManager] getAssetsFromResult:self.displayAlbum.fetchResult pickingVideoEnable:self.pickingVideoEnable completionBlock:^(NSArray<XMNAssetModel *> *assets) {
                    __weak typeof(*&self) self = wSelf;
                    NSMutableArray *tempAssets = [NSMutableArray array];
                    [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XMNAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        __weak typeof(*&self) self = wSelf;
                        [tempAssets addObject:obj];
                        *stop = ( tempAssets.count > self.maxPreviewCount);
                    }];
                    self.assets = [NSArray arrayWithArray:tempAssets];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __weak typeof(*&self) self = wSelf;
                        [self.collectionView reloadData];
                    });
                }];
            } else {
                // Detailed change information is not available;
                // repopulate the UI from the current fetch result.
                [self.collectionView reloadData];
            }
        }
    });
}

- (NSArray <NSIndexPath *> *)_indexPathsFromIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:self.displayAlbum.count - idx inSection:0]];
    }];
    return indexPaths;
}
#pragma mark - Getters

- (CGFloat)contentViewHeight {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return 41 * 3 + 160 + 8;
    }else {
        return 41 * 2  + 160 + 8;
    }
}

@end
