//
//  LLBrandContactSearchController.m
//  LLWeChat
//
//  Created by GYJZH on 9/22/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLBrandContactSearchController.h"
#import "UIKit+LLExt.h"

@interface LLBrandContactSearchController ()

@end

@implementation LLBrandContactSearchController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData {
    self.dataSources = [@[@"网易在线",@"狗狗看天下", @"一周趣闻", @"说走就走的旅行", @"北京晚报", @"招商银行信用卡"] mutableCopy];
}


@end
