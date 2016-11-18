//
//  LLUserProfile.m
//  LLWeChat
//
//  Created by GYJZH on 7/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUserProfile.h"

@implementation LLUserProfile


+ (instancetype)myUserProfile {
    static LLUserProfile *_myUserProfile;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _myUserProfile = [[LLUserProfile alloc] init];
    });
    
    return _myUserProfile;
}

- (void)initUserProfileWithUserName:(NSString *)userName nickName:(NSString *)nickName avatarURL:(NSString *)avatarURL {
    self.userName = userName;
    self.nickName = nickName.length > 0 ? nickName : userName;
    self.avatarURL = avatarURL.length > 0 ? avatarURL : @"icon_avatar";
    
    self.userOptions = [[LLUserGeneralOptions alloc] initWithUserKey:userName];
    self.pushOptions = [[LLPushOptions alloc] init];
}

- (void)saveUserOptions {
    [self.userOptions saveWithUserKey:self.userName];
}

@end
