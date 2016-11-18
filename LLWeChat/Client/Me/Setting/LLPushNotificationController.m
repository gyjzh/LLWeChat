//
//  LLPushNotificationController.m
//  LLWeChat
//
//  Created by GYJZH on 9/14/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLPushNotificationController.h"
#import "LLUtils.h"
#import "LLTableViewCell.h"
#import "LLNoDisturbTableViewController.h"
#import "LLUserProfile.h"

#define TABLE_CELL_ID @"ID"

@interface LLPushNotificationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray<NSArray<NSString *> *> *dataSource;
@property (nonatomic) NSArray<NSString *> *footerTexts;

@property (nonatomic) UITableView *tableView;

@end

@implementation LLPushNotificationController {
    BOOL isEnabledNotification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新消息通知";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = @[
                  @[@"接受新消息通知"],
                  @[@"通知显示消息详情"],
                  @[@"功能消息免打扰"],
                  @[@"声音", @"振动"],
                  @[@"朋友圈照片更新"]
                      ];

    self.footerTexts = @[@"如果你要关闭或开启微信的新消息通知，请在iPhone的“设置”-“通知”功能中，找到应用程序“微信”更改。",
                         @"关闭后，当收到微信消息时，通知提示将不显示发信人和内容摘要。",
                         @"设置系统功能消息提示声音和振动的时段。",
                         @"当微信在运行时，你可以设置是否需要声音或者振动。",
                         @"关闭后，有朋友更新照片时，界面下面的“发现”切换按钮上不再出现红色提示"];
    
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
    
    isEnabledNotification = [LLUtils isEnabledNotification];
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
            case 0:
                cell.accessoryType_LL = kLLTableViewCellAccessoryText;
                cell.rightTextValue = isEnabledNotification ? @"已开启" : @"已关闭";
                break;
            case 1: {
                cell.accessoryType_LL = kLLTableViewCellAccessorySwitch;
                LLPushDisplayStyle style = [LLUserProfile myUserProfile].pushOptions.displayStyle;
                [cell setSwitchOn:(style == kLLPushDisplayStyleMessageSummary) animated:NO];
                break;
            }
            case 2:
                cell.accessoryType_LL = kLLTableViewCellAccessoryDisclosureIndicator;
                break;
            case 3: {
                cell.accessoryType_LL = kLLTableViewCellAccessorySwitch;
                if (indexPath.row == 0) {
                    BOOL isEnabledAlertSound = [LLUserProfile myUserProfile].pushOptions.isAlertSoundEnabled;
                    [cell setSwitchOn:isEnabledAlertSound animated:NO];
                }else if (indexPath.row == 1) {
                    BOOL isEnabledVibrate = [LLUserProfile myUserProfile].pushOptions.isVibrateEnabled;
                    [cell setSwitchOn:isEnabledVibrate animated:NO];
                }

                break;
            }
            case 4: {
                cell.accessoryType_LL = kLLTableViewCellAccessorySwitch;
                BOOL isEnabledMomentUpdate = [LLUserProfile myUserProfile].pushOptions.isMomentsUpdateEnabled;
                [cell setSwitchOn:isEnabledMomentUpdate animated:NO];
                break;
            }
            default:
                cell.accessoryType_LL = kLLTableViewCellAccessoryNone;
                break;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 2) {
        LLNoDisturbTableViewController *vc = [[LLNoDisturbTableViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - 

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.navigationController.childViewControllers containsObject:self]) {
        LLTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [LLUserProfile myUserProfile].pushOptions.displayStyle = cell.isSwitchOn ? kLLPushDisplayStyleMessageSummary : kLLPushDisplayStyleSimpleBanner;
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        [LLUserProfile myUserProfile].pushOptions.isAlertSoundEnabled = cell.isSwitchOn;
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]];
        [LLUserProfile myUserProfile].pushOptions.isVibrateEnabled = cell.isSwitchOn;
        
        [[LLClientManager sharedManager] savePushOptionsToServer];
        
    }
}

@end
