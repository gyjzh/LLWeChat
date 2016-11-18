//
//  LLLocationManager.m
//  LLWeChat
//
//  Created by GYJZH on 8/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLLocationManager.h"
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "LLUtils.h"
#import "LLConfig.h"
@import AddressBook;

#define SNAPSHOT_SPAN_WIDTH 263
#define SNAPSHOT_SPAN_HEIGHT 150

typedef void (^ReGeocodeSearchCompleteBlock)(AMapReGeocode *address, CLLocationCoordinate2D coordinate2D);


@interface _LLInternal_Data_LLLocationManager : NSObject

//@property (nonatomic) NSInteger index;
@property (nonatomic) AMapReGeocodeSearchRequest *request;
@property (nonatomic) ReGeocodeSearchCompleteBlock completeCallback;

@end

@implementation _LLInternal_Data_LLLocationManager


@end



@interface LLLocationManager () <AMapSearchDelegate>

@property (nonatomic) MAMapView *mapView;

@property (nonatomic) AMapSearchAPI *reGeocodeSearch;

@property (nonatomic) NSMutableArray<_LLInternal_Data_LLLocationManager *> *allRequests;

@end

@implementation LLLocationManager


+ (instancetype)sharedManager {
    static LLLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LLLocationManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    _reGeocodeSearch.delegate = nil;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:SCREEN_FRAME];
        //    _mapView.delegate = self;
        _mapView.mapType = MAMapTypeStandard;
        _mapView.language = MAMapLanguageZhCN;
        _mapView.userTrackingMode = MAUserTrackingModeNone;
        
        _mapView.zoomEnabled = YES;
        _mapView.minZoomLevel = 4;
        _mapView.maxZoomLevel = 19;
        
        _mapView.logoCenter = CGPointMake(-MAXFLOAT, -MAXFLOAT);
        _mapView.scrollEnabled = NO;
        _mapView.showsCompass = NO;
        _mapView.showsScale = NO;
    }
    
    return _mapView;
}

- (AMapSearchAPI *)reGeocodeSearch {
    if (!_reGeocodeSearch) {
        _allRequests = [NSMutableArray array];
        _reGeocodeSearch = [[AMapSearchAPI alloc] init];
        _reGeocodeSearch.delegate = self;

    }
    
    return _reGeocodeSearch;
}


#pragma mark - 地图截图
- (void)takeSnapshotAtCoordinate:(CLLocationCoordinate2D)coordinate2D spanSize:(CGSize)size withCompletionBlock:(void (^)(UIImage *resultImage, CGRect rect))block
{
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    [self.mapView setCenterCoordinate:coordinate2D animated:NO];

    [_mapView takeSnapshotInRect:frame withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(resultImage, rect);
            });
        }
    }];
}

- (UIImage *)takeCenterSnapshotFromMapView:(MAMapView *)mapView {
    CGSize size = mapView.bounds.size;
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    UIImage *image = [mapView takeSnapshotInRect:CGRectMake(centerPoint.x - SNAPSHOT_SPAN_WIDTH/2, centerPoint.y - SNAPSHOT_SPAN_HEIGHT/2, SNAPSHOT_SPAN_WIDTH, SNAPSHOT_SPAN_HEIGHT)];
    return image;
}

- (void)takeCenterSnapshotFromMapView:(MAMapView *)mapView withCompletionBlock:(void (^)(UIImage *resultImage, CGRect rect))block {
    CGSize size = mapView.bounds.size;
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    CGRect rect = CGRectMake(centerPoint.x - SNAPSHOT_SPAN_WIDTH/2, centerPoint.y - SNAPSHOT_SPAN_HEIGHT/2, SNAPSHOT_SPAN_WIDTH, SNAPSHOT_SPAN_HEIGHT);
    [mapView takeSnapshotInRect:rect withCompletionBlock:block];
}

#pragma mark - 地理逆解析

