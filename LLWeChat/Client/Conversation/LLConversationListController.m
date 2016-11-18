//
//  LLConversationListController.m
//  LLWeChat
//
//  Created by GYJZH on 7/19/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLConversationListController.h"
#import "LLChatManager.h"
#import "LLConversationModel.h"
#import "EMClient.h"
#import "LLConversationListCell.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import "LLChatViewController.h"
#import "LLSearchBar.h"
#import "UIKit+LLExt.h"
#import "LLSearchViewController.h"
#import "LLSearchControllerDelegate.h"
#import "LLChatSearchController.h"
#import "LLWebViewController.h"
#import "LLNavigationController.h"
#import "LLMessageCellManager.h"
#import "LLMessageModelManager.h"

#define TABLE_CELL_HEIGHT 68

#define TABLE_CELL_ID @"CELL_ID"

@interface LLConversationListController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, LLChatManagerConversationListDelegate, UISearchBarDelegate, LLSearchControllerDelegate>

@property (nonatomic) NSMutableArray<LLConversationModel *> *allConversationModels;

@property (nonatomic) UIView *connectionAlertView;

@property (nonatomic) UITableView *tableView;

@property (nonatomic) LLSearchBar *searchBar;

@property (nonatomic) UIView *tableHeaderView;

@end

@implementation LLConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"微信";
    
    UIBarButtonItem *plusItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                 action:@selector(plusButtonHandler:)];
    
    self.navigationItem.rightBarButtonItem = plusItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.rowHeight = TABLE_CELL_HEIGHT;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, MAIN_BOTTOM_TABBAR_HEIGHT, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LLConversationListCell" bundle:nil] forCellReuseIdentifier:TABLE_CELL_ID];
    
    _searchBar = [LLSearchBar defaultSearchBarWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCH_TEXT_FIELD_HEIGHT + 16)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_searchBar.frame))];
    _tableHeaderView.backgroundColor = [UIColor clearColor];
    [_tableHeaderView addSubview:_searchBar];
    
    self.tableView.tableHeaderView = _tableHeaderView;
    
    NSInteger _viewHeight = SCREEN_HEIGHT;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0,-_viewHeight, SCREEN_WIDTH, _viewHeight)];
    barView.backgroundColor = self.searchBar.barTintColor;
    [self.tableView addSubview:barView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStateChanged:) name:LLConnectionStateDidChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCompleteHandler:) name:LLMessageUploadStatusChangedNotification object:nil];
    
    //fetch data
    [self fetchData];
}

- (UIView *)connectionAlertView {
    if (!_connectionAlertView) {
        _connectionAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
        _connectionAlertView.backgroundColor = UIColorRGB(255, 223, 224);
        
        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connect_alert_error"]];
        alertView.frame = CGRectMake(20, (CGRectGetHeight(_connectionAlertView.frame) - 28)/2, 28, 28);
        [_connectionAlertView addSubview:alertView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(alertView.frame) + 12, 0, 300, 45)];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"当前网络不可用，请检查你的网络设置";
        [_connectionAlertView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotConnectWebView:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_connectionAlertView addGestureRecognizer:tap];
        
    }
    
    return _connectionAlertView;
}

- (void)uploadCompleteHandler:(NSNotification *)notification {
    LLMessageModel *messageModel = notification.userInfo[LLChatManagerMessageModelKey];
    if (!messageModel)
        return;
    
    WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf refreshTableRowWithConversationId:messageModel.conversationId];
    });
    
}

- (void)refreshTableRowWithConversationModel:(LLConversationModel *)conversationModel {
    for (LLConversationListCell *cell in self.tableView.visibleCells) {
        if ([cell.conversationModel.conversationId isEqualToString:conversationModel.conversationId]) {
            cell.conversationModel = conversationModel;
            break;
        }
    }
}

