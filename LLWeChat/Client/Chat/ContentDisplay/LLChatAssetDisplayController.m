//
//  LLChatAssetDisplayController.m
//  LLWeChat
//
//  Created by GYJZH on 8/16/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatAssetDisplayController.h"
#import "LLChatImageScrollView.h"
#import "LLActionSheet.h"
#import "LLMessageImageCell.h"
#import "LLUtils.h"
#import "LLSDK.h"
#import "LLConfig.h"
#import "UIKit+LLExt.h"
#import "LLVideoPlaybackController.h"
#import "LLImageBottomBar.h"
#import "LLImageAnimationView.h"
#import "LLVideoDisplayView.h"
#import "LLVideoPlaybackController.h"

//每张图片之间的间隔
#define INTERVAL 25
#define TIMER_INTERVAL 5

#define BOTTOM_BAR_HEIGHT 55

#define BOTTOM_BAR_STYLE_Video 4

typedef UIView<LLAssetDisplayView> LLAssetView;

typedef NS_ENUM(NSInteger, LLAssetBottomBarStyle) {
    kLLAssetBottomBarStyleNone = 0,
    kLLAssetBottomBarStyleImageHide,
    kLLAssetBottomBarStyleImageShow,
    kLLAssetBottomBarStyleVideo
};


@interface LLChatAssetDisplayController () <UIScrollViewDelegate, LLVideoPlaybackDelegate>

@property (nonatomic) LLAssetView *curAssetView;
@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIButton *button;
@property (nonatomic) UIButton *closeButton;

@property (nonatomic) LLImageBottomBar *imageBottomBar;
@property (nonatomic) UIView *videoBottomBar;
//@property (nonatomic) UIView *statusView;

@property (nonatomic) LLImageAnimationView *imageAnimationView;

@property (nonatomic) NSMutableArray<LLAssetView *> *allAssetViews;

@property (nonatomic) LLVideoPlaybackController *videoPlaybackController;

@end

@implementation LLChatAssetDisplayController {
    NSInteger length;
    NSInteger scroll_width;
    CGPoint screenCenter;
    BOOL scrollToTop;
    __weak LLActionSheet *actionSheet;
    
    NSTimer *timer;
    LLAssetBottomBarStyle bottomBarStyle;
    
    NSMutableSet<NSString *> *downloadingMessageIds;
    NSMutableSet<NSString *> *downloadFailedMessageIds;
    BOOL needUpdateStatusView;
    BOOL needAutoPlayVideo;
    BOOL needAutoStopVideo;
    BOOL shouldExitAfterRotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LLUtils configAudioSessionForPlayback];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    length = _allAssets.count >= 3 ? 3: _allAssets.count;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    self.allAssetViews = [NSMutableArray arrayWithCapacity:2 * length];
    
    downloadingMessageIds = [NSMutableSet set];
    downloadFailedMessageIds = [NSMutableSet set];
    if (_curShowMessageModel.isVideoPlayable) {
        needAutoPlayVideo = YES;
    }else if ((_curShowMessageModel.messageBodyType == kLLMessageBodyTypeVideo) &&
              ((_curShowMessageModel.messageDownloadStatus == kLLMessageDownloadStatusPending) || (_curShowMessageModel.messageDownloadStatus == kLLMessageDownloadStatusFailed))){
        [self downloadAttachmentForMessageModel:_curShowMessageModel];
    }
    
    [self setupViews];
    [self addGestures];
    [self registerChatManagerNotification];
    
    [self showAllAssets];
    [self layoutAssetViews:SCREEN_SIZE];
}

