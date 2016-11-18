//
//  LLUserProfile.h
//  LLWeChat
//
//  Created by GYJZH on 7/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPushOptions.h"
#import "LLUserGeneralOptions.h"

@interface LLUserProfile : NSObject

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *nickName;
//用户头像资源
@property (nonatomic, copy) NSString *avatarURL;

//用户的通用设置
@property (nonatomic) LLUserGeneralOptions *userOptions;

//用户的消息推送设置
@property (nonatomic) LLPushOptions *pushOptions;

+ (instancetype)myUserProfile;

- (void)initUserProfileWithUserName:(NSString *)userName nickName:(NSString *)nickName avatarURL:(NSString *)avatarURL;

- (void)saveUserOptions;

@end
