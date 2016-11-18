//
//  LLSearchViewController.h
//  CYLSearchViewController
//
//  Created by GYJZH on 8/23/16.
//  Copyright © 2016 chenyilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSearchResultDelegate.h"
#import "LLSearchControllerDelegate.h"
#import "LLSearchBar.h"

#define HIDE_ANIMATION_DURATION 0.3
#define SHOW_ANIMATION_DURATION 0.3

@interface LLSearchViewController : UIViewController

@property (nonatomic) UIViewController<LLSearchResultDelegate>* searchResultController;

@property (nonatomic, weak) id<LLSearchControllerDelegate> delegate;

@property (nonatomic) LLSearchBar *searchBar;

+ (instancetype)sharedInstance;

+ (void)destoryInstance;

- (void)showInViewController:(UIViewController *)controller fromSearchBar:(UISearchBar *)fromSearchBar ;

- (void)dismissSearchController;

- (void)dismissKeyboard;

@end