- (void)dealloc {
    [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addGestures {
     //添加Gesture
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    [tapGR requireGestureRecognizerToFail:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAction:)];
    [self.view addGestureRecognizer:longPressGesture];

}


- (void)setupViews {
    self.scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_allAssets.count * scroll_width, SCREEN_HEIGHT);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < length; i++) {
        LLChatImageScrollView *imageScrollView = [[LLChatImageScrollView alloc] initWithFrame:SCREEN_FRAME];
        imageScrollView.hidden = YES;
        imageScrollView.delegate = self;
        [_scrollView addSubview:imageScrollView];
        [_allAssetViews addObject:imageScrollView];
        
        LLVideoDisplayView *videoView = [[LLVideoDisplayView alloc] initWithFrame:SCREEN_FRAME];
        videoView.hidden = YES;
        videoView.chatAssetDisplayController = self;
        [_scrollView addSubview:videoView];
        [_allAssetViews addObject:videoView];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 显示视频、照片 -

- (void)showAllAssets {
    NSInteger showIndex = [_allAssets indexOfObject:self.curShowMessageModel];
    NSInteger from = showIndex -1;
    if (showIndex == 0) {
        from = showIndex;
    }else if (showIndex == _allAssets.count - 1) {
        from = showIndex - (length - 1);
    }
    
    NSInteger assetIndex = from;
    for (NSInteger i = 0; i< length; i++) {
        LLAssetView *assetView = [self showAssetViewWithAssetIndex:assetIndex];
        assetIndex++;
        if (i == showIndex - from)
            _curAssetView = assetView;
    }
    
    self.scrollView.contentOffset = CGPointMake(scroll_width * showIndex, 0);
    bottomBarStyle = kLLAssetBottomBarStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if ([_curAssetView isKindOfClass:[LLChatImageScrollView class]]) {
        LLChatImageScrollView *imageScrollView = (LLChatImageScrollView *)_curAssetView;

        CGRect frame = imageScrollView.imageView.frame;
        CGRect fromRect = [[LLUtils currentWindow] convertRect:self.originalWindowFrame toView:_curAssetView];
        imageScrollView.imageView.frame = fromRect;

        [LLUtils currentWindow].userInteractionEnabled = NO;
        [UIView animateWithDuration:DEFAULT_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut                   animations:^{
                                imageScrollView.imageView.frame = frame;
                            }
                         completion:^(BOOL finished) {
                             [self showBottomBar];
                             [self checkDownloadStatus];
                             [LLUtils currentWindow].userInteractionEnabled = YES;
                         }];
        
    }else if ([_curAssetView isKindOfClass:[LLVideoDisplayView class]]) {
        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)_curAssetView;
        CGRect frame = videoDisplayView.imageView.frame;
        CGRect fromRect = [[LLUtils currentWindow] convertRect:self.originalWindowFrame toView:self.view];
        videoDisplayView.imageView.frame = fromRect;
        
        [LLUtils currentWindow].userInteractionEnabled = NO;
        [UIView animateWithDuration:DEFAULT_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                                videoDisplayView.imageView.frame = frame;
                            }
                         completion:^(BOOL finished){
                             [self showBottomBar];
                             [self checkDownloadStatus];
                             [LLUtils currentWindow].userInteractionEnabled = YES;
                         }];
    }
    
}

#pragma mark - 屏幕旋转 -

- (void)layoutAssetViews:(CGSize)size {
    if (size.width + INTERVAL == scroll_width)
        return;
    
    [actionSheet hideInWindow:self.view.window];
    
    scroll_width = size.width + INTERVAL;
    screenCenter = CGPointMake(size.width/2, size.height/2);
    _scrollView.frame = CGRectMake(0, 0, scroll_width, size.height);
    for (UIView<LLAssetDisplayView> *view in self.scrollView.subviews) {
        if (view.assetIndex >= 0) {
            view.frame = CGRectMake(view.assetIndex * scroll_width, 0, size.width, size.height);
            if (view.messageBodyType == kLLMessageBodyTypeImage) {
                LLChatImageScrollView *imageScrollView = (LLChatImageScrollView *)view;
                if (imageScrollView.zoomScale >= 1 + FLT_EPSILON) {
                    imageScrollView.scrollEnabled = NO;
                    [imageScrollView setZoomScale:1.0 animated:NO];
                    imageScrollView.scrollEnabled = YES;
                }
                [(LLChatImageScrollView *)view layoutImageView:size];
            }
        }
    }
    
    _scrollView.contentOffset = CGPointMake(scroll_width * _curAssetView.assetIndex, 0);
    _scrollView.contentSize = CGSizeMake(_allAssets.count * scroll_width, size.height);
    
}

//参考StackOverflow：http://stackoverflow.com/questions/26069874/what-is-the-right-way-to-handle-orientation-changes-in-ios-8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self layoutAssetViews:size];
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
        if (shouldExitAfterRotation) {
            shouldExitAfterRotation = NO;
            
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
}


