//
//  AMapCommonObj.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/7/22.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

/**
 *  该文件定义了搜索结果的基础数据类型。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - AMapSearchObject

/// 搜索SDK基础类
@interface AMapSearchObject : NSObject

/// 返回格式化的描述信息。通用数据结构和response类型有效。
- (NSString *)formattedDescription;

@end

#pragma mark - 通用数据结构

/// 经纬度
@interface AMapGeoPoint : AMapSearchObject<NSCopying>

@property (nonatomic, assign) CGFloat latitude; //!< 纬度（垂直方向）
@property (nonatomic, assign) CGFloat longitude; //!< 经度（水平方向）

+ (AMapGeoPoint *)locationWithLatitude:(CGFloat)lat longitude:(CGFloat)lon;

@end

/**
 * 多边形
 * 当传入两个点的时候，当做矩形处理:左下-右上两个顶点；其他情况视为多边形，几个点即为几边型。
 */
@interface AMapGeoPolygon : AMapSearchObject<NSCopying>

@property (nonatomic, strong) NSArray<AMapGeoPoint *> *points; //!< 坐标集, AMapGeoPoint 数组

+ (AMapGeoPolygon *)polygonWithPoints:(NSArray *)points;

@end

@class AMapDistrict;

/// 城市
@interface AMapCity : AMapSearchObject

@property (nonatomic, copy)   NSString  *city;  //!< 城市名称
@property (nonatomic, copy)   NSString  *citycode; //!< 城市编码
@property (nonatomic, copy)   NSString  *adcode; //!< 城市区域编码
@property (nonatomic, assign) NSInteger  num;   //!< 此区域的建议结果数目,AMapSuggestion中使用
@property (nonatomic, strong) NSArray<AMapDistrict *> *districts; //!< 途径区域 AMapDistrict 数组，AMepStep中使用，只有name和adcode。

@end

/// 建议信息
@interface AMapSuggestion : AMapSearchObject

@property (nonatomic, strong) NSArray<NSString *> *keywords; //!< NSString 数组
@property (nonatomic, strong) NSArray<AMapCity *> *cities; //!< AMapCity 数组

@end

#pragma mark - 输入提示

/// 输入提示
@interface AMapTip : AMapSearchObject

@property (nonatomic, copy) NSString     *uid; //!< poi的id
@property (nonatomic, copy) NSString     *name; //!< 名称
@property (nonatomic, copy) NSString     *adcode; //!< 区域编码
@property (nonatomic, copy) NSString     *district; //!< 所属区域
@property (nonatomic, copy) NSString     *address; //!< 地址
@property (nonatomic, copy) AMapGeoPoint *location; //!< 位置

@end

#pragma mark - POI

@interface AMapIndoorData : AMapSearchObject

@property (nonatomic, assign) NSInteger floor; //!< 楼层，为0时为POI本身。
@property (nonatomic, copy)   NSString  *floorName; //!< 楼层名称。
@property (nonatomic, copy)   NSString  *pid; //!< 父ID

@end

/// 子POI
@interface AMapSubPOI : AMapSearchObject

@property (nonatomic, copy)   NSString     *uid; //!< POI全局唯一ID
@property (nonatomic, copy)   NSString     *name; //!< 名称
@property (nonatomic, copy)   NSString     *sname; //!< 名称简写
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 经纬度
@property (nonatomic, copy)   NSString     *address;  //!< 地址
@property (nonatomic, assign) NSInteger     distance; //!< 距中心点距离
@property (nonatomic, copy)   NSString     *subtype; //!< 子POI类型

@end

/// POI
@interface AMapPOI : AMapSearchObject

// 基础信息
@property (nonatomic, copy)   NSString     *uid; //!< POI全局唯一ID
@property (nonatomic, copy)   NSString     *name; //!< 名称
@property (nonatomic, copy)   NSString     *type; //!< 兴趣点类型
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 经纬度
@property (nonatomic, copy)   NSString     *address;  //!< 地址
@property (nonatomic, copy)   NSString     *tel;  //!< 电话
@property (nonatomic, assign) NSInteger     distance; //!< 距中心点距离，仅在周边搜索时有效
@property (nonatomic, copy)   NSString     *parkingType; //!< 停车场类型，地上、地下、路边

