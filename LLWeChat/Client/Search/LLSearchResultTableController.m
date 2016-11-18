//
//  LLSearchResultTableController.m
//  LLWeChat
//
//  Created by GYJZH on 06/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSearchResultTableController.h"
#import "LLMessageSearchResultCell.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"

#define CELL_REUSE_ID @"Cell_Reuse_Id"

#define TABLE_CELL_HEIGHT 68

@interface LLSearchResultTableController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@end

@implementation LLSearchResultTableController {
    BOOL navigationBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.rowHeight = TABLE_CELL_HEIGHT;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableHeaderView = [self tableHeaderView];
    [self.view addSubview:_tableView];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blackView.backgroundColor = [UIColor blackColor];
    [_tableView addSubview:blackView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LLMessageSearchResultCell" bundle:nil] forCellReuseIdentifier:CELL_REUSE_ID];
    
    self.title = self.searchResultModels[0].nickName;
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    navigationBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidlDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:navigationBarHidden animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLMessageSearchResultCell *cell = (LLMessageSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    LLMessageSearchResultModel *model = self.searchResultModels[indexPath.row];
    [cell setSearchResultModels:@[model] showDate:NO];

    //最后一个Cell的Seperator
    if (indexPath.row == self.searchResultModels.count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (UIView *)tableHeaderView {
    CGFloat height = 40;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = UIColorRGB(240, 240, 240);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 18, SCREEN_WIDTH , 15)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = kLLTextColor_lightGray_system;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"共%ld条与\"%@\"相关的聊天记录", (unsigned long)self.searchResultModels.count, self.searchText];
    [view addSubview:label];
    
    return view;
}


@end
