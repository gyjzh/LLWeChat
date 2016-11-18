//
//  LLAssetImageCell.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLAssetImageCell.h"
#import "LLAssetManager.h"

@interface LLAssetImageCell ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *checkView;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selectAction;
@property (nonatomic) SEL showAction;

@end

@implementation LLAssetImageCell {
    CGRect checkFrame;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        self.checkView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-27, 0, 27, 27)];
        self.checkView.image = [UIImage imageNamed:@"FriendsSendsPicturesSelectIcon"];
        self.checkView.contentMode = UIViewContentModeTopRight;
        [self.contentView addSubview:self.checkView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        
        [self addGestureRecognizer:tapGesture];
        
        checkFrame = CGRectMake(CGRectGetWidth(self.frame)/2, 0, CGRectGetWidth(self.frame)/2, CGRectGetWidth(self.frame)/2);
        
    }
    
    return self;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self];

    if (CGRectContainsPoint(checkFrame, point)) {
        IMP _imp = [self.target methodForSelector:self.selectAction];
        BOOL (*func)(id, SEL, id) = (void *)_imp;
        BOOL result = func(self.target, self.selectAction, self);
        
        if (!result)return;
        
        self.cellSelected = !self.cellSelected;
 
        if (self.cellSelected) {
            NSTimeInterval duration = 0.6;
            
            [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
                int num = 3;
                for (int i = 0; i < num; i++) {
                    [UIView addKeyframeWithRelativeStartTime:i * duration / num
                                            relativeDuration:duration / num
                                                  animations:^{
                        CGFloat zoomFactors[] = {0.8, 1.2, 1};
                        self.checkView.transform = CGAffineTransformMakeScale(zoomFactors[i], zoomFactors[i]);
                    }];
                }  
            } completion:^(BOOL finished) {
                
            }];
        }
    }else {
        IMP _imp = [self.target methodForSelector:self.showAction];
        void (*func)(id, SEL, id) = (void *)_imp;
        func(self.target, self.showAction, self);
    }
}

- (void)addTarget:(id)target selectAction:(SEL)selectAction showAction:(SEL)showAction {
    self.target = target;
    self.selectAction = selectAction;
    self.showAction = showAction;
}

- (void)setAssetModel:(LLAssetModel *)assetModel {
    _assetModel = assetModel;
    
    __weak typeof(self) weakSelf = self;
    [assetModel fetchThumbnailWithPointSize:self.frame.size completion:^(UIImage * _Nullable image, LLAssetModel *assetModel) {
        if (assetModel == weakSelf.assetModel) {
            weakSelf.imageView.image = image;
        }
    }];
}

- (void)setCellSelected:(BOOL)cellSelected{
    _cellSelected = cellSelected;
    self.checkView.image = [UIImage imageNamed:self.isCellSelected ? @"FriendsSendsPicturesSelectYIcon" : @"FriendsSendsPicturesSelectIcon"];
}


@end