// 扩展信息
@property (nonatomic, copy)   NSString     *postcode; //!< 邮编
@property (nonatomic, copy)   NSString     *website; //!< 网址
@property (nonatomic, copy)   NSString     *email;    //!< 电子邮件
@property (nonatomic, copy)   NSString     *province; //!< 省
@property (nonatomic, copy)   NSString     *pcode;   //!< 省编码
@property (nonatomic, copy)   NSString     *city; //!< 城市名称
@property (nonatomic, copy)   NSString     *citycode; //!< 城市编码
@property (nonatomic, copy)   NSString     *district; //!< 区域名称
@property (nonatomic, copy)   NSString     *adcode;   //!< 区域编码
@property (nonatomic, copy)   NSString     *gridcode; //!< 地理格ID
@property (nonatomic, copy)   AMapGeoPoint *enterLocation; //!< 入口经纬度
@property (nonatomic, copy)   AMapGeoPoint *exitLocation; //!< 出口经纬度
@property (nonatomic, copy)   NSString     *direction; //!< 方向
@property (nonatomic, assign) BOOL          hasIndoorMap; //!< 是否有室内地图
@property (nonatomic, copy)   NSString     *businessArea; //!< 所在商圈
@property (nonatomic, strong) AMapIndoorData *indoorData; //!< 室内信息
@property (nonatomic, strong) NSArray<AMapSubPOI *> *subPOIs; //!< 子POI列表 AMapSubPOI 数组

@end

#pragma mark - 逆地理编码 && 地理编码

/// 兴趣区域
@interface AMapAOI : AMapSearchObject

@property (nonatomic, copy)   NSString     *uid; //!< AOI全局唯一ID
@property (nonatomic, copy)   NSString     *name; //!< 名称
@property (nonatomic, copy)   NSString     *adcode;   //!< 所在区域编码
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 中心点经纬度
@property (nonatomic, assign) CGFloat      area; //!< 面积，单位平方米

@end

/// 道路
@interface AMapRoad : AMapSearchObject

@property (nonatomic, copy)   NSString     *uid; //!< 道路ID
@property (nonatomic, copy)   NSString     *name; //!< 道路名称
@property (nonatomic, assign) NSInteger     distance; //!< 距离（单位：米）
@property (nonatomic, copy)   NSString     *direction; //!< 方向
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 坐标点

@end

/// 道路交叉口
@interface AMapRoadInter : AMapSearchObject

@property (nonatomic, assign) NSInteger     distance; //!< 距离（单位：米）
@property (nonatomic, copy)   NSString     *direction; //!< 方向
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 经纬度
@property (nonatomic, copy)   NSString     *firstId; //!< 第一条道路ID
@property (nonatomic, copy)   NSString     *firstName; //!< 第一条道路名称
@property (nonatomic, copy)   NSString     *secondId; //!< 第二条道路ID
@property (nonatomic, copy)   NSString     *secondName; //!< 第二条道路名称

@end

/// 门牌信息
@interface AMapStreetNumber : AMapSearchObject

@property (nonatomic, copy)   NSString     *street; //!< 街道名称
@property (nonatomic, copy)   NSString     *number; //!< 门牌号
@property (nonatomic, copy)   AMapGeoPoint *location; //!<  坐标点
@property (nonatomic, assign) NSInteger     distance; //!< 距离（单位：米）
@property (nonatomic, copy)   NSString     *direction; //!< 方向

@end

/// 商圈
@interface AMapBusinessArea : AMapSearchObject

@property (nonatomic, strong) NSString     *name; //!< 名称
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 中心坐标

@end

/// 地址组成要素
@interface AMapAddressComponent : AMapSearchObject

@property (nonatomic, copy)   NSString         *province; //!< 省/直辖市
@property (nonatomic, copy)   NSString         *city; //!< 市
@property (nonatomic, copy)   NSString         *citycode; //!< 城市编码
@property (nonatomic, copy)   NSString         *district; //!< 区
@property (nonatomic, copy)   NSString         *adcode; //!< 区域编码
@property (nonatomic, copy)   NSString         *township; //!< 乡镇街道
@property (nonatomic, copy)   NSString         *towncode; //!< 乡镇街道编码
@property (nonatomic, copy)   NSString         *neighborhood; //!< 社区
@property (nonatomic, copy)   NSString         *building; //!< 建筑
@property (nonatomic, strong) AMapStreetNumber *streetNumber; //!< 门牌信息
@property (nonatomic, strong) NSArray<AMapBusinessArea *> *businessAreas; //!< 商圈列表 AMapBusinessArea 数组

