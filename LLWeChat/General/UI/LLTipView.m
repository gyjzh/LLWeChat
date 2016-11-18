//
//  LLTipView.m
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLTipView.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"


@interface LLTipView ()

@property (nonatomic) NSMutableSet<UIView<LLTipDelegate> *> *allTipViews;

@end

@implementation LLTipView

+ (instancetype)sharedInstance {
    static LLTipView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLTipView alloc] initWithFrame:SCREEN_FRAME];
    });
    
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _allTipViews = [NSMutableSet set];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    NSSet<UIView<LLTipDelegate> *> *tipViews = [self.allTipViews copy];
    for (UIView<LLTipDelegate> *tipView in tipViews) {
        SAFE_SEND_MESSAGE(tipView, canCancelByTouch) {
            BOOL canCancel = [tipView canCancelByTouch];
            
            if (canCancel) {
                [self removeTipView:tipView];
            }
        }
    }
    
}

- (void)removeTipView:(UIView<LLTipDelegate> *)tipView {
    [_allTipViews removeObject:tipView];
    
    SAFE_SEND_MESSAGE(tipView, willRemoveFromTipLayer) {
        [tipView willRemoveFromTipLayer];
    }
    
    [tipView removeFromSuperview];
    
    SAFE_SEND_MESSAGE(tipView, didRemoveFromTipLayer) {
        [tipView didRemoveFromTipLayer];
    }
    
    if (_allTipViews.count == 0)
        [self removeFromSuperview];
    
}


+ (void)showTipView:(nonnull UIView<LLTipDelegate> *)view {
    LLTipView *containerView = [LLTipView sharedInstance];
    if (!containerView.superview) {
        [[LLUtils currentWindow] addSubview:containerView];
    }
    [containerView.superview bringSubviewToFront:containerView];
    
    [containerView.allTipViews addObject:view];

    [containerView addSubview:view];
    SAFE_SEND_MESSAGE(view, didMoveToTipLayer) {
        [view didMoveToTipLayer];
    }
    
    view.center = containerView.center;
    SAFE_SEND_MESSAGE(view, tipViewCenterPositionOffset) {
        UIOffset offset = [view tipViewCenterPositionOffset];
        view.center = CGPointMake(view.center.x + offset.horizontal, view.center.y + offset.vertical);
    }

}

+ (void)hideTipView:(nonnull UIView<LLTipDelegate> *)tipView {
    LLTipView *containerView = [LLTipView sharedInstance];
    [containerView removeTipView:tipView];
}


@end
