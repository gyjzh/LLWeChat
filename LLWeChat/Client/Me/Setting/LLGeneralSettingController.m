//
//  LLGeneralSettingController.m
//  LLWeChat
//
//  Created by GYJZH on 09/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLGeneralSettingController.h"
#import "LLUtils.h"
#import "LLTableViewCell.h"
#import "LLUserProfile.h"

#define TABLE_CELL_ID @"ID"

@interface LLGeneralSettingController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray<NSArray<NSString *> *> *dataSource;
@property (nonatomic) NSArray<NSString *> *footerTexts;

@property (nonatomic) UITableView *tableView;

@end

@implementation LLGeneralSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"通用";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = @[
                        @[@"双击全屏查看文本消息"]
                        ];
    
    self.footerTexts = @[@"开启后，需要双击文本才能全屏查看文本消息。关闭后，单击即可全屏查看文本消息。"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = TABLE_VIEW_CELL_DEFAULT_HEIGHT;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, TABLE_VIEW_CELL_LEFT_MARGIN, 0, 0);
    [self.view addSubview:self.tableView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return TABLE_SECTION_HEIGHT_ZERO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGSize size = [LLUtils boundingSizeForText:self.footerTexts[section] maxWidth:SCREEN_WIDTH - TABLE_VIEW_CELL_LEFT_MARGIN * 2 font:[UIFont systemFontOfSize:FOOTER_LABEL_FONT_SIZE] lineSpacing:0];
    return size.height + 20 + 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleValueLeft reuseIdentifier:TABLE_CELL_ID];
        switch (indexPath.section) {
            case 0: {
                cell.accessoryType_LL = kLLTableViewCellAccessorySwitch;
                BOOL isOn = [LLUserProfile myUserProfile].userOptions.doubleTapToShowTextMessage;
                [cell setSwitchOn:isOn animated:NO];
                break;
            default:
                break;
            }
            
        }
        
    }
    
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat height = [self tableView:tableView heightForFooterInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = self.tableView.backgroundColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TABLE_VIEW_CELL_LEFT_MARGIN, 5, SCREEN_WIDTH - TABLE_VIEW_CELL_LEFT_MARGIN * 2, height - 20 - 5)];
    label.font = [UIFont systemFontOfSize:FOOTER_LABEL_FONT_SIZE];
    label.textColor = kLLTextColor_lightGray_system;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = self.footerTexts[section];
    [view addSubview:label];
    
    return view;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.navigationController.childViewControllers containsObject:self]) {
        LLTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        LLUserGeneralOptions *userOptions = [LLUserProfile myUserProfile].userOptions;
        if (cell.isSwitchOn != userOptions.doubleTapToShowTextMessage) {
            userOptions.doubleTapToShowTextMessage = cell.isSwitchOn;
            [[LLUserProfile myUserProfile] saveUserOptions];
        }
        
    }
}


@end
