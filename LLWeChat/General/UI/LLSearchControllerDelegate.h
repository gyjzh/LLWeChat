//
//  LLSearchControllerDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 8/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LLSearchViewController;
@protocol LLSearchControllerDelegate <NSObject>

@optional
- (void)willDismissSearchController:(LLSearchViewController *)searchController;

- (void)didDismissSearchController:(LLSearchViewController *)searchController;

- (void)willPresentSearchController:(LLSearchViewController *)searchController;

- (void)didPresentSearchController:(LLSearchViewController *)searchController;

@end
