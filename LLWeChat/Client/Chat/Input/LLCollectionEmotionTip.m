//
//  LLCollectionEmotionTip.m
//  LLWeChat
//
//  Created by GYJZH on 7/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLCollectionEmotionTip.h"
#import "LLColors.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"

@interface LLCollectionEmojiTip ()

@property (nonatomic) UIImageView *backgroundImageView;

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UILabel *label;

@end


@implementation LLCollectionEmojiTip

+ (instancetype)sharedTip {
    static LLCollectionEmojiTip *tip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        tip = [[LLCollectionEmojiTip alloc] initWithFrame:CGRectMake(0, 0, 64, 92)];
    });

    return tip;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_keyboard_magnifier"]];
        [self addSubview:self.backgroundImageView];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 42)/2, 4, 42, 42)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, CGRectGetWidth(self.frame), 20)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = kLLTextColor_lightGray_6;
        [self addSubview:self.label];
    }

    return self;
}


- (void)showTipOnCell:(LLCollectionEmojiCell *)cell {
    if (cell == _cell) return;
    _cell = cell;

    if (!_cell) {
        [self removeFromSuperview];
    }else {
        UIView *superView = _cell.superview.superview;
        [superView addSubview:self];

        CGPoint point = [_cell convertPoint:_cell.tipFloatPoint toView:superView];
        CGRect frame = self.frame;
        frame.origin.x = point.x - CGRectGetWidth(frame)/2;
        frame.origin.y = point.y - CGRectGetHeight(frame);
        self.frame = frame;

        self.imageView.image = [[LLEmotionModelManager sharedManager] imageForEmotionModel:_cell.emotionModel];
        self.label.text = _cell.emotionModel.text;
    }
}

@end



#pragma mark - GIF Tip

#define SIDE_BAR_WIDTH 30
#define MIDDLE_BAR_WIDTH 20
#define TOTAL_BAR_SIZE 148
#define ARROW_HEIGHT 10


typedef NS_ENUM(NSInteger, LLTipPositionType) {
    kLLTipPositionTypeLeft = 1,
    kLLTipPositionTypeMiddle,
    kLLTipPositionTypeRight
};


@interface LLCollectionGifTip ()

@property (nonatomic) UIImageView *leftBackgroundImageView;
@property (nonatomic) UIImageView *middleBackgroundImageView;
@property (nonatomic) UIImageView *rightBackgroundImageView;

@property (nonatomic) LLTipPositionType type;

@property (nonatomic) UIImageView *gifImageView;

@end


@implementation LLCollectionGifTip

+ (instancetype)sharedTip {
    static LLCollectionGifTip *tip;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        tip = [[LLCollectionGifTip alloc] initWithFrame:CGRectMake(0, 0, TOTAL_BAR_SIZE, TOTAL_BAR_SIZE + ARROW_HEIGHT)];
    });

    return tip;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsLeft"];
        self.middleBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsMiddle"];
        self.rightBackgroundImageView = [self imageWithResizbleImage:@"EmoticonBigTipsRight"];

        _type = 0;

        CGFloat gap = 0.1 * TOTAL_BAR_SIZE;
        CGFloat gifWidth = 0.8 * TOTAL_BAR_SIZE;
        self.gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(gap, gap, gifWidth, gifWidth)];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.gifImageView];
    }

    return self;
}

- (UIImageView *)imageWithResizbleImage:(NSString *)imageName {
    UIImage *image = [[UIImage imageNamed:imageName] resizableImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    [self addSubview:imageView];

    return imageView;
}


- (void)showTipOnCell:(LLCollectionGifCell *)cell {
    if (cell == _cell) return;
    _cell = cell;

    if (!_cell || !_cell.emotionModel.imageGIF) {
        self.gifImageView.image = nil;
        [self removeFromSuperview];
    }else {
        UIView *superView = _cell.superview.superview;
        [superView addSubview:self];
        
        CGPoint point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame)/2, 0) toView:superView];
        LLTipPositionType type = kLLTipPositionTypeMiddle;
        CGRect frame = self.frame;
        frame.origin.y = point.y - TOTAL_BAR_SIZE - ARROW_HEIGHT + 4;

        CGFloat _x = point.x - TOTAL_BAR_SIZE/2;
        if (_x < 0) {
            type = kLLTipPositionTypeLeft;
            point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame) * 0.45, 0) toView:superView];
            frame.origin.x = point.x - SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH /2;

        }else if (TOTAL_BAR_SIZE + _x > SCREEN_WIDTH) {
            type = kLLTipPositionTypeRight;
            point = [_cell convertPoint:CGPointMake(CGRectGetWidth(_cell.frame) * 0.55, 0) toView:superView];
            frame.origin.x = point.x + SIDE_BAR_WIDTH + MIDDLE_BAR_WIDTH /2 - TOTAL_BAR_SIZE;

        }else {
            type = kLLTipPositionTypeMiddle;
            frame.origin.x = _x;
        }

        self.frame = frame;

        [self updateBackgroundWithType:type];

        NSData *gifData = [[LLEmotionModelManager sharedManager] gifDataForEmotionModel:_cell.emotionModel];
        self.gifImageView.image = [UIImage sd_animatedGIFWithData:gifData];
    }
}

- (void)updateBackgroundWithType:(LLTipPositionType)type {
    if (_type == type) return;
    _type = type;

    if (_type == kLLTipPositionTypeLeft) {
        self.leftBackgroundImageView.frame = CGRectMake(0,0, SIDE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(SIDE_BAR_WIDTH, 0, MIDDLE_BAR_WIDTH,
                TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(SIDE_BAR_WIDTH + MIDDLE_BAR_WIDTH, 0, (TOTAL_BAR_SIZE -
                SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH), TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }else if (type == kLLTipPositionTypeMiddle) {
        CGFloat side = (TOTAL_BAR_SIZE - MIDDLE_BAR_WIDTH)/2;
        self.leftBackgroundImageView.frame = CGRectMake(0, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(side, 0, MIDDLE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(TOTAL_BAR_SIZE - side, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }else if (type ==kLLTipPositionTypeRight) {
        CGFloat side = (TOTAL_BAR_SIZE - SIDE_BAR_WIDTH - MIDDLE_BAR_WIDTH);
        self.leftBackgroundImageView.frame = CGRectMake(0, 0, side, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.middleBackgroundImageView.frame = CGRectMake(side, 0, MIDDLE_BAR_WIDTH, TOTAL_BAR_SIZE + ARROW_HEIGHT);
        self.rightBackgroundImageView.frame = CGRectMake(TOTAL_BAR_SIZE - SIDE_BAR_WIDTH, 0, SIDE_BAR_WIDTH,
                TOTAL_BAR_SIZE + ARROW_HEIGHT);
    }
}


@end
