//
//  LLUserGeneralOptions.m
//  LLWeChat
//
//  Created by GYJZH on 09/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUserGeneralOptions.h"
#import "LLConfig.h"

@implementation LLUserGeneralOptions

- (instancetype)initWithUserKey:(NSString *)userKey {
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *doubleTapKey = [NSString stringWithFormat:@"%@_%@", userKey, DOUBLE_TAP_SHOW_TEXT_KEY];
        NSNumber *doubleTapValue = [userDefaults objectForKey:doubleTapKey];
        if (doubleTapValue) {
            self.doubleTapToShowTextMessage = [doubleTapValue boolValue];
        }else {
            self.doubleTapToShowTextMessage = NO;
        }
        
    }
    
    return self;
}

- (void)saveWithUserKey:(NSString *)userKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *doubleTapKey = [NSString stringWithFormat:@"%@_%@", userKey, DOUBLE_TAP_SHOW_TEXT_KEY];
    
    [userDefaults setObject:@(self.doubleTapToShowTextMessage) forKey:doubleTapKey];
    [userDefaults synchronize];
}

@end
