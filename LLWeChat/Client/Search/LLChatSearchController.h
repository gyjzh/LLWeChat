//
//  LLChatSearchController.h
//  LLWeChat
//
//  Created by GYJZH on 9/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLViewController.h"
#import "LLSearchResultDelegate.h"
#import "LLSearchViewController.h"

@interface LLChatSearchController : LLViewController<LLSearchResultDelegate>

@property (nonatomic, weak) LLSearchViewController *searchViewController;

@end
