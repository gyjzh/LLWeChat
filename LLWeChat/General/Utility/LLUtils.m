//
//  LLUtils.m
//  LLWeChat
//
//  Created by GYJZH on 7/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLColors.h"
#import "LLEmotionModelManager.h"
#import "MBProgressHUD.h"

@interface LLUtils ()

@end


@implementation LLUtils

+ (instancetype)sharedUtils {
    static LLUtils *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLUtils alloc] init];
    });
    
    return _instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSTimeInterval)adjustTimestampFromServer:(long long)timestamp {
    if (timestamp > 140000000000) {
        timestamp /= 1000;
    }
    return timestamp;
}


+ (UIButton *)navigationBackButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.8];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, 0, 47, 50);
    
    return btn;
}



@end











