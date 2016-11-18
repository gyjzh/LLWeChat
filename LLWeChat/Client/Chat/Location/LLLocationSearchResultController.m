//
//  LLLocationSearchResultController.m
//  LLWeChat
//
//  Created by GYJZH on 8/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLLocationSearchResultController.h"
#import "LLUtils.h"
#import "LLColors.h"
#import "LLLocationTableViewCell.h"
#import "LLGDConfig.h"

#define Style_NoResult 0
#define Style_CanLoadMore 1
#define Style_isLoading 2
#define Style_LoadAll 3
#define Style_HintSearch 4

@interface LLLocationSearchResultController () <UITableViewDataSource, UITableViewDelegate, AMapSearchDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray<AMapPOI *> *allMapPOIs;

@property (nonatomic) UIView *noResultView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic) UIView *footerView;
@property (nonatomic) UILabel *footerLabel;
@property (nonatomic) UIActivityIndicatorView *footerIndicator;
@property (nonatomic) UIView *footerLoadingView;

@end

@implementation LLLocationSearchResultController {
    NSInteger curPage;
    AMapPOIKeywordsSearchRequest *request;
    NSString *originSearchText;
    NSInteger footerStyle;
    UIView *blankView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = kLLBackgroundColor_nearWhite;
    _tableView.separatorColor = kLLBackgroundColor_darkGray;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51;
    [self.view addSubview:_tableView];
    
    CALayer *line1 = [LLUtils lineWithLength:SCREEN_WIDTH atPoint:CGPointZero];
    line1.backgroundColor = kLLTextColor_lightGray_6.CGColor;
    [self.view.layer addSublayer:line1];
    
    UILabel *_noResultLabel = [[UILabel alloc] init];
    _noResultLabel.text = @"无结果";
    _noResultLabel.font = [UIFont boldSystemFontOfSize:20];
    _noResultLabel.textColor = kLLTextColor_grayBlack;
    [_noResultLabel sizeToFit];
    _noResultLabel.center = CGPointMake(SCREEN_WIDTH/2, 110);
    
    _noResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
    [_noResultView addSubview:_noResultLabel];
    
    [self setupFooterView];
    blankView = [[UIView alloc] init];
    _tableView.tableFooterView = blankView;
    
    curPage = 1;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.types               = (NSString *)allPOISearchTypes;
    request.requireExtension    = YES;
    request.cityLimit           = NO;
    request.requireSubPOIs      = YES;
    
    footerStyle = Style_NoResult;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    _tableView.frame = self.view.bounds;
}

- (void)setupFooterView {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _tableView.rowHeight)];
    _footerView.backgroundColor = _tableView.backgroundColor;
    CALayer *line1 = [LLUtils lineWithLength:SCREEN_WIDTH atPoint:CGPointZero];
    line1.backgroundColor = _tableView.separatorColor.CGColor;
    [_footerView.layer addSublayer:line1];
    
    CALayer *line2 = [LLUtils lineWithLength:SCREEN_WIDTH atPoint:CGPointMake(0, CGRectGetHeight(_footerView.frame)-0.5)];
    line2.backgroundColor = _tableView.separatorColor.CGColor;
    [_footerView.layer addSublayer:line2];

    _footerLabel = [[UILabel alloc] init];
    _footerLabel.font = [UIFont systemFontOfSize:16];
    _footerLabel.textColor = [UIColor blackColor];
    _footerLabel.textAlignment = NSTextAlignmentLeft;
    _footerLabel.text = @"加载更多";
    [_footerLabel sizeToFit];
    _footerLabel.center = CGPointMake(SCREEN_WIDTH/2, CGRectGetHeight(_footerView.frame)/2);
    [_footerView addSubview:_footerLabel];
    
    _footerLoadingView = [[UIView alloc] init];

    _footerIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_footerLoadingView addSubview:_footerIndicator];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"正在加载...";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = 25;
    frame.origin.y = (CGRectGetHeight(_footerIndicator.frame) - CGRectGetHeight(frame))/2;
    label.frame = frame;
    [_footerLoadingView addSubview:label];

    _footerLoadingView.frame = CGRectMake(0, 0, CGRectGetMaxX(label.frame), CGRectGetHeight(_footerIndicator.frame));
    _footerLoadingView.center = _footerLabel.center;
    [_footerView addSubview:_footerLoadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.search.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    originSearchText = nil;
    self.search.delegate = nil;
    [self.tableView setContentOffset:CGPointZero animated:NO];
    [self.allMapPOIs removeAllObjects];
    [self setFooterViewIsLoading:NO];
    self.tableView.tableFooterView = blankView;
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - 搜索

- (BOOL)shouldShowSearchResultControllerBeforePresentation {
    return NO;
}

- (BOOL)shouldHideSearchResultControllerWhenNoSearch {
    return YES;
}

- (void)searchCancelButtonDidTapped {
    
}

- (void (^)())animationForDismiss {    
    return ^() {
        self.view.alpha = 0;
    };
}

- (void (^)())animationForPresentation {
    self.view.alpha = 1;
    return nil;
}

//搜索发生错误时调用
- (void)AMapSearchRequest:(id)_request didFailWithError:(NSError *)error {
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [_request class], error);
}

