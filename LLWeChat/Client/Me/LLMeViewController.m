//
//  LLMeViewController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMeViewController.h"
#import "LLTableViewMeCell.h"
#import "LLUserProfile.h"
#import "LLTableViewCellData.h"
#import "LLMeSettingController.h"
#import "LLUtils.h"
#import "LLTableViewCell.h"

@interface LLMeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray<NSArray<LLTableViewCellData *> *> *dataSource;

@end

@implementation LLMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"我　" style:UIBarButtonItemStylePlain target:nil
                   action:nil];    

    NSArray<LLTableViewCellData *> *section1 = @[
            [[LLTableViewCellData alloc] initWithTitle:@"相册" iconName:@"MoreMyAlbum"],
            [[LLTableViewCellData alloc] initWithTitle:@"收藏" iconName:@"MoreMyFavorites"],
            [[LLTableViewCellData alloc] initWithTitle:@"钱包" iconName:@"MoreMyBankCard"],
            [[LLTableViewCellData alloc] initWithTitle:@"卡包" iconName:@"MyCardPackageIcon"],
    ];
    
    NSArray<LLTableViewCellData *> *section2 = @[
            [[LLTableViewCellData alloc] initWithTitle:@"表情" iconName:@"MoreExpressionShops"],
    ];
    
    NSArray<LLTableViewCellData *> *section3 = @[
            [[LLTableViewCellData alloc] initWithTitle:@"设置" iconName:@"MoreSetting"],
    ];
    
    self.dataSource = @[section1, section2, section3];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, MAIN_BOTTOM_TABBAR_HEIGHT, 0);
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


#pragma mark - TableView Delegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return self.dataSource[section-1].count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 88;
    else
        return TABLE_VIEW_CELL_DEFAULT_HEIGHT;
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
    static NSString *MeID = @"MeInfoCell";
    
    if (indexPath.section == 0) {
        LLTableViewMeCell *cell = [tableView dequeueReusableCellWithIdentifier:MeID forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.avatarImage.image = [UIImage imageNamed:[LLUserProfile myUserProfile].avatarURL];
        cell.nickNameLabel.text = [LLUserProfile myUserProfile].nickName;
        cell.WeChatIDLabel.text = [NSString stringWithFormat:@"微信号: %@", [LLUserProfile myUserProfile].userName];
        
        return cell;
    }else {
        LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleDefault reuseIdentifier:ID];
        }
        LLTableViewCellData *itemData = self.dataSource[indexPath.section-1][indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = itemData.title;
        cell.imageView.image = itemData.icon;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 3) {
        LLMeSettingController  *settingVC = (LLMeSettingController *)[[LLUtils mainStoryboard] instantiateViewControllerWithIdentifier:@"MeSettingController"];
        settingVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:settingVC animated:YES];
    } 
}


@end
