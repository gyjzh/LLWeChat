//
//  UITableView+LLExt.m
//  LLWeChat
//
//  Created by GYJZH on 03/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "UITableView+LLExt.h"

@implementation UITableView (LLExt)

- (void)scrollsToBottomAnimated:(BOOL)animated {
    NSInteger sectionCount = [self.dataSource numberOfSectionsInTableView:self];
    if (sectionCount < 1)
        return;
    
    NSInteger count = [self.dataSource tableView:self numberOfRowsInSection:sectionCount - 1];
    if (count < 1)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count - 1 inSection:sectionCount - 1];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    if (cell) {
        CGFloat offsetY = self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.frame);
        if (offsetY < -self.contentInset.top)
            offsetY = -self.contentInset.top;
        
        [self setContentOffset:CGPointMake(0, offsetY) animated:animated];
    }else {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

@end