@end

/// 逆地理编码
@interface AMapReGeocode : AMapSearchObject

// 基础信息
@property (nonatomic, copy)   NSString             *formattedAddress; //!< 格式化地址
@property (nonatomic, strong) AMapAddressComponent *addressComponent; //!< 地址组成要素

// 扩展信息
@property (nonatomic, strong) NSArray<AMapRoad *> *roads; //!< 道路信息 AMapRoad 数组
@property (nonatomic, strong) NSArray<AMapRoadInter *> *roadinters; //!< 道路路口信息 AMapRoadInter 数组
@property (nonatomic, strong) NSArray<AMapPOI *> *pois; //!< 兴趣点信息 AMapPOI 数组
@property (nonatomic, strong) NSArray<AMapAOI *> *aois; //!< 兴趣区域信息 AMapAOI 数组

@end

/// 地理编码
@interface AMapGeocode : AMapSearchObject

@property (nonatomic, copy) NSString     *formattedAddress; //<! 格式化地址
@property (nonatomic, copy) NSString     *province; //<! 所在省/直辖市
@property (nonatomic, copy) NSString     *city; //<! 城市名
@property (nonatomic, copy) NSString     *citycode; //!< 城市编码
@property (nonatomic, copy) NSString     *district; //<! 区域名称
@property (nonatomic, copy) NSString     *adcode; //<! 区域编码
@property (nonatomic, copy) NSString     *township; //<! 乡镇街道
@property (nonatomic, copy) NSString     *neighborhood; //<! 社区
@property (nonatomic, copy) NSString     *building; //<! 楼
@property (nonatomic, copy) AMapGeoPoint *location; //<! 坐标点
@property (nonatomic, copy) NSString     *level; //<! 匹配的等级

@end

#pragma mark - 公交查询
@class AMapBusLine;

/// 公交站
@interface AMapBusStop : AMapSearchObject

@property (nonatomic, copy)   NSString     *uid; //!< 公交站点ID
@property (nonatomic, copy)   NSString     *adcode; //!< 区域编码
@property (nonatomic, copy)   NSString     *name; //!< 公交站名
@property (nonatomic, copy)   NSString     *citycode; //!< 城市编码
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 经纬度坐标
@property (nonatomic, strong) NSArray<AMapBusLine *> *buslines; //!< 途径此站的公交路线 AMapBusLine 数组
@property (nonatomic, copy)   NSString *sequence; //!< 查询公交线路时的第几站

@end

/// 公交线路
@interface AMapBusLine : AMapSearchObject

// 基础信息
@property (nonatomic, copy) NSString     *uid; //!< 公交线路ID
@property (nonatomic, copy) NSString     *type; //!< 公交类型
@property (nonatomic, copy) NSString     *name; //!< 公交线路名称
@property (nonatomic, copy) NSString     *polyline; //!< 坐标集合
@property (nonatomic, copy) NSString     *citycode; //!< 城市编码
@property (nonatomic, copy) NSString     *startStop; //!< 首发站
@property (nonatomic, copy) NSString     *endStop; //!< 终点站
@property (nonatomic, copy) AMapGeoPoint *location; //!< 当查询公交站点时，返回的AMapBusLine中含有该字段

// 扩展信息
@property (nonatomic, copy)   NSString *startTime; //!< 首班车时间
@property (nonatomic, copy)   NSString *endTime; //!< 末班车时间
@property (nonatomic, copy)   NSString *company; //!< 所属公交公司
@property (nonatomic, assign) CGFloat distance; //!< 距离。在公交线路查询时，该值为此线路的全程距离，单位为千米; 在公交路径规划时，该值为乘坐此路公交车的行驶距离，单位为米
@property (nonatomic, assign) CGFloat basicPrice; //!< 起步价
@property (nonatomic, assign) CGFloat totalPrice; //!< 全程票价
@property (nonatomic, copy)   AMapGeoPolygon *bounds; //!< 矩形区域左下、右上顶点坐标
@property (nonatomic, strong) NSArray<AMapBusStop *> *busStops; //!< 本线路公交站 AMapBusStop 数组

