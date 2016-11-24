//
//  LLImageScrollView.m
//  LLPickImageDemo
//
//  Created by GYJZH on 7/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageScrollView.h"
#import "LLUtils.h"

@interface LLImageScrollView ()

@property (nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation LLImageScrollView

- (instancetype)init {
    self = [super initWithFrame:SCREEN_FRAME];
    self.backgroundColor = [UIColor clearColor];
    self.pagingEnabled = NO;
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
    self.bounces = YES;
    self.bouncesZoom = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
   
    _imageView = [[UIImageView alloc] initWithFrame:SCREEN_FRAME];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];

    _assetIndex = -1;

    return self;
}


- (void)setContentWithImage:(UIImage *)image {
    if (!image) {
        _isImageExist = NO;
        [self showLoadingIndicator];
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 1;
        return;
    }
    
    _isImageExist = YES;
    
    _imageSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/image.size.width * image.size.height);
    CGFloat _y = (SCREEN_HEIGHT > _imageSize.height) ? (SCREEN_HEIGHT - _imageSize.height)/2 : 0;
    _imageView.frame = CGRectMake(0, _y, SCREEN_WIDTH, _imageSize.height);
   
    _imageView.image = image;
    
    self.contentSize = _imageSize;
    
    //设置缩放范围
    self.minimumZoomScale = MinimumZoomScale;
    CGFloat vScale = SCREEN_HEIGHT / _imageSize.height;
    self.maximumZoomScale = MAX(vScale, MaximumZoomScale);

    [self hideLoadingIndicator];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }
    
    return _indicatorView;
}

- (void)showLoadingIndicator {
    self.imageView.hidden = YES;

    [self addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}


- (void)hideLoadingIndicator {
    self.imageView.hidden = NO;

    [_indicatorView stopAnimating];
    [_indicatorView removeFromSuperview];
}


@end