#pragma mark - 处理左右滑动 -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView)return;
    
    if (_allAssets.count == 1)return;
    
    //以照片是否越过屏幕中间分割线为依据，滑动距离越过了中间分割线，就表示显示的照片更换了
    //不等到照片完全划出屏幕
    CGPoint point = [self.view convertPoint:screenCenter toView:self.scrollView];
    UIView<LLAssetDisplayView> *assetView;
    for (UIView<LLAssetDisplayView> *view in self.scrollView.subviews) {
        if (!view.hidden && CGRectContainsPoint(view.frame, point)) {
            assetView = view;
            break;
        }
    }
    
    //当前图没有变
    if (!assetView || assetView == self.curAssetView)
        return;
    
    [self changeAssetViewToInitialState:_curAssetView];
     _curAssetView = assetView;
    NSInteger assetIndex = assetView.assetIndex;
    _curShowMessageModel = self.allAssets[assetIndex];
    [self showBottomBar];
    
    if (_allAssets.count <= 3)
        return;

    //移动前后照片
    if (assetIndex + 1 < _allAssets.count && ![self assetViewWithAssetIndex:assetIndex + 1]) {
        [self hideAssetViewWithAssetIndex:assetIndex - 2];
        [self showAssetViewWithAssetIndex:assetIndex + 1];
    }else if (assetIndex - 1 >= 0 && ![self assetViewWithAssetIndex:assetIndex - 1]) {
        [self hideAssetViewWithAssetIndex:assetIndex + 2];
        [self showAssetViewWithAssetIndex:assetIndex - 1];
    }
    
}

- (void)changeAssetViewToInitialState:(UIView<LLAssetDisplayView> *)view {
    if (view.messageBodyType == kLLMessageBodyTypeImage) {
        LLChatImageScrollView *curImageScrollView = (LLChatImageScrollView *)self.curAssetView;
        if (curImageScrollView.zoomScale >= 1 + FLT_EPSILON) {
            curImageScrollView.scrollEnabled = NO;
            [curImageScrollView setZoomScale:1.0 animated:NO];
            curImageScrollView.scrollEnabled = YES;
        }
    }else if (view.messageBodyType == kLLMessageBodyTypeVideo) {
        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)view;
        videoDisplayView.videoPlaybackStatus = kLLVideoPlaybackStatusPicture;
        if (self.videoPlaybackController.isPlaying) {
            [self.videoPlaybackController willStop];
            needAutoStopVideo = YES;
        }
    }
}


- (LLAssetView *)assetViewWithAssetIndex:(NSInteger)assetIndex {
    for (UIView<LLAssetDisplayView> *view in _allAssetViews) {
        if (!view.hidden && view.assetIndex == assetIndex) {
            return view;
        }
    }
    
    return nil;
}

- (LLAssetView *)assetViewWithMessageModel:(LLMessageModel *)messageModel {
    for (UIView<LLAssetDisplayView> *view in _allAssetViews) {
        if ([view.messageModel.messageId isEqualToString:messageModel.messageId]) {
            return view;
        }
    }
    
    return nil;
}

- (LLAssetView *)hideAssetViewWithAssetIndex:(NSInteger)assetIndex {
    for (LLAssetView *view in _allAssetViews) {
        if (view.assetIndex == assetIndex) {
            view.hidden = YES;
            return view;
        }
    }
    
    return nil;
}

- (LLAssetView *)showAssetViewWithAssetIndex:(NSInteger)assetIndex {

    for (LLAssetView *view in _allAssetViews) {
        if (view.assetIndex == assetIndex) {
            if (view.messageBodyType == kLLMessageBodyTypeVideo) {
                ((LLVideoDisplayView *)view).needAnimation = YES;
                [self checkVideoDownloadStatus:(LLVideoDisplayView *)view];
            }
            view.hidden = NO;
            return view;
        }
    }
   
    LLMessageModel *model = _allAssets[assetIndex];
    LLAssetView *assetView;
    for (LLAssetView *view in _allAssetViews) {
        if (view.hidden && view.messageBodyType == model.messageBodyType) {
            assetView = view;
            assetView.hidden = NO;
            break;
        }
    }
    
    assetView.assetIndex = assetIndex;
    assetView.frame = CGRectMake(assetIndex * scroll_width, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    if (model.messageBodyType == kLLMessageBodyTypeImage) {
        LLChatImageScrollView *imageScrollView = (LLChatImageScrollView *)assetView;
        if ([downloadFailedMessageIds containsObject:model.messageId]) {
            [imageScrollView setDownloadFailImage];
        }else {
            imageScrollView.messageModel = model;
        }
    }else if (model.messageBodyType == kLLMessageBodyTypeVideo) {
        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)assetView;
        videoDisplayView.messageModel = model;
        videoDisplayView.videoPlaybackStatus = kLLVideoPlaybackStatusPicture;
        [self checkVideoDownloadStatus:videoDisplayView];
    }
    
    return assetView;
    
}

