//
//  LLLocationShowController.m
//  LLWeChat
//
//  Created by GYJZH on 8/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLLocationShowController.h"
#import "LLActionSheet.h"
#import "LLColors.h"
#import "LLUtils.h"
#import "LLLocationManager.h"
#import <MAMapKit/MAMapKit.h>

#define BOTTOM_BAR_HEIGHT 90

#define TAG_LOCATION_ME_NEAR 1
#define TAG_LOCATION_ME_FAR 2

@interface LLLocationShowController () <MAMapViewDelegate, AMapSearchDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) MAMapView *mapView;
@property (nonatomic) UILabel *topLabel;
@property (nonatomic) UILabel *bottomLabel;
@property (nonatomic) UIButton *locationBtn;
@property (nonatomic) MAAnnotationView *userLocationAnnotationView;

@property (nonatomic) AMapSearchAPI *search;

@property (nonatomic) BOOL locationPermissionGranted;

@end

@implementation LLLocationShowController {
    BOOL isBackToUserLocation;
    BOOL hasInitMapView;
    BOOL navigationBarTranslucent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.view.backgroundColor = [UIColor redColor];
    CGRect frame = SCREEN_FRAME;
    frame.size.height = SCREEN_HEIGHT - BOTTOM_BAR_HEIGHT;
    _mapView = [[MAMapView alloc] initWithFrame:frame];
    _mapView.delegate = self;
    _mapView.mapType = MAMapTypeStandard;
    _mapView.language = MAMapLanguageZhCN;
    
    _mapView.zoomEnabled = YES;
    _mapView.minZoomLevel = 4;
    _mapView.maxZoomLevel = 18;
    
    _mapView.scrollEnabled = YES;
    _mapView.showsCompass = NO;
    
    _mapView.logoCenter = CGPointMake(SCREEN_WIDTH - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2);
    
    _mapView.showsScale = YES;
    _mapView.scaleOrigin = CGPointMake(12, CGRectGetHeight(_mapView.frame) - 25);
    
    [self.view addSubview:_mapView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"barbuttonicon_back_cube"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"barbuttonicon_more_cube"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton sizeToFit];
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -13);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my"] forState:UIControlStateNormal];
    [_locationBtn setBackgroundImage:[UIImage imageNamed:@"location_my_HL"] forState:UIControlStateHighlighted];
    _locationBtn.tag = TAG_LOCATION_ME_FAR;
    [_locationBtn sizeToFit];
    frame = _locationBtn.frame;
    frame.origin.x = SCREEN_WIDTH - 13 - CGRectGetWidth(frame);
    frame.origin.y = CGRectGetMaxY(_mapView.frame) - 18 - 50;
    _locationBtn.frame = frame;
    [self.view addSubview:_locationBtn];
    [_locationBtn addTarget:self action:@selector(backToUserLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BOTTOM_BAR_HEIGHT, SCREEN_WIDTH, BOTTOM_BAR_HEIGHT)];
    locationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:locationView];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"locationSharing_navigate_icon_new"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"locationSharing_navigate_icon_HL_new"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self  action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn sizeToFit];
    frame = shareBtn.frame;
    frame.origin.x = SCREEN_WIDTH - 13 - CGRectGetWidth(frame);
    frame.origin.y = (CGRectGetHeight(locationView.frame) - CGRectGetHeight(frame))/2;
    shareBtn.frame = frame;
    [locationView addSubview:shareBtn];
    
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 25, CGRectGetMinX(shareBtn.frame) -13 - 29 , 25)];
    _topLabel.font = [UIFont systemFontOfSize:20];
    _topLabel.textColor = [UIColor blackColor];
    _topLabel.textAlignment = NSTextAlignmentLeft;
    [locationView addSubview:_topLabel];
    
    _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_topLabel.frame), 54, CGRectGetWidth(_topLabel.frame), 20)];
    _bottomLabel.font = [UIFont systemFontOfSize:12];
    _bottomLabel.textColor = kLLTextColor_lightGray_system;
    _bottomLabel.textAlignment = NSTextAlignmentLeft;
    [locationView addSubview:_bottomLabel];
    
    isBackToUserLocation = NO;
    _topLabel.text = self.model.locationName;
    _bottomLabel.text = self.model.address;
    
    NSArray<UIGestureRecognizer *> *gestureRecognizers = self.mapView.subviews[0].gestureRecognizers;
    for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
            [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
            break;
        }
    }
    
    [self checkAuthorization];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    navigationBarTranslucent = self.navigationController.navigationBar.translucent;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.subviews[0].alpha = 0;

    if (!hasInitMapView) {
        hasInitMapView = YES;
        [self.mapView setZoomLevel:self.model.zoomLevel animated:NO];
        [self.mapView setCenterCoordinate:self.model.coordinate2D animated:NO];
        
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = self.model.coordinate2D;
        [self.mapView addAnnotation:pointAnnotation];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = navigationBarTranslucent;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self endUpdatingLocation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")]) {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


#pragma mark - 按钮回调

- (void)back:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)more:(UIButton *)btn {
    LLActionSheet *actionSheet = [[LLActionSheet alloc] initWithTitle:nil];
    LLActionSheetAction *action1 = [LLActionSheetAction actionWithTitle:@"发送给朋友"
                                                                handler:^(LLActionSheetAction *action) {
                                                                    
                                                                }];
    
    LLActionSheetAction *action2 = [LLActionSheetAction actionWithTitle:@"收藏"
                                                                handler:^(LLActionSheetAction *action) {
                                                                    
                                                                }] ;
    
    [actionSheet addActions:@[action1, action2]];
    
    [actionSheet showInWindow:self.view.window];
}