// 公交路径规划信息
@property (nonatomic, strong) AMapBusStop *departureStop; //!< 起程站
@property (nonatomic, strong) AMapBusStop *arrivalStop; //!< 下车站
@property (nonatomic, strong) NSArray<AMapBusStop *> *viaBusStops; //!< 途径公交站 AMapBusStop 数组
@property (nonatomic, assign) NSInteger duration; //!< 预计行驶时间（单位：秒）

@end

#pragma mark - 行政区划

@interface AMapDistrict : AMapSearchObject

@property (nonatomic, copy)   NSString     *adcode; //!< 区域编码
@property (nonatomic, copy)   NSString     *citycode; //!< 城市编码
@property (nonatomic, copy)   NSString     *name; //!< 行政区名称
@property (nonatomic, copy)   NSString     *level; //!< 级别
@property (nonatomic, copy)   AMapGeoPoint *center; //!< 城市中心点
@property (nonatomic, strong) NSArray<AMapDistrict *> *districts; //!< 下级行政区域数组
@property (nonatomic, strong) NSArray<NSString *> *polylines; //!< 行政区边界坐标点, NSString 数组

@end

#pragma mark - 路径规划

/// 实时路况信息
@interface AMapTMC : AMapSearchObject

@property (nonatomic, assign) NSInteger distance; //!< 长度（单位：米）
@property (nonatomic, copy)   NSString  *status; //!< 路况状态描述：0 未知，1 畅通，2 缓行，3 拥堵

@end

/// 路段基本信息
@interface AMapStep : AMapSearchObject

// 基础信息
@property (nonatomic, copy)   NSString  *instruction; //!< 行走指示
@property (nonatomic, copy)   NSString  *orientation; //!< 方向
@property (nonatomic, copy)   NSString  *road; //!< 道路名称
@property (nonatomic, assign) NSInteger  distance; //!< 此路段长度（单位：米）
@property (nonatomic, assign) NSInteger  duration; //!< 此路段预计耗时（单位：秒）
@property (nonatomic, copy)   NSString  *polyline; //!< 此路段坐标点串
@property (nonatomic, copy)   NSString  *action; //!< 导航主要动作
@property (nonatomic, copy)   NSString  *assistantAction; //!< 导航辅助动作
@property (nonatomic, assign) CGFloat    tolls; //!< 此段收费（单位：元）
@property (nonatomic, assign) NSInteger  tollDistance; //!< 收费路段长度（单位：米）
@property (nonatomic, copy)   NSString  *tollRoad; //!< 主要收费路段

// 扩展信息
@property (nonatomic, strong) NSArray<AMapCity *> *cities; //!< 途径城市 AMapCity 数组
@property (nonatomic, strong) NSArray<AMapTMC *> *tmcs; //!< 路况信息数组，只有驾车路径规划时有效

@end

/// 步行、驾车方案
@interface AMapPath : AMapSearchObject

@property (nonatomic, assign) NSInteger  distance; //!< 起点和终点的距离
@property (nonatomic, assign) NSInteger  duration; //!< 预计耗时（单位：秒）
@property (nonatomic, copy)   NSString  *strategy; //!< 导航策略
@property (nonatomic, strong) NSArray<AMapStep *> *steps; //!< 导航路段 AMapStep数组
@property (nonatomic, assign) CGFloat    tolls; //!< 此方案费用（单位：元）
@property (nonatomic, assign) NSInteger  tollDistance; //!< 此方案收费路段长度（单位：米）
@property (nonatomic, assign) NSInteger  totalTrafficLights; //!< 此方案交通信号灯个数

@end

/// 步行换乘信息
@interface AMapWalking : AMapSearchObject

@property (nonatomic, copy)   AMapGeoPoint *origin; //!< 起点坐标
@property (nonatomic, copy)   AMapGeoPoint *destination; //!< 终点坐标
@property (nonatomic, assign) NSInteger     distance; //!< 起点和终点的步行距离
@property (nonatomic, assign) NSInteger     duration; //!< 步行预计时间
@property (nonatomic, strong) NSArray<AMapStep *> *steps; //!< 步行路段 AMapStep 数组

@end

/// 出租车信息
@interface AMapTaxi : AMapSearchObject