#pragma mark - 处理缩放

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[LLChatImageScrollView class]])
        return nil;
    return ((LLChatImageScrollView *)scrollView).imageView;
}

//处理双击放大、缩小
- (void)handleZoom:(UITapGestureRecognizer *)tap {
    if (![_curAssetView isKindOfClass:[LLChatImageScrollView class]]) {
        [self handleTapGesture:nil];
        return;
    }
    LLChatImageScrollView *scrollView = (LLChatImageScrollView *)_curAssetView;
    if (scrollView.isZooming)return;
    if (!scrollView.shouldZoom)return;
    CGFloat zoomScale = scrollView.zoomScale;
    
    if(zoomScale < 1.0 + FLT_EPSILON) {
        CGPoint loc = [tap locationInView: scrollView];
        CGRect rect = CGRectMake(loc.x - 0.5, loc.y - 0.5, 1, 1);
        
        [scrollView zoomToRect:rect animated:YES];
    }else {
        [scrollView setZoomScale:1 animated:YES];
    }
    
}

- (void)scrollViewDidZoom:(LLChatImageScrollView *)scrollView {
    UIImageView *zoomImageView = (UIImageView *)[self viewForZoomingInScrollView: scrollView];
    
    CGRect frame = zoomImageView.frame;
    
    //当视图不能填满整个屏幕时，让其居中显示
    frame.origin.x = (CGRectGetWidth(self.view.frame) > CGRectGetWidth(frame)) ? (CGRectGetWidth(self.view.frame) - CGRectGetWidth(frame))/2 : 0;
    frame.origin.y = (CGRectGetHeight(self.view.frame) > CGRectGetHeight(frame)) ? (CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame))/2 : 0;
    if (fabs(scrollView.zoomScale - 1.0) < FLT_EPSILON) {
        frame.size = scrollView.imageSize;
        scrollView.contentSize = frame.size;
    }
    
    zoomImageView.frame = frame;
    
}



#pragma mark - Status View -

