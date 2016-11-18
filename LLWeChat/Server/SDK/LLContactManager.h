//
//  LLContactManager.h
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLContactModel.h"
#import "LLSDKError.h"
#import "InvitationManager.h"

#define LLContactChangedNotification @"LLContactChangedNotification"

NS_ASSUME_NONNULL_BEGIN

@interface LLContactManager : NSObject

+ (instancetype)sharedManager;

- (void)asynGetContactsFromDB:(void (^ __nullable)(NSArray<LLContactModel *> *))complete;

- (NSArray<LLContactModel *> *)getContactsFromDB;

- (void)asynGetContactsFromServer:(void (^ __nullable)(NSArray<LLContactModel *> *))complete;

- (LLSDKError *)addContact:(NSString *)buddyName;

- (void)acceptInvitationWithApplyEntity:(ApplyEntity *)entity completeCallback:(void (^ __nullable)(LLSDKError *error))completeCallback;

NS_ASSUME_NONNULL_END

@end
