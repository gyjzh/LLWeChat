//
//  LLChatSearchController.m
//  LLWeChat
//
//  Created by GYJZH on 9/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatSearchController.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "UIKit+LLExt.h"
#import "LLSNSSearchController.h"
#import "LLArticleSearchController.h"
#import "LLBrandContactSearchController.h"
#import "LLMessageSearchResultCell.h"
#import "LLChatManager.h"
#import "LLMessageSearchResultModel.h"
#import "LLSearchResultTableController.h"

#define CELL_REUSE_ID @"Cell_Reuse_Id"

#define TABLE_CELL_HEIGHT 68

typedef NS_ENUM(NSInteger, LLSubSearchIndex) {
    kLLSubSearchIndexSNS = 0,
    kLLSubSearchIndexArticle,
    kLLSubSearchIndexBrandContact
};

@interface LLChatSearchController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *snsView;

@property (weak, nonatomic) IBOutlet UIView *articleView;

@property (weak, nonatomic) IBOutlet UIView *brandcontactView;

//@property (nonatomic) UINavigationController *navigationController;

@property (nonatomic) UIButton *backButton;

@property (nonatomic) LLSearchBar *searchBar;
@property (nonatomic) BOOL isTransitioning;

@property (nonatomic) UIViewController *subSearchController;

@property (nonatomic) UIView *searchResultView;
@property (nonatomic) UILabel *searchResultLabel;
@property (nonatomic) UITableView *chatHistoryTableView;

@property (nonatomic) NSArray<NSArray<LLMessageSearchResultModel *> *> *searchResultArray;

@property (nonatomic, copy) NSString *searchText;

@end

@implementation LLChatSearchController {
    CGFloat searchBarMinWidth;
    UIColor *searchBarBackgroundColor;
    UIColor *searchBarTintColor;
    CGSize searchBarLeftViewSize;
    UIView *blockView;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGB(233, 233, 233);
    
    [self setButtonsAlpha:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePanHandler:)];
    pan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:pan];
    
    blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    blockView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    blockView.userInteractionEnabled = YES;
    blockView.backgroundColor = [UIColor clearColor];
    
    _searchResultView = [[UIView alloc] initWithFrame:self.view.bounds];
    _searchResultView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_searchResultView];
    _searchResultView.hidden = YES;
    
    _searchResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 46, SCREEN_WIDTH - 40, 67)];
    _searchResultLabel.font = [UIFont systemFontOfSize:15];
    _searchResultLabel.textColor = kLLTextColor_lightGray_system;
    _searchResultLabel.textAlignment = NSTextAlignmentCenter;
    _searchResultLabel.numberOfLines = 10;
    _searchResultLabel.backgroundColor = [UIColor clearColor];
    _searchResultLabel.text = @"没有找到";
    [_searchResultView addSubview:_searchResultLabel];
    
    self.chatHistoryTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _chatHistoryTableView.rowHeight = TABLE_CELL_HEIGHT;
    _chatHistoryTableView.delegate = self;
    _chatHistoryTableView.dataSource = self;
    _chatHistoryTableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);
    _chatHistoryTableView.tableFooterView = [[UIView alloc] init];
    _chatHistoryTableView.hidden = YES;
    _chatHistoryTableView.backgroundColor = [UIColor whiteColor];
    _chatHistoryTableView.tableHeaderView = [self tableHeaderView];
    [_searchResultView addSubview:_chatHistoryTableView];
    
    [self.chatHistoryTableView registerNib:[UINib nibWithNibName:@"LLMessageSearchResultCell" bundle:nil] forCellReuseIdentifier:CELL_REUSE_ID];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _searchResultView.frame = self.view.bounds;
    _chatHistoryTableView.frame = _searchResultView.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _searchBar = self.searchViewController.searchBar;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    if (self.searchResultView.hidden)
        [self.searchViewController dismissKeyboard];
}

