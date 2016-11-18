//
//  LLSNSSearchController.m
//  LLWeChat
//
//  Created by GYJZH on 9/22/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSNSSearchController.h"
#import "LLUtils.h"

@interface LLSNSSearchController () <UISearchBarDelegate>

@end

@implementation LLSNSSearchController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchData {
    self.dataSources = [@[@"朋友分享的音乐",@"朋友关注的美食",@"朋友喜事"] mutableCopy];
}

@end
