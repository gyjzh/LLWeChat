//
//  LLArticleSearchController.m
//  LLWeChat
//
//  Created by GYJZH on 9/22/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLArticleSearchController.h"


@interface LLArticleSearchController ()

@end

@implementation LLArticleSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)fetchData {
    self.dataSources = [@[@"热门话题",@"我的精选",@"科技互联网"] mutableCopy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
