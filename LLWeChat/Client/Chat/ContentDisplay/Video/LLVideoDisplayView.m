//
//  LLVideoDisplayView.m
//  LLWeChat
//
//  Created by GYJZH on 9/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVideoDisplayView.h"
#import "LLVideoDownloadStatusHUD.h"
#import "LLUtils.h"

@interface LLVideoDisplayView ()

@property (nonatomic) LLVideoDownloadStatusHUD *HUD;

@end

@implementation LLVideoDisplayView

@synthesize imageView = _imageView;
@synthesize messageModel = _messageModel;
@synthesize messageBodyType = _messageBodyType;
@synthesize assetIndex = _assetIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _videoDownloadStyle = kLLVideoDownloadStyleNone;
        _messageBodyType = kLLMessageBodyTypeVideo;
        _assetIndex = -1;

        self.backgroundColor = [UIColor blackColor];

        self.videoPlaybackView = [[LLVideoPlaybackView alloc] initWithFrame:self.bounds];
        [self addSubview:self.videoPlaybackView];
        _videoPlaybackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        /* Specifies that the player should preserve the video’s aspect ratio and
         fit the video within the layer’s bounds. */
        [self.videoPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        _imageView.hidden = YES;
    }
    
    return self;
}


- (LLVideoDownloadStatusHUD *)HUD {
    if (!_HUD) {
        _HUD = [[LLVideoDownloadStatusHUD alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        _HUD.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _HUD.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _HUD.backgroundColor = [UIColor clearColor];
        
        [_HUD setText:@"轻触载入" forStatus:kLLVideoDownloadHUDStatusPending];
        [_HUD setText:@"下载失败" forStatus:kLLVideoDownloadHUDStatusFailed];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        [_HUD addGestureRecognizer:tapGR];
    }
    
    return _HUD;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self.chatAssetDisplayController HUDDidTapped:_HUD];
}

- (void)setMessageModel:(LLMessageModel *)messageModel {
    _messageModel = messageModel;
    _needAnimation = YES;
    self.imageView.image = messageModel.thumbnailImage;
    
    self.videoDownloadStyle = kLLVideoDownloadStyleNone;
}

- (void)setVideoPlaybackStatus:(LLVideoPlaybackStatus)videoPlaybackStatus {
    _videoPlaybackStatus = videoPlaybackStatus;
    switch (_videoPlaybackStatus) {
        case kLLVideoPlaybackStatusPicture:
            _imageView.hidden = NO;
            break;
        case kLLVideoPlaybackStatusVideo:
            _imageView.hidden = YES; 
            break;
        default:
            break;
    }
}

- (void)setVideoDownloadStyle:(LLVideoDownloadStyle)style {
    if (_videoDownloadStyle == style)
        return;
    _videoDownloadStyle = style;

    switch (style) {
        case kLLVideoDownloadStylePending:
            if (!self.HUD.superview) {
                [self addSubview:self.HUD];
            }
            self.HUD.status = kLLVideoDownloadHUDStatusPending;
            break;
        case kLLVideoDownloadStyleWaiting:
            if (!self.HUD.superview) {
                [self addSubview:self.HUD];
                [_HUD playZoomAnimation];
            }
            self.HUD.status = kLLVideoDownloadHUDStatusWaiting;
            break;
        case kLLVideoDownloadStyleDownloading: {
            NSInteger progress = self.messageModel.fileDownloadProgress;
            BOOL needAnimation = NO;
            if (!self.HUD.superview) {
                needAnimation = YES;
                [self addSubview:self.HUD];
            }
            
            if (progress == 0) {
                _videoDownloadStyle = kLLVideoDownloadStyleWaiting;
                self.HUD.status = kLLVideoDownloadHUDStatusWaiting;
            }else if (progress >= 100) {
                _videoDownloadStyle = kLLVideoDownloadStyleDownloadSuccess;
                self.HUD.status = kLLVideoDownloadHUDStatusSuccess;
                [_HUD removeFromSuperview];
            }else {
                _HUD.status = kLLVideoDownloadHUDStatusDownloading;
                if (needAnimation) {
                    [_HUD playQuickProgressAnimationTo:progress];
                }else {
                    _HUD.progress = progress;
                }
            }
        }
            break;
        case kLLVideoDownloadStyleDownloadSuccess:
            [_HUD removeFromSuperview];
            break;
        case kLLVideoDownloadStyleFailed:
            if (!self.HUD.superview) {
                [self addSubview:self.HUD];
            }
            _HUD.status = kLLVideoDownloadHUDStatusFailed;
            break;
        case kLLVideoDownloadStyleNone:
            [_HUD removeFromSuperview];
            break;
    }
    
    _needAnimation = NO;
}

- (void)setDownloadProgress:(NSInteger)progress {
    self.HUD.progress = progress;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        if (_videoDownloadStyle == kLLVideoDownloadStyleWaiting ||
            _videoDownloadStyle == kLLVideoDownloadStyleDownloading) {
            self.videoDownloadStyle = kLLVideoDownloadStyleNone;
        }
    }
}


//FIXME: 虽然设置了autoresizingMask，可是在偶然的情况下，屏幕旋转时_HUD位置跑偏
//
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _HUD.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _imageView.frame = self.bounds;
}


@end
