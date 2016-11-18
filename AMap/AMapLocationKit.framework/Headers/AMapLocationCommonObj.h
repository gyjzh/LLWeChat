//
//  AMapLocationCommonObj.h
//  AMapLocationKit
//
//  Created by AutoNavi on 15/10/22.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** AMapLocation errorDomain */
extern NSString * const AMapLocationErrorDomain;

/** AMapLocation errorCode */
typedef NS_ENUM(NSInteger, AMapLocationErrorCode)
{
    AMapLocationErrorUnknown = 1,               //!< 未知错误
    AMapLocationErrorLocateFailed = 2,          //!< 定位错误
    AMapLocationErrorReGeocodeFailed  = 3,      //!< 逆地理错误
    AMapLocationErrorTimeOut = 4,               //!< 超时
    AMapLocationErrorCanceled = 5,              //!< 取消
    AMapLocationErrorCannotFindHost = 6,        //!< 找不到主机
    AMapLocationErrorBadURL = 7,                //!< URL异常
    AMapLocationErrorNotConnectedToInternet = 8,//!< 连接异常
    AMapLocationErrorCannotConnectToHost = 9,   //!< 服务器连接失败
    AMapLocationErrorRegionMonitoringFailure=10,//!< 地理围栏错误
};

/** AMapLocation Region State */
typedef NS_ENUM(NSInteger, AMapLocationRegionState)
{
    AMapLocationRegionStateUnknow = 0,          //!< 未知
    AMapLocationRegionStateInside = 1,          //!< 在范围内
    AMapLocationRegionStateOutside = 2,         //!< 在范围外
};

/**
 * 逆地理信息
 */
@interface AMapLocationReGeocode : NSObject<NSCopying,NSCoding>

@property (nonatomic, copy) NSString *formattedAddress;//!< 格式化地址

@property (nonatomic, copy) NSString *country; //!< 国家
@property (nonatomic, copy) NSString *province; //!< 省/直辖市
@property (nonatomic, copy) NSString *city;     //!< 市
@property (nonatomic, copy) NSString *district; //!< 区
@property (nonatomic, copy) NSString *township; //!< 乡镇
@property (nonatomic, copy) NSString *neighborhood; //!< 社区
@property (nonatomic, copy) NSString *building; //!< 建筑
@property (nonatomic, copy) NSString *citycode; //!< 城市编码
@property (nonatomic, copy) NSString *adcode;   //!< 区域编码

@property (nonatomic, copy) NSString *street;   //!< 街道名称
@property (nonatomic, copy) NSString *number;   //!< 门牌号

@property (nonatomic, copy) NSString *POIName; //!< 兴趣点名称
@property (nonatomic, copy) NSString *AOIName; //!< 所属兴趣点名称


@end

/** AMapLocation CoordinateType */
typedef NS_ENUM(NSUInteger, AMapLocationCoordinateType)
{
    AMapLocationCoordinateTypeBaidu = 0,        //!< Baidu
    AMapLocationCoordinateTypeMapBar,           //!< MapBar
    AMapLocationCoordinateTypeMapABC,           //!< MapABC
    AMapLocationCoordinateTypeSoSoMap,          //!< SoSoMap
    AMapLocationCoordinateTypeAliYun,           //!< AliYun
    AMapLocationCoordinateTypeGoogle,           //!< Google
    AMapLocationCoordinateTypeGPS,              //!< GPS
};

/**
 *  转换目标经纬度为高德坐标系
 *
 *  @param coordinate 待转换的经纬度
 *  @param type       坐标系类型
 *  @return 高德坐标系经纬度
 */
FOUNDATION_EXTERN CLLocationCoordinate2D AMapLocationCoordinateConvert(CLLocationCoordinate2D coordinate, AMapLocationCoordinateType type);

/**
 *  判断目标经纬度是否在大陆以及港、澳地区。输入参数为高德坐标系。
 *
 *  @param coordinate 待判断的目标经纬度
 *  @return 是否在大陆以及港、澳地区
 */
FOUNDATION_EXTERN BOOL AMapLocationDataAvailableForCoordinate(CLLocationCoordinate2D coordinate);