- (UIView *)imageBottomBar {
    if (!_imageBottomBar) {
        _imageBottomBar = [[NSBundle mainBundle] loadNibNamed:@"LLImageBottomBar" owner:self options:nil][0];
        _imageBottomBar.frame = CGRectMake(0, self.view.bounds.size.height - BOTTOM_BAR_HEIGHT, self.view.bounds.size.width, BOTTOM_BAR_HEIGHT);
        [self.view addSubview:_imageBottomBar];
        _imageBottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _imageBottomBar;
}


- (UIView *)videoBottomBar {
    if (!_videoBottomBar) {
        _videoPlaybackController = [[LLVideoPlaybackController alloc] initWithNibName:@"LLVideoPlaybackController" bundle:nil];
        [self addChildViewController:_videoPlaybackController];
        _videoPlaybackController.delegate = self;
        _videoBottomBar = _videoPlaybackController.view;
        _videoBottomBar.frame =CGRectMake(0, self.view.bounds.size.height - BOTTOM_BAR_HEIGHT, self.view.bounds.size.width, BOTTOM_BAR_HEIGHT);
        [self.view addSubview:_videoBottomBar];
        _videoBottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _videoBottomBar;
}

- (LLImageAnimationView *)imageAnimationView {
    if (!_imageAnimationView) {
        _imageAnimationView = [[LLImageAnimationView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _imageAnimationView.center = self.view.center;
        _imageAnimationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return _imageAnimationView;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView)
        return;
    [timer invalidate];
    if (_imageBottomBar) {
        [UIView animateWithDuration:DEFAULT_DURATION animations:^{
            _imageBottomBar.downloadButton.alpha = 0;
        }];
    }
}

- (void)showBottomBar {
    _videoBottomBar.hidden = YES;
    _imageBottomBar.hidden = YES;
    
    if ([_curAssetView isKindOfClass:[LLChatImageScrollView class]]) {
        self.imageBottomBar.hidden = NO;
        
    }else if([_curAssetView isKindOfClass:[LLVideoDisplayView class]]){
        self.videoBottomBar.hidden = NO;

        if (_curShowMessageModel.isVideoPlayable) {
            [_videoPlaybackController initVideoBottomBarWithDuration:_curShowMessageModel.mediaDuration];

            if (bottomBarStyle == kLLAssetBottomBarStyleImageHide) {
                [_videoPlaybackController setBackgroundViewVisible:NO];
                [_videoPlaybackController showControlView:NO];
            }else if (bottomBarStyle == kLLAssetBottomBarStyleImageShow) {
                [_videoPlaybackController setBackgroundViewVisible:NO];
                [_videoPlaybackController hideControlView:NO];
            }else {
                [_videoPlaybackController setBackgroundViewVisible:YES];
                [_videoPlaybackController showControlView:NO];
            }
        }else {
            if (bottomBarStyle == kLLAssetBottomBarStyleImageHide) {
                [_videoPlaybackController setBackgroundViewVisible:NO];
            }else if (bottomBarStyle == kLLAssetBottomBarStyleImageShow) {
                [_videoPlaybackController setBackgroundViewVisible:NO];
            }else {
                [_videoPlaybackController setBackgroundViewVisible:YES];
            }
            
            [_videoPlaybackController hideControlView:NO];
        }

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) return;
    
    [self checkDownloadStatus];
    
}

- (void)hideImageBottomBar:(NSTimer *)timer {
    bottomBarStyle = kLLAssetBottomBarStyleImageHide;
    
    [_imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleHide animated:YES];
}

- (void)checkDownloadStatus {
    BOOL needShowAnimationView = NO;
    
    if (needAutoStopVideo) {
        needAutoStopVideo = NO;
        [self.videoPlaybackController stop];
    }
    
    if (_curAssetView.messageBodyType == kLLMessageBodyTypeImage) {
        switch (_curShowMessageModel.messageDownloadStatus) {
            case kLLMessageDownloadStatusWaiting:
            case kLLMessageDownloadStatusDownloading: {
                //用户点击了查看原图
                if ([downloadingMessageIds containsObject:_curShowMessageModel.messageId]) {
                    bottomBarStyle = kLLAssetBottomBarStyleImageHide;
                    [self.imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleDownloading animated:YES];
                    [self.imageBottomBar setDownloadProgress:_curShowMessageModel.fileDownloadProgress];
                    
                }else {
                    needShowAnimationView = YES;
                }
                
            }
                break;
            case kLLMessageDownloadStatusFailed:
                if ([downloadFailedMessageIds containsObject:_curShowMessageModel.messageId]) {

                    bottomBarStyle = kLLAssetBottomBarStyleImageHide;
                    [self.imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleHide animated:YES];

                }else {
                    bottomBarStyle = kLLAssetBottomBarStyleImageShow;
                    [self.imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleDownloadFullImage animated:YES];
                    [self.imageBottomBar setDownloadFullImageSize:[LLUtils sizeStringWithStyle:nil size:[_curShowMessageModel fileAttachmentSize]]];
            }
                break;
            case kLLMessageDownloadStatusPending:
                [[LLChatManager sharedManager] asynDownloadMessageAttachments:_curShowMessageModel progress:nil completion:nil];
                needShowAnimationView = YES;
                break;
            case kLLMessageDownloadStatusSuccessed: {
                bottomBarStyle = kLLAssetBottomBarStyleImageShow;
                [self.imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleMore animated:YES];
                [timer invalidate];
                timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(hideImageBottomBar:) userInfo:nil repeats:NO];
            }
                break;
            default:
                break;
        }
        
    }else if (_curAssetView.messageBodyType == kLLMessageBodyTypeVideo) {
        needShowAnimationView = NO;
        bottomBarStyle = kLLAssetBottomBarStyleVideo;
        
        //视频存在,可以播放
        if (_curShowMessageModel.isVideoPlayable) {
            LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)_curAssetView;
            
            if (![_curShowMessageModel.fileLocalPath isEqualToString:_videoPlaybackController.videoURL.path]) {
                NSURL *videoURL = [NSURL fileURLWithPath:_curShowMessageModel.fileLocalPath];
                self.videoPlaybackController.playbackView = videoDisplayView.videoPlaybackView;
                self.videoPlaybackController.videoURL = videoURL;
            }
            
            [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                [_videoPlaybackController setBackgroundViewVisible:YES];
                if (_videoPlaybackController.isControlViewHidden) {
                    [_videoPlaybackController showControlView:NO];
                }
            }];
 
        }else {
            [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                [_videoPlaybackController setBackgroundViewVisible:YES];
                if (!_videoPlaybackController.isControlViewHidden) {
                    [_videoPlaybackController hideControlView:NO];
                }
            }];
            
            LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)_curAssetView;
            switch (_curShowMessageModel.messageDownloadStatus) {
                case kLLMessageDownloadStatusWaiting:
                    [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleWaiting];
                    break;
                case kLLMessageDownloadStatusDownloading:
                    [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleDownloading];
                    [videoDisplayView setDownloadProgress:_curShowMessageModel.fileDownloadProgress];
                    break;
                default:
                    break;
            }

        }
        
    }
    
    if (needShowAnimationView) {
        self.imageAnimationView.alpha = 0;
        [self.view addSubview:self.imageAnimationView];
        [UIView animateWithDuration:DEFAULT_DURATION animations:^{
            self.imageAnimationView.alpha = 1;
        }];
        bottomBarStyle = kLLAssetBottomBarStyleImageHide;
        [self.imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleHide animated:YES];
    }else if (_imageAnimationView.superview) {
        [UIView animateWithDuration:DEFAULT_DURATION animations:^{
            self.imageAnimationView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.imageAnimationView removeFromSuperview];
        }];
    }
}