- (void)screenEdgePanHandler:(UIPanGestureRecognizer *)pan {
    if (!self.subSearchController)
        return;
    
    CGFloat x = [pan translationInView:self.view.window].x;
    CGFloat progress = x / SCREEN_WIDTH;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self.searchViewController dismissKeyboard];
            [self.view.window addSubview:blockView];
            [self setBackTransitionProgress:0 duration:0];
            break;
        case UIGestureRecognizerStateChanged:
            [self setBackTransitionProgress:progress duration:0];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self backTransitionEnded:[pan velocityInView:self.view.window]];
            break;
        default:
            break;
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat btnWidth = CGRectGetWidth(self.snsView.frame);
    CGFloat gap = (SCREEN_WIDTH - 3 * btnWidth) / 10;
    self.snsView.left_LL = gap * 2;
    self.articleView.left_LL = 5 * gap + btnWidth;
    self.brandcontactView.left_LL = SCREEN_WIDTH - 2 *gap - btnWidth;
}


#pragma mark - 搜索 -

- (void)searchWithText:(NSString *)searchText {
    if (![self.searchBar.placeholder isEqualToString:@"搜索"]) {
        return;
    }
    
    if (searchText.length == 0) {
        self.searchText = nil;
        self.searchResultArray = nil;
        self.searchResultView.hidden = YES;
        [self.chatHistoryTableView reloadData];
    }else {
        searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.searchText = searchText;
        self.searchResultView.hidden = NO;
        
        if (searchText.length > 0) {
            self.searchResultLabel.hidden = NO;
            self.searchResultArray = [[LLChatManager sharedManager] searchChatHistoryWithKeyword:searchText];
            
            if (self.searchResultArray.count == 0) {
                NSString *string = [NSString stringWithFormat:@"没有找到\"%@\"相关的聊天记录", searchText];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
                [attributeString addAttribute:NSForegroundColorAttributeName value:kLLTextColor_green range:[string rangeOfString:searchText]];
                
                CGRect frame = _searchResultLabel.frame;
                frame.size.height = [LLUtils boundingSizeForText:string maxWidth:CGRectGetWidth(frame) font:_searchResultLabel.font lineSpacing:0].height;
                _searchResultLabel.frame = frame;
                
                self.searchResultLabel.attributedText = attributeString;
                self.chatHistoryTableView.hidden = YES;
            }else {
                self.chatHistoryTableView.hidden = NO;
            }
        }else {
            self.searchResultLabel.hidden = YES;
            self.searchResultArray = nil;
            self.chatHistoryTableView.hidden = YES;
        }
        
        [self.chatHistoryTableView reloadData];
    }
}

- (void)searchTextDidChange:(NSString *)searchText {
    [self searchWithText:searchText];
}

- (void)searchButtonDidTapped:(NSString *)searchText {
    [self searchWithText:searchText];
}

- (BOOL)shouldShowSearchResultControllerBeforePresentation {
    return YES;
}

- (BOOL)shouldHideSearchResultControllerWhenNoSearch {
    return NO;
}

- (void)setButtonsAlpha:(CGFloat)alpha {
    self.snsView.alpha = alpha;
    self.articleView.alpha = alpha;
    self.brandcontactView.alpha = alpha;
}

- (void (^)())animationForPresentation {
    
    return ^() {
        [self setButtonsAlpha:1];
    };
}

- (void (^)())animationForDismiss {
    self.snsView.hidden = YES;
    self.articleView.hidden = YES;
    self.brandcontactView.hidden = YES;
    
    CGRect frame = self.view.frame;
    frame.size.height -= MAIN_BOTTOM_TABBAR_HEIGHT;
    self.view.frame = frame;
    
    return ^() {
        if (!self.searchResultView.hidden) {
            self.searchResultView.alpha = 0;
        }else {
            self.view.backgroundColor = [UIColor clearColor];
        }

    };
}

#pragma mark - 手势返回动画 -

