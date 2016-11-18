//
//  LLSearchResultTableController.h
//  LLWeChat
//
//  Created by GYJZH on 06/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageSearchResultModel.h"

@interface LLSearchResultTableController : UIViewController

@property (nonatomic) NSArray<LLMessageSearchResultModel *> *searchResultModels;

@property (nonatomic, copy) NSString *searchText;

@end
