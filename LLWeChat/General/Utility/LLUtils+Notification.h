//
//  LLUtils+Notification.h
//  LLWeChat
//
//  Created by GYJZH on 9/15/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"

@interface LLUtils (Notification)

+ (UIUserNotificationType)getCurrentRegistedNotificationType;

+ (BOOL)isEnabledNotification;

@end
