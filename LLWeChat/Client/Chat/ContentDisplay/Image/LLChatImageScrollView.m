//
//  LLChatImageScrollView.m
//  LLWeChat
//
//  Created by GYJZH on 8/16/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatImageScrollView.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "LLSDK.h"
#import "UIKit+LLExt.h"
#import "LLChatAssetDisplayController.h"

@interface LLChatImageScrollView ()

@property (nonatomic) UIView *downloadFailedView;

@end

@implementation LLChatImageScrollView

@synthesize imageView = _imageView;
@synthesize messageModel = _messageModel;
@synthesize messageBodyType = _messageBodyType;
@synthesize assetIndex = _assetIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    self.pagingEnabled = NO;
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
    self.bounces = YES;
    self.bouncesZoom = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    _messageBodyType = kLLMessageBodyTypeImage;
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    _assetIndex = -1;
    
//    [self addLongPressGestureRecognizer:@selector(longPressHandler:) duration:0.8];
    
    return self;
}

- (void)setMessageModel:(LLMessageModel *)messageModel {
    _messageModel = messageModel;
    [_downloadFailedView removeFromSuperview];

    UIImage *fullImage = _messageModel.fullImage;
    if (fullImage) {
        _imageView.image = fullImage;
    }else {
        _imageView.image = _messageModel.thumbnailImage;
    }
    
    [self layoutImageView:self.bounds.size];
    
}


- (UIView *)downloadFailedView {
    if (!_downloadFailedView) {
        _downloadFailedView = [[NSBundle mainBundle] loadNibNamed:@"LLImageDownloadFailView" owner:nil options:nil][0];
    }
    
    return _downloadFailedView;
}

- (void)setDownloadFailImage {
    if (fabs(self.zoomScale - 1) >= FLT_EPSILON) {
        [self setZoomScale:1 animated:NO];
    }
    
    self.downloadFailedView.frame = self.bounds;
    [self addSubview:self.downloadFailedView];
}

- (BOOL)shouldZoom {
    return _downloadFailedView.superview == nil;
}

- (void)layoutImageView:(CGSize)size {
    self.downloadFailedView.frame = CGRectMake(0, 0, size.width, size.height);
    _imageSize = _imageView.image.size;
    
    //竖屏状态
    if (size.width == SCREEN_WIDTH) {
        _imageSize = CGSizeMake(size.width, size.width/_imageSize.width * _imageSize.height);
        CGFloat _y = (SCREEN_HEIGHT > _imageSize.height) ? (SCREEN_HEIGHT - _imageSize.height)/2 : 0;
        _imageView.frame = CGRectMake(0, _y, SCREEN_WIDTH, _imageSize.height);
        
    }else {
        _imageSize = CGSizeMake(_imageSize.width *size.height / _imageSize.height ,size.height);
        
        //太窄了，显示为一个超细条，此处给它加宽到SCREEN_WIDTH
        if (_imageSize.width < SCREEN_WIDTH/10) {
            _imageSize = CGSizeMake(SCREEN_WIDTH ,SCREEN_WIDTH/_imageSize.width *_imageSize.height);
            CGFloat _x = (size.width - _imageSize.width) / 2;
            _imageView.frame = CGRectMake(_x, 0, _imageSize.width, _imageSize.height);
            
            //完全在这个范围内，刚刚好
        }else if (_imageSize.width <= size.width) {
            CGFloat _x = (size.width - _imageSize.width) / 2;
            _imageView.frame = CGRectMake(_x, 0, _imageSize.width, _imageSize.height);
            
            //太宽了，这是必须保证宽度合适
        }else {
            _imageSize = CGSizeMake(size.width, size.width/_imageSize.width * _imageSize.height);
            CGFloat _y = (size.height - _imageSize.height)/2;
            _imageView.frame = CGRectMake(0, _y, _imageSize.width, _imageSize.height);
        }
        
    }
    
    self.contentSize = _imageSize;
    
    //设置缩放范围
    self.minimumZoomScale = MinimumZoomScale;
    CGFloat scale1 = _imageSize.width < size.width ? (size.width / _imageSize.width) : 0;
    CGFloat scale2 = _imageSize.height < size.height ? (size.height / _imageSize.height) : 0;
    
    self.maximumZoomScale = MAX(MAX(scale1, scale2), MaximumZoomScale);
}

- (void)downloadFullImageFailed {
    
}


@end
