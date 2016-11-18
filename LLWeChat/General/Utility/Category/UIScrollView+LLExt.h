//
//  UIScrollView+LLExt.h
//  LLWeChat
//
//  Created by GYJZH on 8/2/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LLExt)

@property (assign, nonatomic) CGFloat insetTop_LL;
@property (assign, nonatomic) CGFloat insetBottom_LL;
@property (assign, nonatomic) CGFloat insetLeft_LL;
@property (assign, nonatomic) CGFloat insetRight_LL;

@property (assign, nonatomic) CGFloat offsetX_LL;
@property (assign, nonatomic) CGFloat offsetY_LL;

@property (assign, nonatomic) CGFloat contentWidth_LL;
@property (assign, nonatomic) CGFloat contentHeight_LL;

- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)scrollToTopAnimated:(BOOL)animated;

- (BOOL)isAtTop;

- (BOOL)isAtBottom;

@end
