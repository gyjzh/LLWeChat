//
//  LLContactManager.m
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactManager.h"
#import "LLUtils.h"
#import "EMSDK.h"


#define CONTACT_QUEUE_ID "CONTACT_QUEUE_ID"

@interface LLContactManager () <EMContactManagerDelegate>

@property (nonatomic) dispatch_queue_t contact_queue;

@property (nonatomic) NSMutableArray<LLContactModel *> *allContacts;

@end

@implementation LLContactManager

CREATE_SHARED_MANAGER(LLContactManager)


- (instancetype)init {
    self = [super init];
    if (self) {
        _contact_queue = dispatch_queue_create(CONTACT_QUEUE_ID, DISPATCH_QUEUE_SERIAL);
        
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:_contact_queue];
        
    }
    
    return self;
}


#pragma mark - 获取好友 -

- (void)getContacts:(void (^)(NSArray<LLContactModel *> *))complete {
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContacts];
    
    NSMutableArray<LLContactModel *> *allContacts = [NSMutableArray arrayWithCapacity:buddyList.count + 1];
    for (NSString *buddy in buddyList) {
        LLContactModel *model = [[LLContactModel alloc] initWithBuddy:buddy];
        [allContacts addObject:model];
    }
    
    //        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    //        if (loginUsername && loginUsername.length > 0) {
    //            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:loginUsername];
    //            [allContacts addObject:model];
    //        }
    
    if (complete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(allContacts);
        });
    }

}

- (void)asynGetContactsFromDB:(void (^ __nullable)(NSArray<LLContactModel *> *))complete {
    dispatch_async(_contact_queue, ^{
        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
        
        NSMutableArray<LLContactModel *> *allContacts = [NSMutableArray arrayWithCapacity:buddyList.count];
        for (NSString *buddy in buddyList) {
            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:buddy];
            [allContacts addObject:model];
        }
        
//        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
//        if (loginUsername && loginUsername.length > 0) {
//            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:loginUsername];
//            [allContacts addObject:model];
//        }
        
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(allContacts);
            });
        }
        
    });

}

- (NSArray<LLContactModel *> *)getContactsFromDB {
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
    
    NSMutableArray<LLContactModel *> *allContacts = [NSMutableArray arrayWithCapacity:buddyList.count];
    for (NSString *buddy in buddyList) {
        LLContactModel *model = [[LLContactModel alloc] initWithBuddy:buddy];
        [allContacts addObject:model];
    }
    
    //        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    //        if (loginUsername && loginUsername.length > 0) {
    //            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:loginUsername];
    //            [allContacts addObject:model];
    //        }
    
    return allContacts;
}

- (void)asynGetContactsFromServer:(void (^)(NSArray<LLContactModel *> *))complete {
    [[EMClient sharedClient].contactManager asyncGetContactsFromServer:^(NSArray *buddyList) {
        NSMutableArray<LLContactModel *> *allContacts = [NSMutableArray arrayWithCapacity:buddyList.count];
        for (NSString *buddy in buddyList) {
            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:buddy];
            [allContacts addObject:model];
        }
        
//        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
//        if (loginUsername && loginUsername.length > 0) {
//            LLContactModel *model = [[LLContactModel alloc] initWithBuddy:loginUsername];
//            [allContacts addObject:model];
//        }
        
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(allContacts);
            });
        }
        
    } failure:^(EMError *aError) {
        
    }];
}

- (LLSDKError *)addContact:(NSString *)buddyName {
    EMError *error = [[EMClient sharedClient].contactManager addContact:buddyName message:@"赌神赌圣赌侠赌王赌霸"];
    
    return error ? [LLSDKError errorWithEMError:error] : nil;
}

#pragma mark - 好友关系变化回调 -

/**
 *  对方同意加我为好友
 *
 *  @param aUsername <#aUsername description#>
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    dispatch_async(dispatch_get_main_queue(), ^{
        [LLUtils showTextHUD:[NSString stringWithFormat:@"%@同意加你为好友", aUsername]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LLContactChangedNotification object:[LLContactManager sharedManager]];
    });
    
}

/**
 *  对方拒绝加我为好友
 *
 *  @param aUsername <#aUsername description#>
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername {
    
}

/**
 *  对方删除与我的好友关系
 *
 *  @param aUsername <#aUsername description#>
 */
- (void)didReceiveDeletedFromUsername:(NSString *)aUsername {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LLContactChangedNotification object:[LLContactManager sharedManager]];
    });
}


/**
 *  好友关系建立，双方都收到该回调
 *
 *  @param aUsername <#aUsername description#>
 */
- (void)didReceiveAddedFromUsername:(NSString *)aUsername {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LLContactChangedNotification object:[LLContactManager sharedManager]];
    });

}


/**
 *  收到对方发来的好友申请请求
 *
 *  @param aUsername <#aUsername description#>
 *  @param aMessage  <#aMessage description#>
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    if (!aUsername) {
        return;
    }
    
    [self addNewApply:aUsername];

}


- (void)addNewApply:(NSString *)userName {
    if (userName.length > 0) {
        //new apply
        ApplyEntity * newEntity= [[ApplyEntity alloc] init];
        newEntity.applicantUsername = userName;
        
        NSString *loginName = [[EMClient sharedClient] currentUsername];
        newEntity.receiverUsername = loginName;
        
        [[InvitationManager sharedInstance] addInvitation:newEntity loginUser:loginName];
        
    }
  
}

- (void)acceptInvitationWithApplyEntity:(ApplyEntity *)entity completeCallback:(void (^ __nullable)(LLSDKError *error))completeCallback {
    MBProgressHUD *HUD = [LLUtils showActivityIndicatiorHUDWithTitle:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:entity.applicantUsername];
        dispatch_async(dispatch_get_main_queue(), ^{
            [LLUtils hideHUD:HUD animated:YES];
            if (!error) {
                NSString *loginUsername = [[EMClient sharedClient] currentUsername];
                [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
            }else {
                [LLUtils showMessageAlertWithTitle:nil message:@"同意添加好友时发生错误"];
            }
            
            if (completeCallback) {
                completeCallback(error ? [LLSDKError errorWithEMError:error] : nil);
            }
        });
    });
    
}

@end
