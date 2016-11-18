//
//  LLCollectionEmotionCell.h
//  LLWeChat
//
//  Created by GYJZH on 7/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLEmotionModelManager.h"

#define EMOJI_IMAGE_SIZE 30

@protocol ILLEmotionTipDelegate <NSObject>

- (void)didMoveIn;

- (void)didMoveOut;

@end

@interface LLCollectionEmojiCell : UICollectionViewCell <ILLEmotionTipDelegate>

@property (nonatomic) LLEmotionModel *emotionModel;

@property (nonatomic) BOOL isDelete;

- (void)setContent:(LLEmotionModel *)model;

- (CGPoint)tipFloatPoint;

@end


//////////////////////////////////


@interface LLCollectionGifCell : UICollectionViewCell <ILLEmotionTipDelegate>

@property (nonatomic) LLEmotionModel *emotionModel;

- (void)setContent:(LLEmotionModel *)model;

@end