- (void)setBackTransitionProgress:(CGFloat)progress duration:(CGFloat)duration {

    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews |
                                UIViewAnimationCurveEaseInOut
                     animations:^{
                         CGRect frame = self.subSearchController.view.frame;
                         frame.origin.x = progress * SCREEN_WIDTH;
                         self.subSearchController.view.frame = frame;
                         
                         frame = self.searchBar.frame;
                         frame.size.width = searchBarMinWidth + (SCREEN_WIDTH - searchBarMinWidth) *progress;
                         frame.origin.x = SCREEN_WIDTH - frame.size.width;
                         self.searchBar.frame = frame;
                         
                         frame = self.searchBar.searchTextField.leftView.frame;
                         frame.size = searchBarLeftViewSize;
                         self.searchBar.searchTextField.leftView.frame = frame;
                         
                         self.backButton.alpha = 1 - progress;
                     }
                     completion:^(BOOL finished) {
                         if (progress == 1) {
                             [self backTransitionComplete];
                         }
                         if (duration > 0 && (progress == 0 || progress == 1)){
                             [blockView removeFromSuperview];
                         }
                     }];
    
    
}

- (void)backTransitionEnded:(CGPoint)velocity {
    CGFloat _x = self.subSearchController.view.frame.origin.x;
    CGFloat _t;
    CGFloat progress;
    CGFloat factor = 1.1;
    if (fabs(velocity.x) < SCREEN_WIDTH * 2) {
        progress = (2 * _x >= SCREEN_WIDTH) ? 1 : 0;
        _t = 0.25;
    }else if (velocity.x < 0) {
        progress = 0;
        _t = fabs(_x / velocity.x) * factor;
    }else {
        progress = 1;
        _t = (SCREEN_WIDTH - _x) / velocity.x * factor;
    }

    if (_t > 0.25)
        _t = 0.25;
    else if (_t < 0.1)
        _t = 0.1;
    
    [self setBackTransitionProgress:progress duration:_t];

}


- (void)backTransitionComplete {
    self.backButton.alpha = 1;
    [self.backButton removeFromSuperview];
    [self.subSearchController.view removeFromSuperview];
    [self.subSearchController removeFromParentViewController];
    self.subSearchController = nil;
    [_searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    _searchBar.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchBar.placeholder = @"搜索";
    _searchBar.text = nil;
    _searchBar.tintColor = searchBarTintColor;
    _searchBar.backgroundColor = searchBarBackgroundColor;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchViewController dismissKeyboard];
}

#pragma mark - 分类搜索 -

//- (UINavigationController *)navigationController {
//    if (!_navigationController) {
//        _navigationController = [[UINavigationController alloc] init];
//    }
//    
//    return _navigationController;
//}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"barbuttonicon_back"];
        [_backButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor lightGrayColor];
        [_backButton sizeToFit];
        CGRect frame = _backButton.frame;
        frame.size.height += 13 * 2;
        frame.size.width += 12 * 2;
        frame.origin.y = 63;
        _backButton.frame = frame;
        [_backButton addTarget:self action:@selector(backHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backButton;
}


- (void)showSubSearchController:(LLSubSearchIndex)index {
    LLSearchBar *searchBar =  self.searchViewController.searchBar;
    NSString *searchIconName;
    NSString *placeholder;
    switch (index) {
        case kLLSubSearchIndexSNS:
            placeholder = @"搜索朋友圈";
            searchIconName = @"fts_searchicon_sns";
            if (![self.subSearchController isKindOfClass:[LLSNSSearchController class]]) {
                self.subSearchController = [[LLSNSSearchController alloc] init];
            }
            break;
            
        case kLLSubSearchIndexArticle:
            placeholder = @"搜索文章";
            searchIconName = @"fts_searchicon_article";
            if (![self.subSearchController isKindOfClass:[LLArticleSearchController class]]) {
                self.subSearchController = [[LLArticleSearchController alloc] init];
            }
            break;
            
        case kLLSubSearchIndexBrandContact:
            placeholder = @"搜索公众号";
            searchIconName = @"fts_searchicon_brandcontact";
            if (![self.subSearchController isKindOfClass:[LLBrandContactSearchController class]]) {
                self.subSearchController = [[LLBrandContactSearchController alloc] init];
            }
            break;
    }
    
    searchBar.placeholder = placeholder;
    searchBarBackgroundColor = searchBar.backgroundColor;
    searchBarTintColor = searchBar.tintColor;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBarLeftViewSize = searchBar.searchTextField.leftView.frame.size;
    [searchBar setImage:[UIImage imageNamed:searchIconName] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    self.backButton.right_LL = 0;
    [searchBar.superview insertSubview:self.backButton belowSubview:searchBar];
    
    [self addChildViewController:self.subSearchController];
    self.subSearchController.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    [self.view addSubview:self.subSearchController.view];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews |
                                UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.backButton.left_LL = 0;
        
        CGRect frame = searchBar.frame;
        frame.origin.x = CGRectGetMaxX(self.backButton.frame) - 6;
        frame.size.width = SCREEN_WIDTH - frame.origin.x;
        searchBarMinWidth = frame.size.width;
        searchBar.frame = frame;
        
        _subSearchController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        [self setButtonsAlpha:0];
    }
                     completion:^(BOOL finished){
                         [self setButtonsAlpha:1];
                     }];
}

