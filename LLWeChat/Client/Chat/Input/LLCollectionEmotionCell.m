//
//  LLCollectionEmotionCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLCollectionEmotionCell.h"
#import "LLCollectionEmotionTip.h"

static CGPoint tipPoint;

@interface LLCollectionEmojiCell ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation LLCollectionEmojiCell {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame) - EMOJI_IMAGE_SIZE) /2, (CGRectGetHeight(frame) - EMOJI_IMAGE_SIZE) /2, EMOJI_IMAGE_SIZE, EMOJI_IMAGE_SIZE)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:self.imageView];
        
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)setContent:(LLEmotionModel *)model {
    self.emotionModel = model;
    self.isDelete = NO;
    
    if (model)
        self.imageView.image = [[LLEmotionModelManager sharedManager] imageForEmotionModel:model];
}

- (void)setIsDelete:(BOOL)isDelete {
    _isDelete = isDelete;
    if (_isDelete) {
        self.emotionModel = nil;
        self.imageView.image = [UIImage imageNamed:@"emotion_delete"];
    }else {
        self.imageView.image = nil;
    }
}

- (CGPoint)tipFloatPoint {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tipPoint = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetMaxY(self.imageView.frame));
    });
    
    return tipPoint;
}

- (void)didClicked {
    
}


- (void)didMoveIn {
    if (!self.emotionModel) return;
    
    self.hidden = YES;
    [[LLCollectionEmojiTip sharedTip] showTipOnCell:self];
}

- (void)didMoveOut {
    if (!self.emotionModel) return;
    
    self.hidden = NO;
    [[LLCollectionEmojiTip sharedTip] showTipOnCell:nil];
}


@end




@interface LLCollectionGifCell ()

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UIImageView *highlightedBackgroundView;

@property (nonatomic) UILabel *label;

@end


@implementation LLCollectionGifCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.highlightedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmoticonFocus"]];
        self.highlightedBackgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame));
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.highlightedBackgroundView];
        self.highlightedBackgroundView.hidden = YES;

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetWidth(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetWidth(frame))];
        self.label.font = [UIFont systemFontOfSize:13];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:self.label];
        
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)setContent:(LLEmotionModel *)model {
    _emotionModel = model;
    if (!model) {
        self.imageView.image = nil;
        self.label.text = @"";
    }else {
        self.imageView.image = [[LLEmotionModelManager sharedManager] imageForEmotionModel:model];
        self.label.text = model.text;
    }
}

- (void)didClicked {
    
    
}

- (void)didMoveIn {
    if (!self.emotionModel) return;

    self.highlightedBackgroundView.hidden = NO;
    [[LLCollectionGifTip sharedTip] showTipOnCell:self];
}

- (void)didMoveOut {
    if (!self.emotionModel) return;

    self.highlightedBackgroundView.hidden = YES;
    [[LLCollectionGifTip sharedTip] showTipOnCell:nil];
}



@end
