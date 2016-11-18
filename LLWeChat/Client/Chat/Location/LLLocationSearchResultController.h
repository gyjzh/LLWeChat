//
//  LLLocationSearchResultController.h
//  LLWeChat
//
//  Created by GYJZH on 8/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSearchResultDelegate.h"
#import "LLGaoDeLocationViewController.h"
#import "LLSearchViewController.h"

@interface LLLocationSearchResultController : UIViewController<LLSearchResultDelegate>

@property (nonatomic, weak) LLGaoDeLocationViewController *gaodeViewController;
@property (nonatomic, weak) LLSearchViewController *searchViewController;


@end
