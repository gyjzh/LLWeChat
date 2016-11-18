//
//  LLWebViewProgressView.h
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

//参考项目网址：https://github.com/ninjinkun/NJKWebViewProgress

#import <UIKit/UIKit.h>

@interface LLWebViewProgressView : UIView

//如果未设置，则使用系统默认tintColor
@property (nonatomic) UIColor *progressBarColor;

- (void)reset;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
