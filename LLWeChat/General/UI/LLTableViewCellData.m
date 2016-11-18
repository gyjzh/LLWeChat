//
//  LLTableViewCellData.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLTableViewCellData.h"

@implementation LLTableViewCellData

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName {
    return [self initWithTitle:title subTitle:nil iconName:iconName];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconName:(NSString *)iconName {
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = [UIImage imageNamed:iconName];
        self.subTitle = subTitle;
    }
    
    return self;
}

@end