//搜索发生错误时调用
- (void)AMapSearchRequest:(AMapReGeocodeSearchRequest *)request didFailWithError:(NSError *)error {
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
//    NSInteger index = [objc_getAssociatedObject(request, &key) intValue];
    
    @synchronized (self) {
        for (NSInteger i = 0, r = _allRequests.count; i < r; i++) {
            _LLInternal_Data_LLLocationManager *data = _allRequests[i];
            if (data.request == request) {
                data.completeCallback(nil, coordinate2D);
                [_allRequests removeObjectAtIndex:i];
                break;
            }
        }
    }
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    
//    NSInteger index = [objc_getAssociatedObject(request, &key) intValue];
    
    @synchronized (self) {
        for (NSInteger i = 0, r = _allRequests.count; i < r; i++) {
            _LLInternal_Data_LLLocationManager *data = _allRequests[i];
            if (data.request == request) {
                data.completeCallback(response.regeocode, coordinate2D);
                [_allRequests removeObjectAtIndex:i];
                break;
            }
        }
    }

}


- (void)reGeocodeFromCoordinate:(CLLocationCoordinate2D)coordinate2D completeCallback:(void (^)(AMapReGeocode *address, CLLocationCoordinate2D coordinate2D))completeCallback {
    if (!completeCallback)
        return;
    
    AMapReGeocodeSearchRequest *regeoUser = [[AMapReGeocodeSearchRequest alloc] init];
    regeoUser.radius = 3000;
    regeoUser.requireExtension = NO;
//    objc_setAssociatedObject(regeoUser, &key, @(key),  OBJC_ASSOCIATION_ASSIGN);
    
    AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude];
    regeoUser.location = point;

    [self.reGeocodeSearch AMapReGoecodeSearch:regeoUser];
    
    _LLInternal_Data_LLLocationManager *data = [_LLInternal_Data_LLLocationManager new];
    data.request = regeoUser;
    data.completeCallback = completeCallback;
//    data.index = key;
    [_allRequests addObject:data];
//    key++;
}


- (void)getLocationNameAndAddressFromReGeocode:(AMapReGeocode *)reGeoCode name:(NSString **)name address:(NSString **)address {
    NSString *_address = reGeoCode.formattedAddress;
    NSString *_name;
    if (reGeoCode.addressComponent.neighborhood.length > 0)
        _name = reGeoCode.addressComponent.neighborhood;
    else if (reGeoCode.addressComponent.building.length > 0) {
        _name = reGeoCode.addressComponent.building;
    }else if (_address.length > 0) {
        _name = [_address substringFromIndex:reGeoCode.addressComponent.province.length];
    }
    
    if (_name.length == 0)
        _name = LOCATION_EMPTY_NAME;
    if (_address.length == 0)
        _address = LOCATION_EMPTY_ADDRESS;
    
    *name = _name;
    *address = _address;
}

#pragma mark - 调用第三方导航APP

-(void)navigationFromCurrentLocationToLocationUsingAppleMap:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName {
    MKPlacemark *mkPlacemark2=[[MKPlacemark alloc] initWithCoordinate:toCoordinate2D addressDictionary:@{(NSString *)kABPersonAddressStreetKey:destinationName}];
    NSDictionary *options=@{
                MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),
                MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
                };
    
    //MKMapItem *mapItem1=[MKMapItem mapItemForCurrentLocation];//当前位置
//    MKMapItem *mapItem1=[[MKMapItem alloc] initWithPlacemark:mkPlacemark1];
    MKMapItem *mapItem2=[[MKMapItem alloc] initWithPlacemark:mkPlacemark2];
    [MKMapItem openMapsWithItems:@[mapItem2] launchOptions:options];
}

-(void)navigationUsingGaodeMapFromLocation:(CLLocationCoordinate2D)fromCoordinate2D toLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName {
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&slat=%f&slon=%f&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",[LLUtils appName], fromCoordinate2D.latitude, fromCoordinate2D.longitude, toCoordinate2D.latitude, toCoordinate2D.longitude, destinationName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];

}

@end
