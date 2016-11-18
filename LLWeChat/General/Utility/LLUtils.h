//
//  LLUtils.h
//  LLWeChat
//
//  Created by GYJZH on 7/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

@import UIKit;
#import "LLMacro.h"
#import "LLColors.h"
#import "LLConfig.h"
#import "LLEmotionModel.h"


NS_ASSUME_NONNULL_BEGIN

inline static long long adjustTimestampFromServer(long long timestamp) {
    if (timestamp > 140000000000) {
        timestamp /= 1000;
    }
    return timestamp;
}


@interface LLUtils : NSObject

+ (instancetype)sharedUtils;

//服务器返回的时间戳单位可能是毫秒
+ (NSTimeInterval)adjustTimestampFromServer:(long long)timestamp;

+ (UIButton *)navigationBackButton;

@end


static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
    
    return curve << 16;
}



NS_ASSUME_NONNULL_END

#import "LLUtils+CGHelper.h"
#import "LLUtils+IPhone.h"
#import "LLUtils+File.h"
#import "LLUtils+Video.h"
#import "LLUtils+Text.h"
#import "LLUtils+Application.h"
#import "LLUtils+Popover.h"
#import "LLUtils+Audio.h"
#import "LLUtils+Notification.h"
