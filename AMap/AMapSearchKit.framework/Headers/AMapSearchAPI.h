//
//  AMapSearchAPI.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/7/22.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMapSearchObj.h"
#import "AMapCommonObj.h"

@protocol AMapSearchDelegate;

/// 搜索结果语言
typedef NS_ENUM(NSInteger, AMapSearchLanguage)
{
    AMapSearchLanguageZhCN = 0, //!< 中文
    AMapSearchLanguageEn = 1 //!< 英文
};

/// 搜索类
@interface AMapSearchAPI : NSObject

/// 实现了AMapSearchDelegate协议的类指针
@property (nonatomic, weak) id<AMapSearchDelegate> delegate;

/// 查询超时时间，单位秒，默认为20秒
@property (nonatomic, assign) NSInteger timeout;

/// 查询结果返回语言, 默认为中文
@property (nonatomic, assign) AMapSearchLanguage language;


/**
 *  AMapSearch的初始化函数。
 *
 *  初始化之前请正确设置key，否则将无法正常使用搜索服务.
 *  @return AMapSearch类对象实例
 */
- (instancetype)init;

/**
 *  取消所有未回调的请求，触发错误回调。
 */
- (void)cancelAllRequests;

#pragma mark - 搜索服务接口

/**
 *  POI ID查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapPOIIDSearchRequest 类。
 */
- (void)AMapPOIIDSearch:(AMapPOIIDSearchRequest *)request;

/**
 *  POI 关键字查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapPOIKeywordsSearchRequest 类。
 */
- (void)AMapPOIKeywordsSearch:(AMapPOIKeywordsSearchRequest *)request;

/**
 *  POI 周边查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapPOIAroundSearchRequest 类。
 */
- (void)AMapPOIAroundSearch:(AMapPOIAroundSearchRequest *)request;

/**
 *  POI 多边形查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapPOIPolygonSearchRequest 类。
 */
- (void)AMapPOIPolygonSearch:(AMapPOIPolygonSearchRequest *)request;

/**
 *  地址编码查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapGeocodeSearchRequest 类。
 */
- (void)AMapGeocodeSearch:(AMapGeocodeSearchRequest *)request;

/**
 *  逆地址编码查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapReGeocodeSearchRequest 类。
 */
- (void)AMapReGoecodeSearch:(AMapReGeocodeSearchRequest *)request;

/**
 *  输入提示查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapInputTipsSearchRequest 类。
 */
- (void)AMapInputTipsSearch:(AMapInputTipsSearchRequest *)request;

/**
 *  公交站点查询接口
 *
 * @param request 查询选项。具体属性字段请参考 AMapBusStopSearchRequest 类。
 */
- (void)AMapBusStopSearch:(AMapBusStopSearchRequest *)request;

/**
 *  公交线路关键字查询
 *
 *  @param request 查询选项。具体属性字段请参考 AMapBusLineIDSearchRequest 类。
 */
- (void)AMapBusLineIDSearch:(AMapBusLineIDSearchRequest *)request;

/**
 *  公交线路关键字查询
 *
 *  @param request 查询选项。具体属性字段请参考 AMapBusLineNameSearchRequest 类。
 */
- (void)AMapBusLineNameSearch:(AMapBusLineNameSearchRequest *)request;

/**
 *  行政区域查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapDistrictSearchRequest 类。
 */
- (void)AMapDistrictSearch:(AMapDistrictSearchRequest *)request;

/**
 *  驾车路径规划查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapDrivingRouteSearchRequest 类。
 */
- (void)AMapDrivingRouteSearch:(AMapDrivingRouteSearchRequest *)request;

/**
 *  步行路径规划查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapWalkingRouteSearchRequest 类。
 */
- (void)AMapWalkingRouteSearch:(AMapWalkingRouteSearchRequest *)request;

/**
 *  公交路径规划查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapTransitRouteSearchRequest 类。
 */
- (void)AMapTransitRouteSearch:(AMapTransitRouteSearchRequest *)request;

/**
 *  天气查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapWeatherSearchRequest 类。
 */
- (void)AMapWeatherSearch:(AMapWeatherSearchRequest *)request;

#pragma mark - 附近搜索相关

