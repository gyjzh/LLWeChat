//
//  LLImageSelectIndicator.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageSelectIndicator.h"

@interface LLImageSelectIndicator ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

@end

@implementation LLImageSelectIndicator {
    UIImage *bigNIcon;
}

- (instancetype)init {
    bigNIcon = [UIImage imageNamed:@"FriendsSendsPicturesSelectBigNIcon"];
    bigNIcon = [bigNIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self = [super initWithFrame:CGRectMake(0, 0, bigNIcon.size.width, 60)];
    self.contentMode = UIViewContentModeCenter;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bigNIcon.size.width, bigNIcon.size.height)];
    [self addSubview:_imageView];
    self.imageView.image = bigNIcon;
    _selected = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchHandler:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tapGesture];
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.imageView.image = _selected? [UIImage imageNamed:@"FriendsSendsPicturesSelectBigYIcon"]: bigNIcon;
}

- (void)touchHandler:(UITapGestureRecognizer *)sender {
    IMP _imp = [self.target methodForSelector:self.action];
    BOOL (*func)(id, SEL, BOOL) = (void*)_imp;
    BOOL result = func(self.target, self.action, _selected);
    
    if (!result)return;
    
    if (_selected) {
        self.selected = NO;
    }else {
        self.selected = YES;
        [self doAnimation];
    }
}

- (void)doAnimation {
    NSTimeInterval duration = 0.6;
    
    [UIView animateKeyframesWithDuration:duration
                delay:0
              options:UIViewKeyframeAnimationOptionCalculationModeCubic
           animations:^{
                int num = 3;
                for (int i = 0; i < num; i++) {
                    [UIView addKeyframeWithRelativeStartTime:i * duration / num
                                            relativeDuration:duration / num
                                                  animations:^{
                        CGFloat zoomFactors[] = {0.8, 1.2, 1};
                        self.imageView.transform = CGAffineTransformMakeScale(zoomFactors[i], zoomFactors[i]);
                    }];
                }
            }
         completion:^(BOOL finished) {
        
    }];

}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

@end