@property (nonatomic, copy)   AMapGeoPoint *origin; //!< 起点坐标
@property (nonatomic, copy)   AMapGeoPoint *destination; //!< 终点坐标
@property (nonatomic, assign) NSInteger    distance; //!< 距离，单位米
@property (nonatomic, assign) NSInteger    duration; //!< 耗时，单位秒
@property (nonatomic, copy)   NSString     *sname; //!< 起点名称
@property (nonatomic, copy)   NSString     *tname; //!< 终点名称

@end

/// 火车站
@interface AMapRailwayStation : AMapSearchObject

@property (nonatomic, copy) NSString     *uid; //!< 火车站ID
@property (nonatomic, copy) NSString     *name; //!< 名称
@property (nonatomic, copy) AMapGeoPoint *location; //!< 经纬度坐标
@property (nonatomic, copy) NSString     *adcode; //!< 区域编码
@property (nonatomic, copy) NSString     *time; //!< 发车、到站时间，途径站时则为进站时间
@property (nonatomic, assign) NSInteger  wait; //!< 途径站点的停靠时间，单位为分钟
@property (nonatomic, assign) BOOL       isStart; //!< 是否是始发站，为出发站时有效
@property (nonatomic, assign) BOOL       isEnd; //!< 是否是终点站，为到达站时有效

@end

/// 火车仓位及价格信息
@interface AMapRailwaySpace : AMapSearchObject

@property (nonatomic, copy) NSString *code; //!< 类型，硬卧、硬座等
@property (nonatomic, assign) CGFloat cost; //!< 票价，单位元

@end

/// 火车信息
@interface AMapRailway : AMapSearchObject

@property (nonatomic, copy) NSString     *uid; //!< 火车线路ID
@property (nonatomic, copy) NSString     *name; //!< 名称
@property (nonatomic, copy) NSString     *trip; //!< 车次
@property (nonatomic, copy) NSString     *type; //!< 类型
@property (nonatomic, assign) NSInteger  distance; //!< 该换乘段行车总距离，单位为米
@property (nonatomic, assign) NSInteger  time; //!< 该线路车段耗时，单位为秒
@property (nonatomic, strong) AMapRailwayStation *departureStation; //!< 出发站
@property (nonatomic, strong) AMapRailwayStation *arrivalStation; //!< 到达站
@property (nonatomic, strong) NSArray<AMapRailwaySpace *> *spaces; //!< 仓位及价格信息

// 扩展信息
@property (nonatomic, strong) NSArray<AMapRailwayStation *> *viaStops; //!< 途径站点信息
@property (nonatomic, strong) NSArray<AMapRailway *> *alters; //!< 备选路线信息, 目前只有id和name

@end


/// 公交换乘路段
@interface AMapSegment : AMapSearchObject

@property (nonatomic, strong) AMapWalking  *walking; //!< 此路段步行导航信息
@property (nonatomic, strong) NSArray<AMapBusLine *> *buslines; //!< 此路段可供选择的不同公交线路 AMapBusLine 数组
@property (nonatomic, strong) AMapTaxi     *taxi; //!< 出租车信息，跨城时有效
@property (nonatomic, strong) AMapRailway  *railway; //!< 火车信息，跨城时有效
@property (nonatomic, copy)   NSString     *enterName; //!< 入口名称
@property (nonatomic, copy)   AMapGeoPoint *enterLocation; //!< 入口经纬度
@property (nonatomic, copy)   NSString     *exitName; //!< 出口名称
@property (nonatomic, copy)   AMapGeoPoint *exitLocation; //!< 出口经纬度

@end

/// 公交方案
@interface AMapTransit : AMapSearchObject

@property (nonatomic, assign) CGFloat    cost; //!< 此公交方案价格（单位：元）
@property (nonatomic, assign) NSInteger  duration; //!< 此换乘方案预期时间（单位：秒）
@property (nonatomic, assign) BOOL       nightflag; //!< 是否是夜班车
@property (nonatomic, assign) NSInteger  walkingDistance; //!< 此方案总步行距离（单位：米）
@property (nonatomic, strong) NSArray<AMapSegment *> *segments; //!< 换乘路段 AMapSegment 数组
@property (nonatomic, assign) NSInteger  distance; //!< 当前方案的总距离

@end

/// 路径规划信息
@interface AMapRoute : AMapSearchObject

@property (nonatomic, copy) AMapGeoPoint *origin; //!< 起点坐标
@property (nonatomic, copy) AMapGeoPoint *destination; //!< 终点坐标

