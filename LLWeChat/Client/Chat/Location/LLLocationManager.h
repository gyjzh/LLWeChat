//
//  LLLocationManager.h
//  LLWeChat
//
//  Created by GYJZH on 8/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface LLLocationManager : NSObject

+ (instancetype)sharedManager;

- (void)takeSnapshotAtCoordinate:(CLLocationCoordinate2D)coordinate2D spanSize:(CGSize)size withCompletionBlock:(void (^)(UIImage *resultImage, CGRect rect))block;

- (void)reGeocodeFromCoordinate:(CLLocationCoordinate2D)coordinate2D completeCallback:(void (^)(AMapReGeocode *address, CLLocationCoordinate2D coordinate2D))completeCallback;

- (void)getLocationNameAndAddressFromReGeocode:(AMapReGeocode *)reGeoCode name:(NSString **)name address:(NSString **)address;

- (UIImage *)takeCenterSnapshotFromMapView:(MAMapView *)mapView;

- (void)takeCenterSnapshotFromMapView:(MAMapView *)mapView withCompletionBlock:(void (^)(UIImage *resultImage, CGRect rect))block;

-(void)navigationFromCurrentLocationToLocationUsingAppleMap:(CLLocationCoordinate2D)toCoordinate2D
                                            destinationName:(NSString *)destinationName;

-(void)navigationUsingGaodeMapFromLocation:(CLLocationCoordinate2D)fromCoordinate2D
                                toLocation:(CLLocationCoordinate2D)toCoordinate2D
                           destinationName:(NSString *)destinationName;
@end
