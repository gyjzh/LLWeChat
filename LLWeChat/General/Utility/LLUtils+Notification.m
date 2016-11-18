//
//  LLUtils+Notification.m
//  LLWeChat
//
//  Created by GYJZH on 9/15/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils+Notification.h"

@implementation LLUtils (Notification)

+ (UIUserNotificationType)getCurrentRegistedNotificationType {
    UIUserNotificationType notificationType = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    return notificationType;
}

+ (BOOL)isEnabledNotification {
    UIUserNotificationType notificationType = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    
    return notificationType != UIUserNotificationTypeNone;
}

@end