@property (nonatomic, assign) CGFloat  taxiCost; //!< 出租车费用（单位：元）
@property (nonatomic, strong) NSArray<AMapPath *> *paths; //!< 步行、驾车方案列表 AMapPath 数组
@property (nonatomic, strong) NSArray<AMapTransit *> *transits; //!< 公交换乘方案列表 AMapTransit 数组

@end

#pragma mark - 天气查询

/// 实况天气，仅支持中国大陆、香港、澳门的数据返回
@interface AMapLocalWeatherLive : AMapSearchObject

@property (nonatomic, copy) NSString *adcode; //!< 区域编码
@property (nonatomic, copy) NSString *province; //!< 省份名
@property (nonatomic, copy) NSString *city; //!< 城市名
@property (nonatomic, copy) NSString *weather; //!< 天气现象
@property (nonatomic, copy) NSString *temperature; //!< 实时温度
@property (nonatomic, copy) NSString *windDirection; //!< 风向
@property (nonatomic, copy) NSString *windPower; //!< 风力，单位：级
@property (nonatomic, copy) NSString *humidity; //!< 空气湿度
@property (nonatomic, copy) NSString *reportTime; //!<数据发布时间

@end

/// 某一天的天气预报信息
@interface AMapLocalDayWeatherForecast : AMapSearchObject

@property (nonatomic, copy) NSString *date; //!< 日期
@property (nonatomic, copy) NSString *week; //!< 星期
@property (nonatomic, copy) NSString *dayWeather; //!< 白天天气现象
@property (nonatomic, copy) NSString *nightWeather;//!< 晚上天气现象
@property (nonatomic, copy) NSString *dayTemp; //!< 白天温度
@property (nonatomic, copy) NSString *nightTemp; //!< 晚上温度
@property (nonatomic, copy) NSString *dayWind; //!< 白天风向
@property (nonatomic, copy) NSString *nightWind; //!< 晚上风向
@property (nonatomic, copy) NSString *dayPower; //!< 白天风力
@property (nonatomic, copy) NSString *nightPower; //!< 晚上风力

@end

/// 天气预报类，支持当前时间在内的3天的天气进行预报
@interface AMapLocalWeatherForecast : AMapSearchObject

@property (nonatomic, copy)   NSString *adcode; //!< 区域编码
@property (nonatomic, copy)   NSString *province; //!< 省份名
@property (nonatomic, copy)   NSString *city; //!< 城市名
@property (nonatomic, copy)   NSString *reportTime; //!<数据发布时间
@property (nonatomic, strong) NSArray<AMapLocalDayWeatherForecast *> *casts; //!< 天气预报AMapLocalDayWeatherForecast数组

@end

#pragma mark - 附近搜索

@interface AMapNearbyUserInfo : AMapSearchObject

@property (nonatomic, copy)   NSString       *userID; //!< 用户ID
@property (nonatomic, copy)   AMapGeoPoint   *location; //!< 最后更新位置
@property (nonatomic, assign) CGFloat         distance; //!< 与搜索点的距离，由搜索时searchType决定
@property (nonatomic, assign) NSTimeInterval  updatetime; //!< 最后更新的时间戳，单位秒

@end

#pragma mark - 云图基础数据类型

/// POI点的图片信息
@interface AMapCloudImage : AMapSearchObject

@property (nonatomic, copy) NSString *uid; //!< 图片的id标识
@property (nonatomic, copy) NSString *preurl; //!< 图片压缩后的url串
@property (nonatomic, copy) NSString *url; //!< 图片原始的url

@end

/// POI信息
@interface AMapCloudPOI : AMapSearchObject

@property (nonatomic, assign) NSInteger     uid; //!< 唯一表示
@property (nonatomic, copy)   NSString     *name; //!< 名称
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 坐标位置
@property (nonatomic, copy)   NSString     *address;  //!< 地址
@property (nonatomic, strong) NSDictionary *customFields; //!< 用户自定义字段
@property (nonatomic, copy)   NSString     *createTime; //!< 创建时间
@property (nonatomic, copy)   NSString     *updateTime; //!< 更新时间
@property (nonatomic, assign) NSInteger     distance; //!< 离当前位置的距离(只在PlaceAround搜索时有效)
@property (nonatomic, strong) NSArray<AMapCloudImage *> *images;  //!< 图片信息

@end





