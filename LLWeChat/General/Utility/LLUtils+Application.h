//
//  LLUtils+Application.h
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"
#import "AppDelegate.h"

@interface LLUtils (Application)

+ (UIViewController *)rootViewController;

+ (UIWindow *)currentWindow;

+ (UIWindow *)popOverWindow;

+ (void)addViewToPopOverWindow:(UIView *)view;

+ (void)removeViewFromPopOverWindow:(UIView *)view;

+ (AppDelegate *)appDelegate;

+ (UIViewController *)viewControllerForView:(UIView *)view;

+ (void)removeViewControllerFromParentViewController:(UIViewController *)viewController;

+ (void)addViewController:(UIViewController *)viewController  toViewController:(UIViewController *)parentViewController;

+ (void)startObserveRunLoop;

+ (void)stopObserveRunLoop;

@end
