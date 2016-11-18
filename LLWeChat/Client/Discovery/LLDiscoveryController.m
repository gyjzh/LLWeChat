//
//  LLDiscoveryController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLDiscoveryController.h"
#import "LLTableViewCellData.h"
#import "LLTableViewCell.h"
#import "LLUtils.h"

@interface LLDiscoveryController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray<NSArray<LLTableViewCellData *> *> *dataSource;

@end

@implementation LLDiscoveryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发现";
    
    NSArray<LLTableViewCellData *> *section1 = @[
         [[LLTableViewCellData alloc] initWithTitle:@"朋友圈" iconName:@"ff_IconShowAlbum"]
    ];
    
    NSArray<LLTableViewCellData *> *section2 = @[
         [[LLTableViewCellData alloc] initWithTitle:@"扫一扫" iconName:@"ff_IconQRCode"],
         [[LLTableViewCellData alloc] initWithTitle:@"摇一摇" iconName:@"ff_IconShake"]
    ];
    
    NSArray<LLTableViewCellData *> *section3 = @[
         [[LLTableViewCellData alloc] initWithTitle:@"附近的人" iconName:@"ff_IconLocationService"],
         [[LLTableViewCellData alloc] initWithTitle:@"漂流瓶" iconName:@"ff_IconBottle"]
    ];
    
    NSArray<LLTableViewCellData *> *section4 = @[
         [[LLTableViewCellData alloc] initWithTitle:@"购物" iconName:@"MoreMyBankCard"],
         [[LLTableViewCellData alloc] initWithTitle:@"游戏" iconName:@"MoreGame"]
    ];
    
    self.dataSource = @[section1, section2, section3, section4];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.rowHeight = TABLE_VIEW_CELL_DEFAULT_HEIGHT;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, MAIN_BOTTOM_TABBAR_HEIGHT, 0);

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 15;
    else
        return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLE_SECTION_HEIGHT_ZERO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ID";
    
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleDefault reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    LLTableViewCellData *itemData = self.dataSource[indexPath.section][indexPath.row];

    cell.textLabel.text = itemData.title;
    cell.imageView.image = itemData.icon;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
