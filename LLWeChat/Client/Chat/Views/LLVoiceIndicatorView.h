//
//  LLVoiceIndicatorView.h
//  LLWeChat
//
//  Created by GYJZH on 8/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLTipDelegate.h"

typedef NS_ENUM(NSInteger, LLVoiceIndicatorStyle) {
    kLLVoiceIndicatorStyleRecord = 0,
    kLLVoiceIndicatorStyleCancel,
    kLLVoiceIndicatorStyleTooShort,
    kLLVoiceIndicatorStyleTooLong,
    kLLVoiceIndicatorStyleVolumeTooLow,

};


@interface LLVoiceIndicatorView : UIView<LLTipDelegate>

@property (nonatomic) LLVoiceIndicatorStyle style;

- (void)setCountDown:(NSInteger)countDown;

- (void)updateMetersValue:(CGFloat)value;

@end