- (void)share:(UIButton *)btn {
    WEAK_SELF;
    LLActionSheet *actionSheet = [[LLActionSheet alloc] initWithTitle:nil];
    LLActionSheetAction *action1 = [LLActionSheetAction actionWithTitle:@"显示路线"
                                                                handler:^(LLActionSheetAction *action) {
                                                                }];
    
    LLActionSheetAction *action2 = [LLActionSheetAction actionWithTitle:@"街景"
                                                                handler:^(LLActionSheetAction *action) {
                                                                    
                                                                }] ;
    
    LLActionSheetAction *action3 = [LLActionSheetAction actionWithTitle:@"腾讯地图"
                                                                handler:^(LLActionSheetAction *action) {
                                                                    
                                                                }];
    
    LLActionSheetAction *action4 = [LLActionSheetAction actionWithTitle:@"高德地图"
                                                                handler:^(LLActionSheetAction *action) {
                                        [[LLLocationManager sharedManager] navigationUsingGaodeMapFromLocation:weakSelf.mapView.userLocation.location.coordinate toLocation:weakSelf.model.coordinate2D destinationName:weakSelf.model.address];
                                                                }];
    
    LLActionSheetAction *action5 = [LLActionSheetAction actionWithTitle:@"苹果地图"
                                                                handler:^(LLActionSheetAction *action) {
            [[LLLocationManager sharedManager] navigationFromCurrentLocationToLocationUsingAppleMap:weakSelf.model.coordinate2D destinationName:weakSelf.model.address];
                                                                }];


    if (self.locationPermissionGranted) {
        [actionSheet addActions:@[action1, action2, LL_ActionSheetSeperator, action3, action4, action5]];
    }else {
        [actionSheet addActions:@[action2, LL_ActionSheetSeperator, action3, action4, action5]];
    }
    
    [actionSheet showInWindow:self.view.window];
}


#pragma mark - 权限管理

- (void)checkAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        self.locationPermissionGranted = NO;
    }else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                self.locationPermissionGranted = NO;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationPermissionGranted = YES;
                [self startUpdatingLocation];
                break;
            //未获取地图权限时，此处不获取地图权限，因为这里仅仅是展示好友发送过来的地图坐标
            case kCLAuthorizationStatusNotDetermined:
                self.locationPermissionGranted = NO;
                break;
        }
    }
    
}


- (void)promptNoAuthorizationAlert {
    [LLUtils showMessageAlertWithTitle:nil message:LOCATION_AUTHORIZATION_DENIED_TEXT];
}

