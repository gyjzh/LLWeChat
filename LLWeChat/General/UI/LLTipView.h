//
//  LLTipView.h
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLTipDelegate.h"

@interface LLTipView : UIView

+ (void)showTipView:(nonnull UIView<LLTipDelegate> *)view;

+ (void)hideTipView:(nonnull UIView<LLTipDelegate> *)tipView;

@end
