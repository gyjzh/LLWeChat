//
//  AMapLocationRegionObj.h
//  AMapLocationKit
//
//  Created by AutoNavi on 15/11/27.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "AMapLocationCommonObj.h"

/// 以下类涉及的坐标需要使用高德坐标系坐标(GCJ02)

#pragma mark - AMapLocationRegion

/**
 *  AMapLocationRegion类，该类提供范围类的基本信息，并无具体实现，不要直接使用。
 */
@interface AMapLocationRegion : NSObject<NSCopying>

/**
 *  初始化方法
 *
 *  @param identifier 唯一标识符，必填，不可为nil
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 *  AMapLocationRegion的identifier
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  当进入region范围时是否通知，默认YES
 */
@property (nonatomic, assign) BOOL notifyOnEntry;

/**
 *  当离开region范围时是否通知，默认YES
 */
@property (nonatomic, assign) BOOL notifyOnExit;

/**
 *  坐标点是否在范围内
 *
 *  @param coordinate 要判断的坐标点
 *  @return 是否在范围内
 */
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

@end

#pragma mark - AMapLocationCircleRegion

/**
 *  AMapLocationCircleRegion类，定义一个圆形范围。
 */
@interface AMapLocationCircleRegion : AMapLocationRegion

/**
 *  根据中心点和半径生成圆形范围
 *
 *  @param center 中心点的经纬度坐标
 *  @param radius 半径，单位：米
 *  @param identifier 唯一标识符，必填，不可为nil
 *  @return AMapLocationCircleRegion类实例
 */
- (instancetype)initWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius identifier:(NSString *)identifier;

/**
 *  中心点的经纬度坐标
 */
@property (nonatomic, readonly) CLLocationCoordinate2D center;

/**
 *  半径，单位：米
 */
@property (nonatomic, readonly) CLLocationDistance radius;

@end

#pragma mark - AMapLocationPolygonRegion

/**
 *  AMapLocationCircleRegion类，定义一个闭合多边形范围，点与点之间按顺序尾部相连, 第一个点与最后一个点相连。
 */
@interface AMapLocationPolygonRegion : AMapLocationRegion

/**
 *  根据经纬度坐标数据生成闭合多边形范围
 *
 *  @param coordinates 经纬度坐标点数据,coordinates对应的内存会拷贝,调用者负责该内存的释放
 *  @param count 经纬度坐标点的个数，不可小于3个
 *  @param identifier 唯一标识符，必填，不可为nil
 *  @return AMapLocationCircleRegion类实例
 */
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSInteger)count identifier:(NSString *)identifier;

/**
 *  经纬度坐标点数据
 */
@property (nonatomic, readonly) CLLocationCoordinate2D *coordinates;

/**
 *  经纬度坐标点的个数
 */
@property (nonatomic, readonly) NSInteger count;

@end