- (void)checkVideoDownloadStatus:(LLVideoDisplayView *)videoDisplayView {
    switch (videoDisplayView.messageModel.messageDownloadStatus) {
        case kLLMessageDownloadStatusPending:
            [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStylePending];
            break;
        case kLLMessageDownloadStatusSuccessed:
            [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleDownloadSuccess];
            break;
        case kLLMessageDownloadStatusFailed: {
            if ([downloadFailedMessageIds containsObject:videoDisplayView.messageModel.messageId]) {
                [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleFailed];
            }else {
                [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStylePending];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 视频播放 -

- (void)playerReadyToPlay:(NSURL *)videoURL {
    //当前视频可以播放
    if (needAutoPlayVideo && [_curShowMessageModel.fileLocalPath isEqualToString:videoURL.path]) {
        needAutoPlayVideo = NO;
        [_videoPlaybackController play];
    }
}

- (void)playerPrepareToPlayFailed:(NSURL *)videoURL {
    
}

- (void)playerDidPlayToEnd:(NSURL *)videoURL {
    
}

- (void)playerCurrentItemDidChangedTo:(NSURL *)videoURL {

}

- (void)playerScrubberWillChange:(NSURL *)videoURL {
    if ([_curShowMessageModel.fileLocalPath isEqualToString:videoURL.path]) {
        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)_curAssetView;
        videoDisplayView.videoPlaybackStatus = kLLVideoPlaybackStatusVideo;
    }
}

- (void)playerRateDidChanged:(NSURL *)videoURL currentRate:(float)rate {
    if (rate != 0.f) {
        //FIXME:VideoLayer在初次获取到AVPlayer之后，可能前几帧尚未有图像，会导致黑屏
        //此处延迟1/10秒。出现黑屏也可能是自己使用方式不当
        WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([weakSelf.curShowMessageModel.fileLocalPath isEqualToString:videoURL.path]) {
                LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)weakSelf.curAssetView;
                videoDisplayView.videoPlaybackStatus = kLLVideoPlaybackStatusVideo;
            }
        });
    }
}

#pragma mark - 照片、视频下载

- (void)registerChatManagerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDownloadHandler:) name:LLMessageDownloadStatusChangedNotification object:nil];
}

- (void)downloadAttachmentForMessageModel:(LLMessageModel *)messageModel {
    [[LLChatManager sharedManager] asynDownloadMessageAttachments:messageModel progress:nil completion:nil];
    
    [downloadingMessageIds addObject:messageModel.messageId];
}