- (void)refreshTableRowWithConversationId:(NSString *)conversationId {
    for (LLConversationListCell *cell in self.tableView.visibleCells) {
        if ([cell.conversationModel.conversationId isEqualToString:conversationId]) {
            cell.conversationModel = cell.conversationModel;
            break;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 获取会话数据

- (void)fetchData {
    [LLChatManager sharedManager].conversationListDelegate = self;
    [[LLChatManager sharedManager] getAllConversationFromDB];
}

- (void)conversationListDidChanged:(NSArray<LLConversationModel *> *)conversationList {
    self.allConversationModels = [conversationList mutableCopy];
    [self.tableView reloadData];
    [self setUnreadMessageCount];
}

- (NSMutableArray<LLConversationModel *> *)currentConversationList {
    return [self.allConversationModels mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView reloadData];
}

- (void)unreadMessageNumberDidChanged {
    [self setUnreadMessageCount];
}


- (void)setUnreadMessageCount {
    NSInteger count = 0;
    for (LLConversationModel *data in self.allConversationModels) {
        count += data.unreadMessageNumber;
    }
    
    [[LLUtils appDelegate].mainViewController setTabbarBadgeValue:count tabbarIndex:kLLMainTabbarIndexChat];
    
    self.navigationItem.title = count > 0 ? [NSString stringWithFormat:@"微信(%ld)", (long)count] : @"微信";
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allConversationModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_CELL_ID forIndexPath:indexPath];
    
    cell.conversationModel = self.allConversationModels[indexPath.row];
    
    return cell;
}


#pragma mark - 左滑显示删除和已读

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLConversationListCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        BOOL result = [[LLChatManager sharedManager] deleteConversation:cell.conversationModel];
        if (result) {
            [self.allConversationModels removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
            [self setUnreadMessageCount];
        }

    }];

    UITableViewRowAction *setReadAction;
    if (cell.conversationModel.unreadMessageNumber > 0) {
        setReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标为已读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [cell markAllMessageAsRead];
            [self setUnreadMessageCount];
            [tableView setEditing:NO animated:YES];
        }];
    }else {
        setReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标为未读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [cell markMessageAsNotRead];
            [self setUnreadMessageCount];
            [tableView setEditing:NO animated:YES];
        }];
    }

                                          
    return @[deleteAction, setReadAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLConversationListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[LLUtils appDelegate].mainViewController chatWithConversationModel:cell.conversationModel];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)connectionStateChanged:(NSNotification*)notification {
    BOOL isConnected = [notification.userInfo[@"connectionState"] integerValue] == kLLConnectionStateConnected;
    
    if (!isConnected) {
        self.navigationItem.title = @"微信(未连接)";
        [self.tableHeaderView addSubview:self.connectionAlertView];
    }else {
        self.navigationItem.title = @"微信";
        [self.connectionAlertView removeFromSuperview];
    }
    
    [self adjustTableHeaderView];
}

//TableHeaderView 从上至下，依次为SearchBar、connectionAlertView、电脑端登录等
- (void)adjustTableHeaderView {
    CGFloat maxHeight = CGRectGetHeight(self.searchBar.frame);
    if (self.connectionAlertView.superview == _tableHeaderView) {
        self.connectionAlertView.top_LL = maxHeight;
        [self.tableHeaderView addSubview:self.connectionAlertView];
        
        maxHeight = CGRectGetMaxY(self.connectionAlertView.frame);
    }
    
    self.tableHeaderView.height_LL = maxHeight;
    
    [self.tableView setTableHeaderView:self.tableHeaderView];
}


#pragma mark - 搜索 -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {    
    LLSearchViewController *vc = [LLSearchViewController sharedInstance];
    LLNavigationController *navigationVC = [[LLNavigationController alloc] initWithRootViewController:vc];
    navigationVC.view.backgroundColor = [UIColor clearColor];
    vc.delegate = self;
    LLChatSearchController *resultController = [[LLUtils mainStoryboard] instantiateViewControllerWithIdentifier:SB_CONVERSATION_SEARCH_VC_ID];
    
    vc.searchResultController = resultController;
    resultController.searchViewController = vc;
    [vc showInViewController:self fromSearchBar:self.searchBar];
    
    return NO;
}

- (void)willPresentSearchController:(LLSearchViewController *)searchController {
    
}

- (void)didPresentSearchController:(LLSearchViewController *)searchController {
    self.tableView.tableHeaderView = nil;
    CGRect frame = _tableHeaderView.frame;
    frame.origin.y = -frame.size.height;
    _tableHeaderView.frame = frame;
}

- (void)willDismissSearchController:(LLSearchViewController *)searchController {
    
    [UIView animateWithDuration:HIDE_ANIMATION_DURATION animations:^{
        _searchBar.hidden = YES;
      self.tableView.tableHeaderView = _tableHeaderView;
    } completion:^(BOOL finished) {
        _searchBar.hidden = NO;
    }];
    
}

- (void)didDismissSearchController:(LLSearchViewController *)searchController {
//    _connectionAlertView.alpha = 0;
//    for (UITableViewCell *cell in self.tableView.visibleCells) {
//        cell.alpha = 0;
//    }
//    [UIView animateWithDuration:0.25 animations:^{
//        _connectionAlertView.alpha = 1;
//        for (UITableViewCell *cell in self.tableView.visibleCells) {
//            cell.alpha = 1;
//        }
//    }];
}


#pragma mark - 其他 -

- (void)showNotConnectWebView:(UITapGestureRecognizer *)tap {
    LLWebViewController *vc = [[LLWebViewController alloc] init];
    vc.title = @"未能连接到互联网";
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"network_setting" ofType:@"html"];
    vc.url = [NSURL fileURLWithPath:htmlPath];
    vc.fromViewController = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)plusButtonHandler:(UIBarButtonItem *)item {
    [self presentImagePickerController];
}

- (void)presentImagePickerController {
   
}



@end
