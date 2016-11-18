//
//  LLNoDisturbTableViewController.m
//  LLWeChat
//
//  Created by GYJZH on 9/14/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLNoDisturbTableViewController.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import "LLTableViewCell.h"
#import "LLPushOptions.h"
#import "LLUserProfile.h"

@interface LLNoDisturbTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray<NSString *> *dataSource;
@property (nonatomic) NSString *footerText;

@end

@implementation LLNoDisturbTableViewController {
    NSIndexPath *curSelectIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"功能消息免打扰";
    self.dataSource = @[@"开启", @"只在夜间开启", @"关闭"];
    self.footerText = @"开启后，“QQ邮箱提醒”在收到邮件后，手机不会震动与发出提示音。如果设置为“只在夜间开启”，则只在22:00到8:00间生效。";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = TABLE_VIEW_CELL_DEFAULT_HEIGHT;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, TABLE_VIEW_CELL_LEFT_MARGIN, 0, 0);
    [self.view addSubview:self.tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat height = [self tableView:tableView heightForFooterInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = self.tableView.backgroundColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TABLE_VIEW_CELL_LEFT_MARGIN, 5, SCREEN_WIDTH - TABLE_VIEW_CELL_LEFT_MARGIN * 2, height - 5)];
    label.font = [UIFont systemFontOfSize:FOOTER_LABEL_FONT_SIZE];
    label.textColor = kLLTextColor_lightGray_system;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = self.footerText;
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGSize size = [LLUtils boundingSizeForText:self.footerText maxWidth:SCREEN_WIDTH - TABLE_VIEW_CELL_LEFT_MARGIN * 2 font:[UIFont systemFontOfSize:FOOTER_LABEL_FONT_SIZE] lineSpacing:0];
    return size.height + 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_TABLE_CELL_ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleValueLeft reuseIdentifier:DEFAULT_TABLE_CELL_ID];
        
        LLPushNoDisturbSetting setting = [LLUserProfile myUserProfile].pushOptions.noDisturbSetting;
        BOOL isOn = ((indexPath.row == 0) && (setting == kLLPushNoDisturbSettingDay))
            || ((indexPath.row == 1) && (setting == kLLPushNoDisturbSettingCustom)) ||
               ((indexPath.row == 2) && (setting == kLLPushNoDisturbSettingClose));
        
        if (isOn) {
            cell.accessoryType_LL = kLLTableViewCellAccessoryCheckmark;
            curSelectIndexPath = indexPath;
        }else
            cell.accessoryType_LL = kLLTableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (curSelectIndexPath.row == indexPath.row)
        return;
    
    LLTableViewCell *cell = [tableView cellForRowAtIndexPath:curSelectIndexPath];
    cell.accessoryType_LL = kLLTableViewCellAccessoryNone;
    
    curSelectIndexPath = indexPath;
    cell = [tableView cellForRowAtIndexPath:curSelectIndexPath];
    cell.accessoryType_LL = kLLTableViewCellAccessoryCheckmark;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!curSelectIndexPath)
        return;
    
    LLPushNoDisturbSetting setting;
    if (curSelectIndexPath.row == 0) {
        setting = kLLPushNoDisturbSettingDay;
    }else if (curSelectIndexPath.row == 1) {
        setting = kLLPushNoDisturbSettingCustom;
    }else if (curSelectIndexPath.row == 2) {
        setting = kLLPushNoDisturbSettingClose;
    }
    
    [LLUserProfile myUserProfile].pushOptions.noDisturbSetting = setting;
    
//    [[LLClientManager sharedManager] savePushOptionsToServer];
}

@end
