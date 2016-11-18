//
//  LLCollectionEmotionTip.h
//  LLWeChat
//
//  Created by GYJZH on 7/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLCollectionEmotionCell.h"

@interface LLCollectionEmojiTip : UIView

@property (nonatomic) LLCollectionEmojiCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(LLCollectionEmojiCell *)cell;

@end



@interface LLCollectionGifTip : UIView

@property (nonatomic) LLCollectionGifCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(LLCollectionGifCell *)cell;

@end