- (void)setLocationButtonStyle:(BOOL)isLocationMeNear {
    NSInteger targetTag = isLocationMeNear ? TAG_LOCATION_ME_NEAR : TAG_LOCATION_ME_FAR;
    if (_locationBtn.tag != targetTag) {
        NSString *backgroundImageString =  isLocationMeNear ? @"location_my_current": @"location_my";
        [_locationBtn setBackgroundImage:[UIImage imageNamed:backgroundImageString] forState:UIControlStateNormal];
    }

}

#pragma mark - 更新地图
- (void)startUpdatingLocation {
    _mapView.distanceFilter = 10;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
    representation.showsHeadingIndicator = YES;
    [_mapView updateUserLocationRepresentation:representation];
    
    if (_search)
        _search.delegate = self;
    
}

- (void)endUpdatingLocation {
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    self.mapView.showsUserLocation = NO;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.delegate = nil;

    if (_search)
        _search.delegate = nil;
}

- (void)backToUserLocation:(UIButton *)button {
    if (!self.locationPermissionGranted)
        return;
    
    isBackToUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate  animated:YES];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (animated && isBackToUserLocation) {
        isBackToUserLocation = NO;
        [self setLocationButtonStyle:YES];
    }else {
        [self setLocationButtonStyle:NO];
    }
}


- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {

    MAAnnotationView *annotationView;
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        annotationView = [[MAAnnotationView alloc] init];
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"located_pin"];
        annotationView.enabled = NO;
        annotationView.draggable = NO;
        annotationView.bounds = CGRectMake(0, 0, 18, 38);
        annotationView.layer.anchorPoint = CGPointMake(0.5, 0.96);
        
    }
//    else if ([annotation isKindOfClass:[MAUserLocation class]]) {
//        annotationView = [[MAAnnotationView alloc] init];
//        annotationView.annotation = annotation;
//        annotationView.image = [UIImage imageNamed:@"located_pin"];
//        annotationView.enabled = NO;
//        annotationView.draggable = NO;
//        annotationView.bounds = CGRectMake(0, 0, 18, 38);
//        annotationView.layer.anchorPoint = CGPointMake(0.5, 0.96);
//    }
    
    
    return annotationView;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    for (MAAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[MAUserLocation class]]){
            MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
            pre.fillColor = kLLBackgroundColor_slightBlue;
            pre.image = [UIImage imageNamed:@"locationSharing_Icon_MySelf"];
            pre.lineWidth = 0;
            pre.showsAccuracyRing = YES;
            pre.showsHeadingIndicator = YES;
            
            UIImage *indicator = [UIImage imageNamed:@"locationSharing_Icon_Myself_Heading"];
            UIImageView *headingView = [[UIImageView alloc] initWithImage:indicator];
            [headingView sizeToFit];
            CGRect frame = headingView.frame;
            frame.origin.x = 1;
            frame.origin.y = -8;
            headingView.frame = frame;
            
            [view addSubview:headingView];
            [self.mapView updateUserLocationRepresentation:pre];
            
            view.canShowCallout = NO;
            self.userLocationAnnotationView = view;
            
            break;
        }
    }
   
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
}

#pragma mark - 路径规划

//TODO：显示路线以后有时间了再做吧

/* 驾车路径规划搜索. */
//- (void)searchRoutePlanningDrive {
//    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
//    
//    navi.requireExtension = YES;
//    navi.strategy = 5;
//    /* 出发点. */
//    CLLocationCoordinate2D fromCoordinate = self.mapView.userLocation.location.coordinate;
//    navi.origin = [AMapGeoPoint locationWithLatitude:fromCoordinate.latitude
//                                           longitude:fromCoordinate.longitude];
//    /* 目的地. */
//    navi.destination = [AMapGeoPoint locationWithLatitude:self.model.coordinate2D.latitude
//                                                longitude:self.model.coordinate2D.longitude];
//    
//    if (!_search) {
//        self.search = [[AMapSearchAPI alloc] init];
//        self.search.delegate = self;
//    }
//    [self.search AMapDrivingRouteSearch:navi];
//}


@end
