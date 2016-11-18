//
//  LLVideoDisPlayController.m
//  LLWeChat
//
//  Created by GYJZH on 9/18/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVideoDisPlayController.h"
#import "LLUtils.h"
#import "LLVideoPlaybackView.h"
#import "LLImagePickerController.h"
#import "LLAssetManager.h"
#import "LLConfig.h"
#import "UIKit+LLExt.h"
#import "LLImagePickerConfig.h"
@import AVFoundation;

@interface LLVideoDisPlayController ()

@property (nonatomic) LLVideoPlaybackView *playbackView;

@property (nonatomic) AVPlayer *player;
@property (nonatomic) UIButton *playButton;

@property (nonatomic) UIView *toolBar;
@property (nonatomic) UIButton *okButton;

@property (nonatomic) BOOL isVideoPlayable;

@end

@implementation LLVideoDisPlayController {
    BOOL shouldShowStatusBar;
    BOOL isPlayOver;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        shouldShowStatusBar = YES;
        isPlayOver = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频预览";
    self.view.backgroundColor = [UIColor blackColor];
    
    [LLUtils configAudioSessionForPlayback];
    [self setupViews];
    [self prepareToPlay];
}

- (void)setupViews {
    _playbackView = [[LLVideoPlaybackView alloc] initWithFrame:SCREEN_FRAME];
    _playbackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playbackView];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
    [_playButton setImage:[UIImage imageNamed:@"MMVideoPreviewPlayHL"] forState:UIControlStateDisabled];
    [_playButton addTarget:self action:@selector(tapHandler:) forControlEvents:UIControlEventTouchUpInside];
    [_playButton sizeToFit];
    _playButton.center = SCREEN_CENTER;
    _playButton.enabled = NO;
    [self.view addSubview:_playButton];
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 64)];
    _toolBar.backgroundColor = UIColorRGB(40, 45, 51);
    UIView *blackBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBar.frame), 20)];
    blackBar.backgroundColor = [UIColor blackColor];
    [_toolBar addSubview:blackBar];
    
    _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _okButton.frame = CGRectMake(CGRectGetWidth(_toolBar.frame) - 6 - 50, 20, 50, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"确定" forState:UIControlStateNormal];
    [_okButton setTitleColor:DEFAULT_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_okButton setTitleColor:DEFAULT_BUTTON_DISABLED_COLOR forState:UIControlStateDisabled];
    _okButton.enabled = NO;
    [_toolBar addSubview:_okButton];
    [self.view addSubview:_toolBar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.playbackView addGestureRecognizer:tap];
    
    //FIXME: 为什么Swipe同时设置四个方向时，只能识别水平方向手势？
    //要想识别四个方向，必须使用两个Swipe
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft |
                      UISwipeGestureRecognizerDirectionRight;
    [self.playbackView addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipeV = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipeV.direction = UISwipeGestureRecognizerDirectionUp |
                       UISwipeGestureRecognizerDirectionDown;
    [self.playbackView addGestureRecognizer:swipeV];
    
}

- (void)prepareToPlay {
    self.isVideoPlayable = NO;
    WEAK_SELF;
    [[LLAssetManager sharedAssetManager] getVideoPlayerItemForAssetModel:_assetModel completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (playerItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG_SELF;
                
                weakSelf.playButton.enabled = YES;
                weakSelf.okButton.enabled = YES;
                weakSelf.isVideoPlayable = YES;
                weakSelf.player = [AVPlayer playerWithPlayerItem:playerItem];
                [weakSelf.playbackView setPlayer:weakSelf.player];

                [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
            });
        }
    }];
}


- (BOOL)prefersStatusBarHidden {
    return !shouldShowStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - 视频 播放 -

- (void)tapHandler:(id)sender {
    [self toggleMediaPlayer];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)swipe {
    [self toggleMediaPlayer];
}

- (void)toggleMediaPlayer {
    if (self.isVideoPlayable) {
        if ([self isPlaying]) {
            [self pause];
        }else {
            if (isPlayOver) {
                isPlayOver = NO;
                [self.playbackView.player seekToTime:kCMTimeZero];
            }
            [self play];
        }
    }
    
    [self updatePlayerUI];
}


- (void)play {
    [self.playbackView.player play];
}

- (void)pause {
    [self.playbackView.player pause];
}

- (BOOL)isPlaying {
    return _isVideoPlayable && ([self.playbackView.player rate] != 0.f);
}


- (void)updatePlayerUI {
    BOOL isHidden = _playButton.hidden;

    _toolBar.hidden = !isHidden;
    _playButton.hidden = !isHidden;
    
    [self.navigationController setNavigationBarHidden:!isHidden animated:NO];
    shouldShowStatusBar = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)playComplete {
    isPlayOver = YES;
    [self updatePlayerUI];
}

#pragma mark - 视频 发送 -

- (void)okButtonClick {
    if (self.okButton.tag == 0) {
        self.okButton.tag = 10;
    }else {
        return;
    }
    
    WEAK_SELF;
    [[LLAssetManager sharedAssetManager] getVideoAssetForAssetModel:self.assetModel completion:^(AVURLAsset * _Nonnull videoAsset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //视频不存在
            if (!videoAsset.URL) {
                weakSelf.okButton.enabled = NO;
                weakSelf.okButton.tag = 0;
                return;
            }
            
            weakSelf.playButton.hidden = YES;
            
            [LLUtils compressVideoAssetForSend:videoAsset
            okCallback:^(NSString *mp4Path) {
                LLImagePickerController *imagePickerController = (LLImagePickerController *)weakSelf.navigationController;
                [imagePickerController didFinishPickingVideo:mp4Path assetGroupModel:weakSelf.assetGroupModel];
            }
            cancelCallback:^{
                weakSelf.playButton.hidden = NO;
                weakSelf.okButton.tag = 0;
            }
              failCallback:^{
                  weakSelf.playButton.hidden = NO;
                  weakSelf.okButton.tag = 0;
              }
             successCallback:^(NSString *mp4Path) {
                 weakSelf.playButton.hidden = NO;
             }];
        });
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
