//
//  LLContactAddController.m
//  LLWeChat
//
//  Created by GYJZH on 15/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactAddController.h"
#import "LLUtils.h"
#import "LLTableViewCellData.h"
#import "LLTableViewCell.h"
#import "LLContactWeChatIdSearchController.h"

#define TABLE_HEADER_HEIGHT 122

@interface LLContactAddController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray<LLTableViewCellData *> *dataSource;

@end

@implementation LLContactAddController {
    //FIXME:
//    BOOL navigationBarTranslucent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TABLE_VIEW_GROUP_BACKGROUNDCOLOR;
    self.title = @"添加朋友";
    
    self.dataSource = @[
        [[LLTableViewCellData alloc] initWithTitle:@"雷达加朋友" subTitle:@"添加身边的朋友" iconName:@"add_friend_icon_reda"],
        [[LLTableViewCellData alloc] initWithTitle:@"面对面建群" subTitle:@"与身边的朋友进入同一个群聊" iconName:@"add_friend_icon_addgroup"],
        [[LLTableViewCellData alloc] initWithTitle:@"扫一扫" subTitle:@"扫描二维码名片" iconName:@"add_friend_icon_scanqr"],
        [[LLTableViewCellData alloc] initWithTitle:@"手机联系人" subTitle:@"添加通讯录中的朋友" iconName:@"add_friend_icon_contacts"],
        [[LLTableViewCellData alloc] initWithTitle:@"公众号" subTitle:@"获取更多资讯和服务" iconName:@"add_friend_icon_offical"]
    ];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.rowHeight = 60;
    self.tableView.preservesSuperviewLayoutMargins = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 13, 0, 0);
    
    self.tableView.tableHeaderView = [self tableHeaderView];
    [self.view addSubview:self.tableView];

}

- (UIView *)tableHeaderView {
    UIView *header = [[NSBundle mainBundle] loadNibNamed:@"LLContactSearchViews" owner:self options:nil][0];
    
    return header;
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

    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:self.navigationController.navigationBarHidden animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelectorOnMainThread:@selector(showNavigationBarAnimated) withObject:nil waitUntilDone:NO];
    
}

- (void)showNavigationBarAnimated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table View - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ID";
    
    LLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [LLTableViewCell cellWithStyle:kLLTableViewCellStyleContactSearchList reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    LLTableViewCellData *itemData = self.dataSource[indexPath.row];
    
    cell.textLabel.text = itemData.title;
    cell.detailTextLabel.text = itemData.subTitle;
    cell.imageView.image = itemData.icon;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - 搜索 -

- (IBAction)tapHandler:(UITapGestureRecognizer *)tap {
    LLContactWeChatIdSearchController *vc = [[LLContactWeChatIdSearchController alloc] init];
    vc.fromControllerClass = self.class;
    
    NSMutableArray<UIViewController *> *childViewControllers = [self.navigationController.childViewControllers mutableCopy];
    [childViewControllers replaceObjectAtIndex:childViewControllers.count - 1 withObject:vc];
    
    [self.navigationController setViewControllers:childViewControllers animated:NO];
}


@end
