//
//  LLMeSettingController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMeSettingController.h"
#import "LLTableViewCellData.h"
#import "LLSDK.h"
#import "LLUtils.h"
#import "LLTableViewCell.h"
#import "LLConfig.h"
#import "LLPushNotificationController.h"
#import "LLGeneralSettingController.h"


@interface LLMeSettingController ()

@property (nonatomic) NSArray<NSArray<NSString *> *> *dataSource;

@end

@implementation LLMeSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.dataSource = @[
                        @[@"账号与安全"],
                        @[@"新消息通知", @"隐私", @"通用"],
                        @[@"帮助与反馈", @"关于微信"],
                        @[@"退出登录"]
                        ];
    
    self.tableView.rowHeight = TABLE_VIEW_CELL_DEFAULT_HEIGHT;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, TABLE_VIEW_CELL_LEFT_MARGIN, 0, 0);
    
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
    static NSString *LogoutID = @"LogoutID";
    static NSString *ID = @"ID";
    if (indexPath.section == self.dataSource.count - 1) {
        LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LogoutID];
        if (!cell) {
            cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleValueCenter reuseIdentifier:LogoutID];
        }
        
        cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
        
        return cell;
    }else {
        LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleValueLeft reuseIdentifier:ID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
        
        return cell;
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == self.dataSource.count - 1) {
        [self logout];
    }else if (indexPath.section == 1) {
        //新消息通知
        if (indexPath.row == 0) {
            LLPushNotificationController *vc = [[LLPushNotificationController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2) {
            LLGeneralSettingController *vc = [[LLGeneralSettingController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


- (void)logout {
    [[LLClientManager sharedManager] logout];
}




@end