- (void)imageDownloadNotification:(LLMessageModel *)messageModel {
    WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF;
        if (messageModel.messageDownloadStatus == kLLMessageDownloadStatusSuccessed) {
            [strongSelf->downloadingMessageIds removeObject:messageModel.messageId];
            LLAssetView *imageView = [weakSelf assetViewWithMessageModel:messageModel];
            [imageView setMessageModel:messageModel];
        }else if (messageModel.messageDownloadStatus == kLLMessageDownloadStatusFailed) {
            [strongSelf->downloadingMessageIds removeObject:messageModel.messageId];
            [strongSelf->downloadFailedMessageIds addObject:messageModel.messageId];
            LLAssetView *imageView = [weakSelf assetViewWithMessageModel:messageModel];
            [(LLChatImageScrollView *)imageView setDownloadFailImage];
        }
        
        if (![weakSelf.curShowMessageModel.messageId isEqualToString:messageModel.messageId])
            return;
        
        switch (messageModel.messageDownloadStatus) {
            case kLLMessageDownloadStatusDownloading:
            case kLLMessageDownloadStatusWaiting:
                [weakSelf.imageBottomBar setDownloadProgress:messageModel.fileDownloadProgress];
                break;
                
            case kLLMessageDownloadStatusSuccessed:
                [weakSelf.imageBottomBar setDownloadProgress:100];
                [weakSelf checkDownloadStatus];
                break;
            case kLLMessageDownloadStatusFailed:
                [weakSelf checkDownloadStatus];
                break;
            default:
                break;
        }
    });
}

- (void)videoDownloadNotification:(LLMessageModel *)messageModel {
    WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF;
        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)[weakSelf assetViewWithMessageModel:messageModel];
        
        if (messageModel.messageDownloadStatus == kLLMessageDownloadStatusSuccessed) {
            [strongSelf->downloadingMessageIds removeObject:messageModel.messageId];
            [weakSelf checkVideoDownloadStatus:videoDisplayView];
        }else if (messageModel.messageDownloadStatus == kLLMessageDownloadStatusFailed) {
            [strongSelf->downloadingMessageIds removeObject:messageModel.messageId];
            [strongSelf->downloadFailedMessageIds addObject:messageModel.messageId];
            [weakSelf checkVideoDownloadStatus:videoDisplayView];
        }
        
        if (![weakSelf.curShowMessageModel.messageId isEqualToString:messageModel.messageId])
            return;
    
        switch (messageModel.messageDownloadStatus) {
            case kLLMessageDownloadStatusWaiting:
                [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleWaiting];
                break;
            case kLLMessageDownloadStatusDownloading:
                [videoDisplayView setVideoDownloadStyle:kLLVideoDownloadStyleDownloading];
                [videoDisplayView setDownloadProgress:messageModel.fileDownloadProgress];
                break;
            case kLLMessageDownloadStatusSuccessed:
                strongSelf->needAutoPlayVideo = YES;
                [weakSelf showBottomBar];
                [weakSelf checkDownloadStatus];
            default:
                break;
        }
    });
}

- (void)messageDownloadHandler:(NSNotification *)notification {
    LLMessageModel *messageModel = notification.userInfo[LLChatManagerMessageModelKey];
    if (!messageModel)
        return;
    
    if (messageModel.messageBodyType == kLLMessageBodyTypeVideo) {
        [self videoDownloadNotification:messageModel];
    }else if (messageModel.messageBodyType == kLLMessageBodyTypeImage) {
        [self imageDownloadNotification:messageModel];
    }
   
}


- (IBAction)imagedownload:(UIButton *)button {
    if ([button.titleLabel.text rangeOfString:@"查看原图"].location != NSNotFound) {
        if (![downloadingMessageIds containsObject:_curShowMessageModel.messageId]) {
            [self downloadAttachmentForMessageModel:_curShowMessageModel];
        }
        
        bottomBarStyle = kLLAssetBottomBarStyleImageHide;
        [_imageBottomBar setBottomBarStyle:kLLImageBottomBarStyleDownloading animated:YES];
        [_imageBottomBar setDownloadProgress:_curShowMessageModel.fileDownloadProgress];
    }else {
        NSLog(@"SDK 不支持取消下载");
    }

}

- (void)videodownload {
    if (![downloadingMessageIds containsObject:_curShowMessageModel.messageId]) {
        [self downloadAttachmentForMessageModel:_curShowMessageModel];
    }
}

- (void)HUDDidTapped:(LLVideoDownloadStatusHUD *)HUD {
    if ((_curShowMessageModel.messageBodyType == kLLMessageBodyTypeVideo) &&
        ((_curShowMessageModel.messageDownloadStatus == kLLMessageDownloadStatusPending) || (_curShowMessageModel.messageDownloadStatus == kLLMessageDownloadStatusFailed))) {
        [self videodownload];
    }
}


