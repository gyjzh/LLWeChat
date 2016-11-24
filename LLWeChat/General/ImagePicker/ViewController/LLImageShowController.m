//
//  LLPhotoPreviewController.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageShowController.h"
#import "LLImageSelectIndicator.h"
#import "LLPhotoToolbar.h"
#import "LLImageScrollView.h"
#import "LLAssetManager.h"
#import "LLImagePickerController.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import "UINavigationBar+LLExt.h"
#import "LLImagePickerConfig.h"

@interface LLImageShowController () <UIScrollViewDelegate>

@property (nonatomic) LLImageScrollView *curShowScrollView;

@property (nonatomic) LLImageSelectIndicator *bigSelectView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<LLImageScrollView *> *innerScrollViews;
@property (nonatomic) LLPhotoToolbar *toolbar;

@end

@implementation LLImageShowController {
    NSInteger length;
    CGFloat scroll_width;
    CGPoint screenCenter;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    scroll_width = SCREEN_WIDTH + INTERVAL;
    screenCenter = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    length = _allAssets.count >= 3 ? 3: _allAssets.count;

    [self setupNavigationBar];
    [self setupViews];

    //添加Gesture
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
    
    [tapGR requireGestureRecognizerToFail:tapGesture];
    
    [self showAllImage];
    
}
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)setupNavigationBar {
    self.view.backgroundColor = [UIColor blackColor];
    CGRect frame = self.navigationController.navigationBar.subviews[0].frame;
    frame.size.height = 64;
    self.navigationController.navigationBar.frame = frame;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -8;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FriendsSendsPicturesQuitBigIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
    [leftItem setTitlePositionAdjustment:UIOffsetMake(20, 0) forBarMetrics:UIBarMetricsDefault];
    [leftItem setBackgroundVerticalPositionAdjustment:-8 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItems = @[spaceItem, leftItem];
    
    _bigSelectView = [[LLImageSelectIndicator alloc] init];
    [_bigSelectView addTarget:self action:@selector(doSelect:)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: _bigSelectView];
    _bigSelectView.selected = [self.allSelectdAssets containsObject:self.curShowAsset];
    
    self.navigationItem.rightBarButtonItems = @[spaceItem, rightItem];
    
}

- (void)setupViews {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scroll_width, SCREEN_HEIGHT)];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_allAssets.count * scroll_width, SCREEN_HEIGHT);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    [self.view addSubview:_scrollView];
    
    self.innerScrollViews = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (int i=0; i < length; i++) {
        LLImageScrollView * _innerScrollView = [[LLImageScrollView alloc] init];
        _innerScrollView.delegate = self;
        [self.innerScrollViews addObject:_innerScrollView];

        [self.scrollView addSubview:_innerScrollView];
    }
    
    _toolbar = [[LLPhotoToolbar alloc] initWithStyle:kLLPhotoToolbarStyle2];
    [_toolbar addTarget:self previewAction:nil finishAction:@selector(doFinish)];
    self.toolbar.number = self.allSelectdAssets.count;
    [self.view addSubview:_toolbar];
    
}

- (BOOL)doSelect:(BOOL)isCurSelected {
    if (!isCurSelected) {
        if (self.allSelectdAssets.count == MAX_PHOTOS_CAN_SELECT) {
            [LLUtils showMessageAlertWithTitle:nil message:[NSString stringWithFormat:@"最多选择%d张照片", MAX_PHOTOS_CAN_SELECT] actionTitle:@"我知道了"];
            return NO;
        }else if (![self.allSelectdAssets containsObject:self.curShowAsset]) {
            [self.allSelectdAssets addObject:self.curShowAsset];
        }
    }else if ([self.allSelectdAssets containsObject:self.curShowAsset]) {
        [self.allSelectdAssets removeObject:self.curShowAsset];
    }
    
    self.toolbar.number = self.allSelectdAssets.count;
    
    return YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barAlpha = 0.6;
}


#pragma mark - 加载照片

