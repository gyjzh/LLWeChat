//
//  LLSearchBar.h
//  CYLSearchViewController
//
//  Created by GYJZH on 8/23/16.
//  Copyright © 2016 chenyilong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SEARCH_TEXT_FIELD_HEIGHT 28

@interface LLSearchBar : UISearchBar

+ (NSInteger)defaultSearchBarHeight;

+ (instancetype)defaultSearchBar;

+ (instancetype)defaultSearchBarWithFrame:(CGRect)frame;

- (UITextField *)searchTextField;

- (UIButton *)searchCancelButton;

- (void)resignFirstResponderWithCancelButtonRemainEnabled;

- (void)configCancelButton;

@end