#pragma mark - 处理照片、视频动作菜单 -
- (void)handleAction:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_curShowMessageModel.messageBodyType == kLLMessageBodyTypeImage) {
            [self showImageActionSheet:_curShowMessageModel];
        }else if (_curShowMessageModel.messageBodyType == kLLMessageBodyTypeVideo) {
            [self showVideoActionSheet:_curShowMessageModel];
        }
    }
}

- (void)showImageActionSheet:(LLMessageModel *)model {
    LLActionSheet *aActionSheet = [[LLActionSheet alloc] initWithTitle:nil];
    actionSheet = aActionSheet;
    
    LLActionSheetAction *action1 = [LLActionSheetAction
                actionWithTitle:@"发送给朋友"
                        handler:^(LLActionSheetAction *action) {
                            
                                }];
    
    LLActionSheetAction *action2 = [LLActionSheetAction
                actionWithTitle:@"收藏"
                        handler:^(LLActionSheetAction *action) {
                            
                                 }];
    
    LLActionSheetAction *action3 = [LLActionSheetAction
                actionWithTitle:@"保存图片"
                        handler:^(LLActionSheetAction *action) {
               [LLUtils saveImageToPhotoAlbum:model.fullImage];
                                 }] ;
    
    LLActionSheetAction *action4 = [LLActionSheetAction
                actionWithTitle:@"定位到聊天位置"
                        handler:^(LLActionSheetAction *action) {
                                 scrollToTop = YES;
                                 [self exit];
                               }] ;
    
    if (model.isFullImageAvailable) {
        [actionSheet addActions:@[action1, action2, action3, action4]];
    }else {
        [actionSheet addAction:action4];
    }
    
    [actionSheet showInWindow:self.view.window];
}

- (void)showVideoActionSheet:(LLMessageModel *)model {
    LLActionSheet *aActionSheet = [[LLActionSheet alloc] initWithTitle:nil];
    actionSheet = aActionSheet;
    
    LLActionSheetAction *action1 = [LLActionSheetAction
                        actionWithTitle:@"发送给朋友"
                        handler:^(LLActionSheetAction *action) {
                            
                        }];
    
    LLActionSheetAction *action2 = [LLActionSheetAction
                        actionWithTitle:@"收藏"
                        handler:^(LLActionSheetAction *action) {
                            
                        }];
    
    LLActionSheetAction *action3 = [LLActionSheetAction
                        actionWithTitle:@"保存视频"
                        handler:^(LLActionSheetAction *action) {
                            [LLUtils saveVideoToPhotoAlbum:model.fileLocalPath];
                        }] ;
    
    LLActionSheetAction *action4 = [LLActionSheetAction
                        actionWithTitle:@"定位到聊天位置"
                        handler:^(LLActionSheetAction *action) {
                            scrollToTop = YES;
                            [self exit];
                        }] ;
    
    if (model.isVideoPlayable) {
        [actionSheet addActions:@[action1, action2, action3, action4]];
    }else {
        [actionSheet addAction:action4];
    }
    
    [actionSheet showInWindow:self.view.window];
}


#pragma mark - Exit -

- (void)exit {
    [timer invalidate];
    [self changeAssetViewToInitialState:_curAssetView];

    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        //参考stackOverflow:http://stackoverflow.com/questions/20987249/how-do-i-programmatically-set-device-orientation-in-ios7
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        shouldExitAfterRotation = YES;
    }else {
       [self.navigationController popViewControllerAnimated:NO];
    }
    
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    scrollToTop = NO;
    [self exit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _imageBottomBar.hidden = YES;
    _videoBottomBar.hidden = YES;
//    if (_curAssetView.messageBodyType == kLLMessageBodyTypeVideo) {
//        LLVideoDisplayView *videoDisplayView = (LLVideoDisplayView *)_curAssetView;
//        videoDisplayView.videoPlaybackView.player = nil;
//    }
    
    [self.delegate didFinishWithMessageModel:_curShowMessageModel
                                      targetView:_curAssetView
                                     scrollToTop:scrollToTop];

}


#pragma mark - 跳转到更多图片 - 

- (IBAction)moreButtonPressed:(id)sender {
    
}

@end