- (void)fillScrollView:(LLImageScrollView *)scrollView withAssetIndex:(NSInteger)assetIndex {
    scrollView.assetIndex = assetIndex;
    scrollView.assetModel = _allAssets[assetIndex];

    LLFetchImageSyncCallbackBlock syncCallback = ^(UIImage *_Nullable image, BOOL needBackgroundLoading) {
        [scrollView setContentWithImage:image];
    };
    
    WEAK_SELF;
    LLFetchImageAsyncCallbackBlock asyncCallback = ^(UIImage *_Nullable image, LLAssetModel *_Nullable assetModel) {
        for (LLImageScrollView *scrollView in weakSelf.innerScrollViews) {
            if (scrollView.assetModel == assetModel) {
                [scrollView setContentWithImage:image];
                if (assetModel == weakSelf.curShowAsset) {
                    [weakSelf setImageSelectStatus];
                }
                break;
            }
        }
    };
    
    if (scrollView.assetModel.isAssetInLocalAlbum) {
        [[LLAssetManager sharedAssetManager] fetchImageFromAssetModel:scrollView.assetModel asyncBlock:asyncCallback syncBlock:syncCallback];
    }else {
        [scrollView setContentWithImage:nil];
    }
    
    [scrollView setContentWithImage:[UIImage imageNamed:@"ff_IconShake"]];
    
    scrollView.frame = CGRectMake(scroll_width * assetIndex, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (void)showAllImage {
    NSInteger showIndex = [_allAssets indexOfObject:self.curShowAsset];
    NSInteger from = showIndex -1;
    if (showIndex == 0) {
        from = showIndex;
    }else if (showIndex == _allAssets.count - 1) {
        from = showIndex -(length-1);
    }
    
    NSInteger assetIndex = from;
    for (LLImageScrollView *scrollView in self.innerScrollViews) {
        [self fillScrollView:scrollView withAssetIndex:assetIndex];
        
        assetIndex ++;
    }

    self.scrollView.contentOffset = CGPointMake(scroll_width * showIndex, 0);
    self.curShowScrollView = self.innerScrollViews[showIndex - from];

}

- (void)setImageSelectStatus {
    if (_curShowScrollView.isImageExist) {
        self.bigSelectView.hidden = NO;
        self.bigSelectView.selected = [self.allSelectdAssets containsObject:self.curShowAsset];
    }else {
        self.bigSelectView.hidden = YES;
    }
}

#pragma mark - 处理左右拖动

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollWillBeginDragging");
    
    if (scrollView != self.scrollView) {
        for (LLImageScrollView *scrollView in self.innerScrollViews) {
            scrollView.hidden = YES;
        }
        scrollView.hidden = NO;
    }else {
        for (LLImageScrollView *scrollView in self.innerScrollViews) {
            scrollView.hidden = NO;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView)return;
    
    if (_allAssets.count == 1)return;

    //以照片是否越过屏幕中间分割线为依据，滑动距离越过了中间分割线，就表示显示的照片更换了
    //不等到照片完全划出屏幕
    CGPoint point = [self.view convertPoint:screenCenter toView:self.scrollView];

    for (int i=0; i<length; i++) {
        LLImageScrollView *innerScrollView = self.innerScrollViews[i];
        
        if (CGRectContainsPoint(innerScrollView.frame, point)) {
            if (_curShowScrollView == innerScrollView)return;
            
            //如果照片处于放大状态，此时将他还原
            if (_curShowScrollView.zoomScale >= 1 + FLT_EPSILON) {
                _curShowScrollView.scrollEnabled = NO;
                [_curShowScrollView setZoomScale:1.0 animated:NO];
                _curShowScrollView.scrollEnabled = YES;
            }
            
            _curShowScrollView = innerScrollView;
            
            //判断当前显示照片是否已被选择
            NSInteger assetIndex = innerScrollView.assetIndex;
            self.curShowAsset = self.allAssets[assetIndex];
            [self setImageSelectStatus];
            
            //移动前后照片
            if (assetIndex + 1 < _allAssets.count && [self scrollViewWithAssetIndex:assetIndex + 1] == nil) {
                [self fillScrollView:[self scrollViewWithAssetIndex:assetIndex - 2] withAssetIndex:assetIndex + 1];
            }else if (assetIndex - 1 >=0 && [self scrollViewWithAssetIndex:assetIndex - 1] == nil) {
                [self fillScrollView: [self scrollViewWithAssetIndex:assetIndex + 2] withAssetIndex:assetIndex - 1];
            }
            
            break;
        }
    }
    
 }



#pragma mark - 处理缩放

- (UIView *)viewForZoomingInScrollView:(LLImageScrollView *)scrollView {
    return scrollView.imageView;
}

//处理双击放大、缩小
- (void)handleZoom:(UITapGestureRecognizer *)tap {
    if (_curShowScrollView.isZooming)return;
    if (_curShowScrollView.imageView.hidden)return;
    CGFloat zoomScale = _curShowScrollView.zoomScale;
    
    if(zoomScale < 1.0 + FLT_EPSILON){
        CGPoint loc = [tap locationInView: _curShowScrollView];
        CGRect rect = CGRectMake(loc.x - 0.5, loc.y - 0.5, 1, 1);
        
        [_curShowScrollView zoomToRect:rect animated:YES];
    }else {
        [_curShowScrollView setZoomScale:1 animated:YES];
    }
    
}


- (void)scrollViewDidZoom:(LLImageScrollView *)scrollView {
    UIImageView *zoomImageView = (UIImageView *)[self viewForZoomingInScrollView: scrollView];
    
    CGRect frame = zoomImageView.frame;
    
    //当视图不能填满整个屏幕时，让其居中显示
    frame.origin.x = (SCREEN_WIDTH > CGRectGetWidth(frame)) ? (SCREEN_WIDTH - CGRectGetWidth(frame))/2 : 0;
    frame.origin.y = (SCREEN_HEIGHT > CGRectGetHeight(frame)) ? (SCREEN_HEIGHT - CGRectGetHeight(frame))/2 : 0;
    if (fabs(scrollView.zoomScale - 1.0) < FLT_EPSILON) {
        frame.size = scrollView.imageSize;
        scrollView.contentSize = frame.size;
    }

    zoomImageView.frame = frame;

}


#pragma mark - 其他

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    NSLog(@"TapTp");
    
    self.toolbar.hidden = !self.toolbar.isHidden;
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doFinish {
    [(LLImagePickerController *)self.navigationController didFinishPickingImages:self.allSelectdAssets WithError:nil assetGroupModel:self.assetGroupModel];
}

- (LLImageScrollView *)scrollViewWithAssetIndex:(NSInteger)assetIndex {
    for (LLImageScrollView *scrollView in self.innerScrollViews) {
        if (scrollView.assetIndex == assetIndex)
            return scrollView;
    }
    
    return nil;
}



@end
