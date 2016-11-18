//
//  LLMainViewController.h
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLConversationModel.h"
#import "LLNavigationController.h"
#import "LLChatViewController.h"

typedef NS_ENUM(NSInteger, LLMainTabbarIndex) {
    kLLMainTabbarIndexChat = 0,
    kLLMainTabbarIndexContact,
    kLLMainTabbarIndexDiscovery,
    kLLMainTabbarIndexMe
};

@interface LLMainViewController : LLNavigationController

@property (nonatomic) LLChatViewController *chatViewController;

- (void)chatWithContact:(NSString *)buddy;

- (void)chatWithConversationModel:(LLConversationModel *)conversationModel;

- (void)setTabbarBadgeValue:(NSInteger)badge tabbarIndex:(LLMainTabbarIndex)tabbarIndex;

@end
