//
//  LLEmotionInputView.h
//  LLWeChat
//
//  Created by GYJZH on 7/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLEmotionModelManager.h"

@protocol ILLEmotionInputDelegate <NSObject>

- (void)emojiCellDidSelected:(LLEmotionModel *)model;

- (void)gifCellDidSelected:(LLEmotionModel *)model;

- (void)sendCellDidSelected;

- (void)deleteCellDidSelected;

@end

@interface LLEmotionInputView : UIView

@property (nonatomic, weak) id<ILLEmotionInputDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)sendEnabled:(BOOL)enabled;

@end