- (void)hideSubSearchController {
    LLSearchBar *searchBar =  self.searchViewController.searchBar;
    
    searchBar.placeholder = nil;
    searchBar.searchTextField.leftViewMode = UITextFieldViewModeNever;
    [searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBarTintColor = searchBar.tintColor;
    searchBar.tintColor = [UIColor clearColor];
    [searchBar becomeFirstResponder];
    
    [self setButtonsAlpha:0];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews |
                                UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.backButton.right_LL = 0;
        
        CGRect frame = searchBar.frame;
        frame.origin.x = 0;
        frame.size.width = SCREEN_WIDTH;
        searchBar.frame = frame;
        
        self.subSearchController.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
        [self setButtonsAlpha:1];

    } completion:^(BOOL finished) {
        [self backTransitionComplete];
            }];
}

- (void)backHandler:(id)sender {
    [self hideSubSearchController];
}

- (IBAction)snsButtonPressed:(id)sender {
    [self showSubSearchController:kLLSubSearchIndexSNS];
}


- (IBAction)articleButtonPressed:(id)sender {
    [self showSubSearchController:kLLSubSearchIndexArticle];
}


- (IBAction)brandcontactPressed:(id)sender {
    [self showSubSearchController:kLLSubSearchIndexBrandContact];
}

- (void)searchCancelButtonDidTapped {
    LLSearchBar *searchBar =  self.searchViewController.searchBar;
    if (_backButton.superview) {
        [_backButton removeFromSuperview];
    }
    
    if (_subSearchController) {
        [_subSearchController.view removeFromSuperview];
        [_subSearchController removeFromParentViewController];
        _subSearchController = nil;
    }
    
    CGRect frame = searchBar.frame;
    frame.origin.x = 0;
    frame.size.width = SCREEN_WIDTH;
    searchBar.frame = frame;
    
    searchBar.placeholder = @"搜索";
    searchBar.text = nil;
    [searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
}

#pragma mark - UITable View -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLMessageSearchResultCell *cell = (LLMessageSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    NSArray<LLMessageSearchResultModel *> *result = self.searchResultArray[indexPath.row];
    [cell setSearchResultModels:result showDate:NO];
    //最后一个Cell的Seperator
    if (indexPath.row == self.searchResultArray.count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (UIView *)tableHeaderView {
    CGFloat height = 40;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = self.chatHistoryTableView.backgroundColor;
    CALayer *line = [LLUtils lineWithLength:SCREEN_WIDTH - 14 atPoint:CGPointMake(14, height-1)];
    [view.layer addSublayer:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 18, SCREEN_WIDTH , 15)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = kLLTextColor_lightGray_system;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"聊天记录";
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LLMessageSearchResultCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //直接跳转到聊天界面
    if (cell.searchResultModels.count == 1) {
        
    //跳转到单个会话搜索结果界面
    }else if (cell.searchResultModels.count > 1) {
        LLSearchResultTableController *vc = [[LLSearchResultTableController alloc] init];
        vc.searchText = self.searchText;
        vc.searchResultModels = cell.searchResultModels;
        
        [self.searchViewController.navigationController pushViewController:vc animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
