//
//  LLContactApplyController.m
//  LLWeChat
//
//  Created by GYJZH on 16/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactApplyController.h"
#import "LLSearchBar.h"
#import "UIKit+LLExt.h"
#import "LLUtils.h"
#import "LLContactAddController.h"
#import "LLContactWeChatIdSearchController.h"
#import "LLUserProfile.h"
#import "InvitationManager.h"
#import "LLTableViewCell.h"
#import "LLContactManager.h"

static NSString *ID = @"ID";

@interface LLContactApplyController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) LLSearchBar *searchBar;

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableArray *dataSource;

@end

@implementation LLContactApplyController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TABLE_VIEW_GROUP_BACKGROUNDCOLOR;;
    
    self.title = @"新的朋友";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"添加朋友" style:UIBarButtonItemStylePlain target:self action:@selector(addFriendHandler:)];
    self.navigationItem.rightBarButtonItem = item;
    
    NSInteger _barHeight = [LLSearchBar defaultSearchBarHeight];
    self.searchBar = [LLSearchBar defaultSearchBarWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _barHeight)];
    self.searchBar.placeholder = @"微信号/手机号";
    self.searchBar.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    NSInteger _viewHeight = SCREEN_HEIGHT;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0,-_viewHeight, SCREEN_WIDTH, _viewHeight)];
    barView.backgroundColor = self.searchBar.barTintColor;
    [self.tableView addSubview:barView];

    self.dataSource = [NSMutableArray array];
    [self loadDataSourceFromLocalDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:self.navigationController.navigationBarHidden animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelectorOnMainThread:@selector(showNavigationBarAnimated) withObject:nil waitUntilDone:NO];
}

- (void)showNavigationBarAnimated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)addFriendHandler:(id)sender {
    LLContactAddController *vc = [[LLContactAddController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"接受" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setBackgroundImage:[UIImage imageWithColor:kLLTextColor_darkGreen] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 50, 30);
        [btn addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = btn;
    }
    
    ApplyEntity *entity = self.dataSource[indexPath.row];
    cell.textLabel.text = entity.applicantUsername;
    cell.accessoryView.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSString *loginUsername = [LLUserProfile myUserProfile].userName;
        ApplyEntity *entity = self.dataSource[indexPath.row];
        
        [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
        [self.dataSource removeObject:entity];
        [self.tableView reloadData];
        
    }];
    
    return @[deleteAction];
}

#pragma mark - SearchBar -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf presentChatIdSearchController];
    });
    
    return NO;
}

- (void)presentChatIdSearchController {
    LLContactWeChatIdSearchController *vc = [[LLContactWeChatIdSearchController alloc] init];
    vc.fromControllerClass = self.class;
    
    NSMutableArray<UIViewController *> *childViewControllers = [self.navigationController.childViewControllers mutableCopy];
    [childViewControllers replaceObjectAtIndex:childViewControllers.count - 1 withObject:vc];
    
    [self.navigationController setViewControllers:childViewControllers animated:NO];
}

#pragma mark - 好友申请 -

- (void)loadDataSourceFromLocalDB {
    [_dataSource removeAllObjects];
    NSString *loginName = [LLUserProfile myUserProfile].userName;
    if(loginName && [loginName length] > 0) {
        NSArray * applyArray = [[InvitationManager sharedInstance] applyEmtitiesWithloginUser:loginName];
        [self.dataSource addObjectsFromArray:applyArray];
        
        [self.tableView reloadData];
    }
}

- (void)acceptFriend:(UIButton *)sender {
    ApplyEntity *entity = self.dataSource[sender.tag];
    [[LLContactManager sharedManager] acceptInvitationWithApplyEntity:entity completeCallback:^(LLSDKError * _Nonnull error) {
        if (!error) {
            [self.dataSource removeObject:entity];
            [self.tableView reloadData];
        }
    }];
    
}

@end