/**
 *  附近搜索查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapNearbySearchRequest 类。
 */
- (void)AMapNearbySearch:(AMapNearbySearchRequest *)request;

#pragma mark - 云图搜索相关

/**
 *  云图周边查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapCloudPOIAroundSearchRequest 类。
 */
- (void)AMapCloudPOIAroundSearch:(AMapCloudPOIAroundSearchRequest *)request;

/**
 *  云图polygon区域查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapCloudPOIPolygonSearchRequest 类。
 */
- (void)AMapCloudPOIPolygonSearch:(AMapCloudPOIPolygonSearchRequest *)request;

/**
 *  云图ID查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapCloudPOIIDSearchRequest 类。
 */
- (void)AMapCloudPOIIDSearch:(AMapCloudPOIIDSearchRequest *)request;

/**
 *  云图本地查询接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapCloudPOILocalSearchRequest 类。
 */
- (void)AMapCloudPOILocalSearch:(AMapCloudPOILocalSearchRequest *)request;

#pragma mark - 短串分享相关

/**
 *  位置短串分享接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapLocationShareSearchRequest 类。
 */
- (void)AMapLocationShareSearch:(AMapLocationShareSearchRequest *)request;

/**
 *  兴趣点短串分享接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapPOIShareSearchRequest 类。
 */
- (void)AMapPOIShareSearch:(AMapPOIShareSearchRequest *)request;

/**
 *  路线规划短串分享接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapRouteShareSearchRequest 类。
 */
- (void)AMapRouteShareSearch:(AMapRouteShareSearchRequest *)request;

/**
 *  导航短串分享接口
 *
 *  @param request 查询选项。具体属性字段请参考 AMapNavigationShareSearchRequest 类。
 */
- (void)AMapNavigationShareSearch:(AMapNavigationShareSearchRequest *)request;

@end

#pragma mark - AMapSearchDelegate

/**
 *  AMapSearchDelegate协议
 *  定义了搜索结果的回调方法，发生错误时的错误回调方法。
 */
@protocol AMapSearchDelegate<NSObject>
@optional

/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error;

/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response;

/**
 *  地理编码查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapGeocodeSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapGeocodeSearchResponse 。
 */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response;

/**
 *  逆地理编码查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response;

/**
 *  输入提示查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapInputTipsSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapInputTipsSearchResponse 。
 */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response;

/**
 *  公交站查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapBusStopSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapBusStopSearchResponse 。
 */
- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response;

/**
 *  公交线路关键字查询回调
 *
 *  @param request  发起的请求，具体字段参考 AMapBusLineSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapBusLineSearchResponse 。
 */
- (void)onBusLineSearchDone:(AMapBusLineBaseSearchRequest *)request response:(AMapBusLineSearchResponse *)response;

/**
 *  行政区域查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapDistrictSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapDistrictSearchResponse 。
 */
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response;

/**
 *  路径规划查询回调
 *
 *  @param request  发起的请求，具体字段参考 AMapRouteSearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapRouteSearchResponse 。
 */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response;

/**
 *  天气查询回调
 *
 *  @param request  发起的请求，具体字段参考 AMapWeatherSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapWeatherSearchResponse 。
 */
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response;

#pragma mark - 附近搜索回调

/**
 *  附近搜索回调
 *
 *  @param request  发起的请求，具体字段参考 AMapNearbySearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapNearbySearchResponse 。
 */
- (void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response;

#pragma mark - 云图搜索回调

/**
 *   云图查询回调函数
 *
 *   @param request 发起的请求，具体字段参考AMapCloudSearchBaseRequest 。
 *   @param response 响应结果，具体字段参考 AMapCloudPOISearchResponse 。
 */
- (void)onCloudSearchDone:(AMapCloudSearchBaseRequest *)request response:(AMapCloudPOISearchResponse *)response;

#pragma mark - 短串分享搜索回调

/**
 *  短串分享搜索回调
 *
 *  @param request  发起的请求
 *  @param response 相应结果，具体字段参考 AMapShareSearchResponse。
 */
- (void)onShareSearchDone:(AMapShareSearchBaseRequest *)request response:(AMapShareSearchResponse *)response;

@end