//搜索成功回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)_request response:(AMapPOISearchResponse *)response {
    NSLog(@"搜索结果返回: %ld %ld", (long)_request.offset, (unsigned long)response.pois.count);
    
    if (response.pois.count == 0) {
        curPage = _request.page;
        if (curPage == 1) {
            self.allMapPOIs = nil;
            [self setTableViewStyle:Style_NoResult];
        }else{
            [self setTableViewStyle:Style_LoadAll];
        }
        
    }else {
        curPage = _request.page;
        if (curPage == 1) {
            self.allMapPOIs = [response.pois mutableCopy];
            [self setTableViewStyle:Style_CanLoadMore];
        }else{
            [self.allMapPOIs addObjectsFromArray:response.pois];
            [self setTableViewStyle:Style_CanLoadMore];
        }
    }
    
}

- (void)searchTextDidChange:(NSString *)searchText {
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    curPage = 1;
    request.page = 1;
    
    if (searchText.length == 0) {
        self.allMapPOIs = nil;
        originSearchText = searchText;
        [self setTableViewStyle:Style_NoResult];
    }else {
        if ([searchText isEqualToString:originSearchText])
            return;

        if (originSearchText.length > 0 && [searchText containsString:originSearchText]) {
        }else {
            self.allMapPOIs = nil;
        }
        
        originSearchText = searchText;
        [self setTableViewStyle:Style_HintSearch];
        [self searchPoiByKeyword:searchText];
    }
}

- (void)searchButtonDidTapped:(NSString *)searchText {
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    curPage = 1;
    request.page = 1;
    self.allMapPOIs = nil;
    originSearchText = searchText;
    
    if (searchText.length == 0) {
        [self setTableViewStyle:Style_NoResult];
    }else {
        [self setTableViewStyle:Style_isLoading];
        [self searchPoiByKeyword:searchText];
    }
}

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword:(NSString *)keywords {
    request.keywords = keywords;
    
    [self.search cancelAllRequests];
    [self.search AMapPOIKeywordsSearch:request];
}

- (void)setTableViewStyle:(NSInteger)style {
    footerStyle = style;
    
    if (style == Style_NoResult) {
        _tableView.tableFooterView = _noResultView;
        [_tableView setContentOffset:CGPointZero animated:NO];
        [self setFooterViewIsLoading:NO];
    }else if (style == Style_isLoading) {
        _tableView.tableFooterView = _footerView;
        [self setFooterViewIsLoading:YES];
    }else if (style == Style_CanLoadMore) {
        _tableView.tableFooterView = _footerView;
        [self setFooterViewIsLoading:NO];
    }else if (style == Style_LoadAll) {
        _tableView.tableFooterView = blankView;
        [self setFooterViewIsLoading:NO];
    }else if (style == Style_HintSearch) {
        _tableView.tableFooterView = blankView;
        [self setFooterViewIsLoading:NO];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 加载更多
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((_tableView.tableFooterView == _footerView) && (![self footerViewisLoading]) &&(scrollView.contentOffset.y + scrollView.frame.size.height + 2 >= scrollView.contentSize.height)) {
        [self setFooterViewIsLoading:YES];
        [self fetchMorePOIData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchViewController dismissKeyboard];
}

//UITableView上拉刷新时，获取更多数据
- (void)fetchMorePOIData {
    if (curPage == request.page) {
        request.page = request.page + 1;
        [self.search AMapPOIKeywordsSearch:request];
    }
    
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allMapPOIs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ID1";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[LLLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }

    AMapPOI *model = self.allMapPOIs[indexPath.row];
    ((LLLocationTableViewCell *)cell).poiModel = model;
    cell.textLabel.attributedText = [self processString:model.name];
    cell.detailTextLabel.attributedText = [self processString:[self getAddressFromAMapPOI:model]];

    return cell;
}

- (NSMutableAttributedString *)processString:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, 0);
    NSInteger start = 0, end = 0;
    BOOL isMatch = NO;
    
    for (NSInteger i = 0, r = text.length; i <= r; i++) {
        range.location = i;
        range.length = 1;
        BOOL isOK = i < r && [originSearchText containsString:[text substringWithRange:range]];
        
        if (isOK) {
            if (!isMatch) {
                isMatch = YES;
                start = i;
                end = i;
            }else {
                end = i;
            }
        }else {
            if (isMatch) {
                isMatch = NO;
                range.location = start;
                range.length = i - start;
                [attributedString addAttribute:NSForegroundColorAttributeName value:kLLTextColor_darkGreen range:range];
            }
        }
        
    }
    
    
    return attributedString;
    
}

- (NSString *)getAddressFromAMapPOI:(AMapPOI *)poi {
    NSString *address;
    if ([poi.city isEqualToString:poi.province]) {
        address = [NSString stringWithFormat:@"%@%@", poi.city, poi.address];
    }else {
        address = [NSString stringWithFormat:@"%@%@%@", poi.province, poi.city, poi.address];
    }

    return address;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LLLocationTableViewCell *cell = (LLLocationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (cell.poiModel)
        [self.gaodeViewController didRowWithModelSelected:cell.poiModel];
}

- (void)setFooterViewIsLoading:(BOOL)isLoading {
    _footerLoadingView.hidden = !isLoading;
    _footerLabel.hidden = !_footerLoadingView.hidden;
    if (isLoading)
        [_footerIndicator startAnimating];
    else
        [_footerIndicator stopAnimating];
}

- (BOOL)footerViewisLoading {
    return !_footerLoadingView.hidden;
}



@end
