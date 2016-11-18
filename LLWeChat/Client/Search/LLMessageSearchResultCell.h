//
//  LLMessageSearchResultCell.h
//  LLWeChat
//
//  Created by GYJZH on 06/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageSearchResultModel.h"

@interface LLMessageSearchResultCell : UITableViewCell

@property (nonatomic) NSArray<LLMessageSearchResultModel *> *searchResultModels;

- (void)setSearchResultModels:(NSArray<LLMessageSearchResultModel *> *)searchResultModels showDate:(BOOL)showDate;

@end
