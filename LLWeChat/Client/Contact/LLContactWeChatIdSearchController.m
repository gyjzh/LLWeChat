//
//  LLContactWeChatIdSearchController.m
//  LLWeChat
//
//  Created by GYJZH on 15/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactWeChatIdSearchController.h"
#import "LLSearchBar.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLContactAddController.h"
#import "LLTableViewCellData.h"
#import "LLTableViewCell.h"
#import "LLUserProfile.h"
#import "LLContactManager.h"

@interface LLContactWeChatIdSearchController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) LLSearchBar *searchBar;

@property (nonatomic) LLTableViewCellData *cellData;

@end

@implementation LLContactWeChatIdSearchController {
//    BOOL navigationBarTranslucent;
    BOOL isSearching;
    BOOL shouldBecomeFirstResponder;
    id<UIGestureRecognizerDelegate> popGestureDelegate;
    UINavigationController *navigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouldBecomeFirstResponder = YES;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    NSInteger _barHeight = [LLSearchBar defaultSearchBarHeight];
    self.searchBar = [LLSearchBar defaultSearchBarWithFrame:CGRectMake(0, 64 - _barHeight, SCREEN_WIDTH, _barHeight)];
    self.searchBar.placeholder = @"微信号/手机号";
    self.searchBar.delegate = self;
    
    barView.backgroundColor = self.searchBar.barTintColor;
    [barView addSubview:self.searchBar];
    [self.view addSubview:barView];
    
    self.view.backgroundColor = kLLBackgroundColor_darkGray;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.rowHeight = 56;
    self.tableView.preservesSuperviewLayoutMargins = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *tap = [self.view addTapGestureRecognizer:@selector(tapHandler:) target:self];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    
    self.cellData = [[LLTableViewCellData alloc] initWithTitle:nil iconName:@"add_friend_icon_search"];
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
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (shouldBecomeFirstResponder) {
        navigationController = self.navigationController;
        popGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    }
    
    [UIView setAnimationsEnabled:NO];
    if (shouldBecomeFirstResponder) {
        shouldBecomeFirstResponder = NO;
        [self.searchBar becomeFirstResponder];
    }
    
    [self.searchBar setShowsCancelButton:YES animated:NO];
    [UIView setAnimationsEnabled:YES];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    navigationController.interactivePopGestureRecognizer.delegate = popGestureDelegate;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = popGestureDelegate;
}

- (void)dismissToExit {
    UIViewController *vc = (UIViewController *)[[self.fromControllerClass alloc] init];
        
    NSMutableArray<UIViewController *> *childViewControllers = [self.navigationController.childViewControllers mutableCopy];
    [childViewControllers replaceObjectAtIndex:childViewControllers.count - 1 withObject:vc];
    
    [self.navigationController setViewControllers:childViewControllers animated:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")]) {
        return self.searchBar.text.length > 0 && !self.searchBar.isFirstResponder;
    }else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return self.searchBar.text.length == 0;
    }
    
    return YES;
}

#pragma mark - Table View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellData.title ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ID";
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleDefault reuseIdentifier:nil];
        cell.imageView.layer.cornerRadius = 6;
        cell.textLabel.textColor = kLLTextColor_darkGreen;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    
    LLTableViewCellData *data = self.cellData;
    cell.imageView.image = data.icon;
    NSMutableAttributedString *searchStr = [[NSMutableAttributedString alloc] initWithString:data.title];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"搜索: " attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                    NSFontAttributeName:[UIFont boldSystemFontOfSize:15]                                                                             }];
    [searchStr insertAttributedString:str atIndex:0];
    
    cell.textLabel.attributedText = searchStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (!isSearching) {
        [self searchContactByChatIdOrPhoneNumber:_cellData.title];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tapHandler:nil];
}

#pragma mark - Search Delegete - 

- (void)tapHandler:(id)sender {
    if (self.tableView.hidden) {
        [self dismissToExit];
    }else {
        [self.searchBar resignFirstResponderWithCancelButtonRemainEnabled];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissToExit];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        _cellData.title = nil;
        self.tableView.hidden = YES;
    }else {
        self.tableView.hidden = NO;
        self.cellData.title = searchBar.text;
        [self.tableView reloadData];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!isSearching) {
        [self searchContactByChatIdOrPhoneNumber:searchBar.text];
    }
}


#pragma mark - 搜索 -

//FIXME:此处只进行非常非常基础的判断
- (void)searchContactByChatIdOrPhoneNumber:(NSString *)chatId {
    isSearching = YES;
    [self.searchBar resignFirstResponderWithCancelButtonRemainEnabled];
    
    NSString *buddyName = _searchBar.text;
    NSString *loginUsername = [[LLUserProfile myUserProfile] userName];
    if ([buddyName isEqualToString:loginUsername]) {
        [LLUtils showMessageAlertWithTitle:nil message:@"你不能添加自己到通讯录"];
        
        isSearching = NO;
        return;
    }
    
    NSArray<LLContactModel *> *userlist = [[LLContactManager sharedManager] getContactsFromDB];
    for (LLContactModel *userModel in userlist) {
        if ([buddyName isEqualToString:userModel.userName]){
            [LLUtils showMessageAlertWithTitle:nil message:@"联系人已存在"];

            isSearching = NO;
            return;
        }
    }
    MBProgressHUD *HUD = [LLUtils showActivityIndicatiorHUDWithTitle:@"正在发送请求..."];
    LLSDKError *error = [[LLContactManager sharedManager] addContact:buddyName];
    [LLUtils hideHUD:HUD animated:YES];
    if (error) {
        [LLUtils showMessageAlertWithTitle:nil message:@"发送请求失败"];
    }else {
        [LLUtils showMessageAlertWithTitle:nil message:@"发送请求成功" actionTitle:@"确定" actionHandler:^{
            [self dismissToExit];
        }];

    }

}

@end
