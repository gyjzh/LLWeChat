//
//  LLContactController.m
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactController.h"
#import "LLSearchBar.h"
#import "LLTableViewCell.h"
#import "LLSDK.h"
#import "LLUtils.h"
#import "LLColors.h"
#import "LLMainViewController.h"
#import "LLSearchBar.h"
#import "LLChatSearchController.h"
#import "LLSearchViewController.h"
#import "LLContactAddController.h"
#import "LLContactApplyController.h"

#define CONTACT_CELL_ID @"contactCellID"

@interface LLContactController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LLSearchControllerDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) LLSearchBar *searchBar;

@property (nonatomic) NSMutableArray<NSString *> *sectionTitles;
@property (nonatomic) NSMutableArray<NSMutableArray<LLContactModel *> *> *dataArray;
@property (nonatomic) NSMutableArray<LLContactModel *> *contactSource;

@property (nonatomic) UIView *tableHeaderView;

@end

@implementation LLContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"通讯录";    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contacts_add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriend:)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.rowHeight = 56;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.sectionIndexColor = kLLTextColor_Normal;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, MAIN_BOTTOM_TABBAR_HEIGHT, 0);
    
    [self.view addSubview:self.tableView];
    
    _searchBar = [LLSearchBar defaultSearchBarWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 14, SEARCH_TEXT_FIELD_HEIGHT + 16)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_searchBar.frame))];
    _tableHeaderView.backgroundColor = [UIColor clearColor];
    [_tableHeaderView addSubview:_searchBar];
    
    self.tableView.tableHeaderView = _tableHeaderView;

    self.sectionTitles = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];

    [self fetchData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactChangedNotification:) name:LLContactChangedNotification object:[LLContactManager sharedManager]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 好友 -

- (void)contactChangedNotification:(NSNotification *)notification {
    [self fetchData];
}

- (void)addFriend:(id)sender {
    LLContactAddController *vc = [[LLContactAddController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fetchData {
    WEAK_SELF;
    [[LLContactManager sharedManager] asynGetContactsFromServer:^(NSArray<LLContactModel *> *contacts) {
        [weakSelf processData:contacts];
    }];
}

- (void)processData:(NSArray<LLContactModel *> *)contacts {
    self.contactSource = [contacts mutableCopy];
    [self.dataArray removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"pinyinOfUserName" ascending:YES];
    
    //建立索引的核心, 返回27，是a－z和＃
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray<NSMutableArray<LLContactModel *> *> *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray<LLContactModel *> *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //按首字母分组
    for (LLContactModel *model in self.contactSource) {
        NSString *firstLetter = [LLUtils firstPinyinLetterOfString:model.userName];
        NSInteger section = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
        
        [sortedArray[section] addObject:model];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        [sortedArray[i] sortUsingDescriptors:@[descriptor]];
    }
    
    //去掉空的section
    for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
        NSArray *array = [sortedArray objectAtIndex:i];
        if ([array count] == 0) {
            [sortedArray removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    
    [self.dataArray addObjectsFromArray:sortedArray];
    [self.tableView reloadData];
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }else {
        return self.dataArray[section-1].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleContactList reuseIdentifier:CONTACT_CELL_ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"新的朋友";
            cell.imageView.image = [UIImage imageNamed:@"plugins_FriendNotify"];
        }else if (indexPath.row == 1) {
            cell.textLabel.text = @"群聊";
            cell.imageView.image = [UIImage imageNamed:@"add_friend_icon_addgroup"];
        }else if (indexPath.row == 2) {
            cell.textLabel.text = @"标签";
            cell.imageView.image = [UIImage imageNamed:@"Contact_icon_ContactTag"];
        }else if (indexPath.row == 3) {
            cell.textLabel.text = @"公众号";
            cell.imageView.image = [UIImage imageNamed:@"add_friend_icon_offical"];
        }
    }else {
        LLContactModel *userModel = self.dataArray[indexPath.section - 1][indexPath.row];
        cell.textLabel.text = userModel.userName;
        cell.imageView.image = userModel.avatarImage;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            LLContactApplyController *vc = [[LLContactApplyController alloc] init];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else {
        LLContactModel *model = self.dataArray[indexPath.section-1][indexPath.row];
        
        [[LLUtils appDelegate].mainViewController chatWithContact:model.userName];
       
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return TABLE_SECTION_HEIGHT_ZERO;
    else
        return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLE_SECTION_HEIGHT_ZERO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = self.tableView.backgroundColor;
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = kLLTextColor_lightGray_system;
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}

#pragma mark - Section Titles -

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - 搜索 -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    LLSearchViewController *vc = [LLSearchViewController sharedInstance];
//    vc.delegate = self;
//    LLChatSearchController *resultController = [[LLUtils mainStoryboard] instantiateViewControllerWithIdentifier:SB_CONVERSATION_SEARCH_VC_ID];
//    
//    vc.searchResultController = resultController;
//    resultController.searchViewController = vc;
//    [vc showInViewController:self fromSearchBar:self.searchBar];
    
    return NO;
}

- (void)willPresentSearchController:(LLSearchViewController *)searchController {
    
}

- (void)didPresentSearchController:(LLSearchViewController *)searchController {
    self.tableView.tableHeaderView = nil;
}

- (void)willDismissSearchController:(LLSearchViewController *)searchController {
    
    [UIView animateWithDuration:HIDE_ANIMATION_DURATION animations:^{
        _tableHeaderView.hidden = YES;
        self.tableView.tableHeaderView = _tableHeaderView;
    } completion:^(BOOL finished) {
        _tableHeaderView.hidden = NO;
    }];
    
}

@end
