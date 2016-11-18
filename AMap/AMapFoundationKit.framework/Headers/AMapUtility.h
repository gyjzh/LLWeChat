//
//  AMapUtility.h
//  AMapFoundation
//
//  Created by xiaoming han on 15/10/27.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  工具方法
 */

FOUNDATION_STATIC_INLINE NSString * AMapEmptyStringIfNil(NSString *s)
{
    return s ? s : @"";
}


/// 坐标类型枚举
typedef NS_ENUM(NSUInteger, AMapCoordinateType)
{
    AMapCoordinateTypeBaidu = 0, // Baidu
    AMapCoordinateTypeMapBar, // MapBar
    AMapCoordinateTypeMapABC, // MapABC
    AMapCoordinateTypeSoSoMap, // SoSoMap
    AMapCoordinateTypeAliYun, // AliYun
    AMapCoordinateTypeGoogle, // Google
    AMapCoordinateTypeGPS, // GPS
};

/**
 *  转换目标经纬度为高德坐标系
 *
 *  @param coordinate 待转换的经纬度
 *  @param type       坐标系类型
 *
 *  @return 高德坐标系经纬度
 */
FOUNDATION_EXTERN CLLocationCoordinate2D AMapCoordinateConvert(CLLocationCoordinate2D coordinate, AMapCoordinateType type);

/**
 *  判断目标经纬度是否在大陆以及港、澳地区。输入参数为高德坐标系。
 *
 *  @param coordinate 待判断的目标经纬度
 *  @return 是否在大陆以及港、澳地区
 */
FOUNDATION_EXTERN BOOL AMapDataAvailableForCoordinate(CLLocationCoordinate2D coordinate);


