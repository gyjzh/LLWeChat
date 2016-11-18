//
//  AMapSearchObj.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/7/22.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

/**
 *  该文件定义了搜索请求和返回对象。
 */

#import <Foundation/Foundation.h>
#import "AMapCommonObj.h"

#pragma mark - AMapPOISearchBaseRequest

/// POI搜索请求基类
@interface AMapPOISearchBaseRequest : AMapSearchObject

@property (nonatomic, copy)   NSString  *types; //!< 类型，多个类型用“|”分割 可选值:文本分类、分类代码
@property (nonatomic, assign) NSInteger  sortrule; //<! 排序规则, 0-距离排序；1-综合排序, 默认1
@property (nonatomic, assign) NSInteger  offset; //<! 每页记录数, 范围1-50, [default = 20]
@property (nonatomic, assign) NSInteger  page; //<! 当前页数, 范围1-100, [default = 1]

@property (nonatomic, assign) BOOL requireExtension; //<! 是否返回扩展信息，默认为 NO。
@property (nonatomic, assign) BOOL requireSubPOIs; //<! 是否返回扩POI，默认为 NO。

@end

/// POI ID搜索请求
@interface AMapPOIIDSearchRequest : AMapPOISearchBaseRequest

@property (nonatomic, copy) NSString *uid; //<! POI全局唯一ID

@end

/// POI关键字搜索
@interface AMapPOIKeywordsSearchRequest : AMapPOISearchBaseRequest

@property (nonatomic, copy)   NSString *keywords; //<! 查询关键字，多个关键字用“|”分割
@property (nonatomic, copy)   NSString *city; //!< 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
@property (nonatomic, assign) BOOL cityLimit; //!< 强制城市限制功能 默认NO，例如：在上海搜索天安门，如果citylimit为true，将不返回北京的天安门相关的POI

@end

/// POI周边搜索
@interface AMapPOIAroundSearchRequest : AMapPOISearchBaseRequest

@property (nonatomic, copy)   NSString     *keywords; //<! 查询关键字，多个关键字用“|”分割
@property (nonatomic, copy)   AMapGeoPoint *location; //<! 中心点坐标
@property (nonatomic, assign) NSInteger     radius; //<! 查询半径，范围：0-50000，单位：米 [default = 3000]

@end

/// POI多边形搜索
@interface AMapPOIPolygonSearchRequest : AMapPOISearchBaseRequest

@property (nonatomic, copy) NSString       *keywords; //<! 查询关键字，多个关键字用“|”分割
@property (nonatomic, copy) AMapGeoPolygon *polygon; //<! 多边形

@end

/// POI搜索返回
@interface AMapPOISearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger       count; //!< 返回的POI数目
@property (nonatomic, strong) AMapSuggestion *suggestion; //!< 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray<AMapPOI *> *pois; //!< POI结果，AMapPOI 数组

@end

#pragma mark - AMapInputTipsSearchRequest

/// 搜索提示请求
@interface AMapInputTipsSearchRequest : AMapSearchObject

@property (nonatomic, copy)   NSString *keywords; //!< 查询关键字
@property (nonatomic, copy)   NSString *city; //!< 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
@property (nonatomic, copy)   NSString *types; //!< 类型，多个类型用“|”分割 可选值:文本分类、分类代码
@property (nonatomic, assign) BOOL cityLimit; //!< 强制城市限制功能，例如：在上海搜索天安门，如果citylimit为true，将不返回北京的天安门相关的POI

@end

/// 搜索提示返回
@interface AMapInputTipsSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger  count; //!< 返回数目
@property (nonatomic, strong) NSArray<AMapTip *> *tips; //!< 提示列表 AMapTip 数组

@end

#pragma mark - AMapGeocodeSearchRequest

/// 地理编码请求
@interface AMapGeocodeSearchRequest : AMapSearchObject

@property (nonatomic, copy) NSString *address; //!< 地址
@property (nonatomic, copy) NSString *city; //!< 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.

@end

/// 地理编码请求
@interface AMapGeocodeSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger  count; //!< 返回数目
@property (nonatomic, strong) NSArray<AMapGeocode *> *geocodes; //!< 地理编码结果 AMapGeocode 数组

@end


#pragma mark - AMapReGeocodeSearchRequest

/// 逆地理编码请求
@interface AMapReGeocodeSearchRequest : AMapSearchObject

@property (nonatomic, assign) BOOL          requireExtension; //!< 是否返回扩展信息，默认NO。
@property (nonatomic, copy)   AMapGeoPoint *location; //!< 中心点坐标。
@property (nonatomic, assign) NSInteger     radius; //!< 查询半径，单位米，范围0~3000，默认1000。

@end

/// 逆地理编码返回
@interface AMapReGeocodeSearchResponse : AMapSearchObject

@property (nonatomic, strong) AMapReGeocode *regeocode; //!< 逆地理编码结果

@end

#pragma mark - AMapBusStopSearchRequest

/// 公交站点请求
@interface AMapBusStopSearchRequest : AMapSearchObject

@property (nonatomic, copy)   NSString  *keywords; //!< 查询关键字
@property (nonatomic, copy)   NSString  *city; //!< 城市 可选值：cityname（中文或中文全拼）、citycode、adcode
@property (nonatomic, assign) NSInteger  offset; //!< 每页记录数，默认为20，取值为：1-50
@property (nonatomic, assign) NSInteger  page; //!< 当前页数，默认值为1，取值为：1-100

@end

/// 公交站点返回
@interface AMapBusStopSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger       count; //!< 公交站数目
@property (nonatomic, strong) AMapSuggestion *suggestion; //!< 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray<AMapBusStop *> *busstops; //!< 公交站点数组，数组中存放AMapBusStop对象

@end

#pragma mark - AMapBusLineSearchRequest

/// 公交线路查询请求基类，不可直接调用
@interface AMapBusLineBaseSearchRequest : AMapSearchObject

@property (nonatomic, copy)   NSString  *city; //!< 城市 可选值：cityname（中文或中文全拼）、citycode、adcode
@property (nonatomic, assign) BOOL       requireExtension; //!< 是否返回扩展信息，默认为NO
@property (nonatomic, assign) NSInteger  offset; //!< 每页记录数，默认为20，取值为1－50
@property (nonatomic, assign) NSInteger  page; //!< 当前页数，默认为1，取值为1-100

@end

/// 公交站线路根据名字请求
@interface AMapBusLineNameSearchRequest : AMapBusLineBaseSearchRequest

@property (nonatomic, copy) NSString *keywords; //!< 查询关键字

@end

/// 公交站线路根据ID请求
@interface AMapBusLineIDSearchRequest : AMapBusLineBaseSearchRequest

@property (nonatomic, copy) NSString *uid;

@end

/// 公交站线路返回
@interface AMapBusLineSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger       count; //!< 返回公交站数目
@property (nonatomic, strong) AMapSuggestion *suggestion; //!< 关键字建议列表和城市建议列表
@property (nonatomic, strong) NSArray<AMapBusLine *> *buslines; //!< 公交线路数组，数组中存放 AMapBusLine 对象

@end

#pragma mark - AMapDistrictSearchRequest

@interface AMapDistrictSearchRequest : AMapSearchObject

@property (nonatomic, copy)   NSString *keywords; //!< 查询关键字，只支持单关键字搜索，全国范围
@property (nonatomic, assign) BOOL      requireExtension; //!< 是否返回边界坐标，默认为NO

@end

@interface AMapDistrictSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger  count; //!< 返回数目
@property (nonatomic, strong) NSArray<AMapDistrict *> *districts; //!< 行政区域 AMapDistrict 数组

@end

#pragma mark - AMapRouteSearchBaseRequest

/// 路径规划基础类，不可直接调用
@interface AMapRouteSearchBaseRequest : AMapSearchObject

@property (nonatomic, copy) AMapGeoPoint *origin; //!< 出发点
@property (nonatomic, copy) AMapGeoPoint *destination; //!< 目的地

@end

#pragma mark - AMapDrivingRouteSearchRequest

/// 驾车路径规划
@interface AMapDrivingRouteSearchRequest : AMapRouteSearchBaseRequest

/// 驾车导航策略：0-速度优先（时间）；1-费用优先（不走收费路段的最快道路）；2-距离优先；3-不走快速路；4-结合实时交通（躲避拥堵）；5-多策略（同时使用速度优先、费用优先、距离优先三个策略）；6-不走高速；7-不走高速且避免收费；8-躲避收费和拥堵；9-不走高速且躲避收费和拥堵
@property (nonatomic, assign) NSInteger strategy; //!< 驾车导航策略([default = 0])

@property (nonatomic, copy) NSArray<AMapGeoPoint *> *waypoints; //!< 途经点 AMapGeoPoint 数组，最多支持16个途经点
@property (nonatomic, copy) NSArray<AMapGeoPolygon *> *avoidpolygons; //!< 避让区域 AMapGeoPolygon 数组，最多支持100个避让区域，每个区域16个点
@property (nonatomic, copy) NSString *avoidroad; //!< 避让道路名

@property (nonatomic, copy) NSString *originId; //!< 出发点 POI ID
@property (nonatomic, copy) NSString *destinationId; //!< 目的地 POI ID

@property (nonatomic, assign) BOOL requireExtension; //!< 是否返回扩展信息，默认为 NO

@end

#pragma mark - AMapWalkingRouteSearchRequest

/// 步行路径规划
@interface AMapWalkingRouteSearchRequest : AMapRouteSearchBaseRequest

/// 是否提供备选步行方案: 0-只提供一条步行方案; 1-提供备选步行方案(有可能无备选方案)
@property (nonatomic, assign) NSInteger multipath; //!< 是否提供备选步行方案([default = 0])
@end

#pragma mark - AMapTransitRouteSearchRequest

/// 公交路径规划
@interface AMapTransitRouteSearchRequest : AMapRouteSearchBaseRequest

/// 公交换乘策略：0-最快捷模式；1-最经济模式；2-最少换乘模式；3-最少步行模式；4-最舒适模式；5-不乘地铁模式
@property (nonatomic, assign) NSInteger strategy;  //!< 公交换乘策略([default = 0])

@property (nonatomic, copy)   NSString *city; //!< 城市, 必填
@property (nonatomic, copy)   NSString *destinationCity; //!< 目的城市, 跨城时需要填写，否则会出错

@property (nonatomic, assign) BOOL nightflag; //!< 是否包含夜班车，默认为 NO
@property (nonatomic, assign) BOOL requireExtension; //!< 是否返回扩展信息，默认为 NO

@end

#pragma mark - AMapRouteSearchResponse

/// 路径规划返回
@interface AMapRouteSearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger count; //!< 路径规划信息数目
@property (nonatomic, strong) AMapRoute *route; //!< 路径规划信息

@end

#pragma mark - AMapWeatherSearchWeather

/// 天气查询类型
typedef NS_ENUM(NSInteger, AMapWeatherType)
{
    AMapWeatherTypeLive = 1, //<! 实时
    AMapWeatherTypeForecast //<! 预报
};

/// 天气查询请求
@interface AMapWeatherSearchRequest : AMapSearchObject

@property (nonatomic, copy)   NSString        *city; //!< 城市名称，支持cityname及adcode
@property (nonatomic, assign) AMapWeatherType  type; //!< 气象类型，Live为实时天气，Forecast为后三天预报天气，默认为Live

@end

/// 天气查询返回
@interface AMapWeatherSearchResponse : AMapSearchObject

@property (nonatomic, strong) NSArray<AMapLocalWeatherLive *> *lives; //!< 实时天气数据信息 AMapLocalWeatherLive 数组，仅在请求实时天气时有返回。

@property (nonatomic, strong) NSArray<AMapLocalWeatherForecast *> *forecasts; //!< 预报天气数据信息 AMapLocalWeatherForecast 数组，仅在请求预报天气时有返回。

@end

#pragma mark - AMapNearbySearchRequest

/// 附近搜索距离类型
typedef NS_ENUM(NSInteger, AMapNearbySearchType)
{
    AMapNearbySearchTypeLiner   = 0, //!< 直线距离
    AMapNearbySearchTypeDriving = 1, //!< 驾车行驶距离
};

/// 附近搜索请求
@interface AMapNearbySearchRequest : AMapSearchObject

@property (nonatomic, copy)   AMapGeoPoint *center; //<! 中心点坐标
@property (nonatomic, assign) NSInteger radius; //<! 查询半径，范围：[0, 10000]，单位：米 [default = 1000]
@property (nonatomic, assign) AMapNearbySearchType searchType; //<! 搜索距离类型，默认为直线距离
@property (nonatomic, assign) NSInteger timeRange; //<! 检索时间范围，超过24小时的数据无法返回，范围[5, 24*60*60] 单位：秒 [default = 1800]
@property (nonatomic, assign) NSInteger limit; //<! 返回条数，范围[1, 100], 默认30

@end

/// 附近搜索返回
@interface AMapNearbySearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger count; //!< 结果总条数
@property (nonatomic, strong) NSArray<AMapNearbyUserInfo *> *infos; //!< 周边用户信息 AMapNearbyUserInfo 数组

@end

#pragma mark - AMapCloudSearchBaseRequest

/// 云图搜索结果排序
typedef NS_ENUM(NSInteger, AMapCloudSortType)
{
    AMapCloudSortTypeDESC      = 0, //<! 降序
    AMapCloudSortTypeASC       = 1  //<! 升序
};

/// 云图搜索请求基类
@interface AMapCloudSearchBaseRequest : AMapSearchObject

/// 要查询的表格ID, 必选
@property (nonatomic, copy) NSString *tableID;

/**
 *  筛选条件数组, 可选, 对建立了排序筛选索引的字段进行筛选(系统默认为：_id，_name，_address，_updatetime，_createtime建立排序筛选索引).
 *  说明：
 *  1.支持对文本字段的精确匹配；支持对整数和小数字段的连续区间筛选;
 *  2.示例:数组{@"type:酒店", @"star:[3,5]"}的含义,等同于SQL语句:WHERE type = "酒店" AND star BETWEEN 3 AND 5
 *  注意: 所设置的过滤条件中不能含有&、#、%等URL的特殊符号。
 */
@property (nonatomic, strong) NSArray<NSString *> *filter;

/**
 *  排序字段名, 可选.
 *  说明：
 *  1.支持按建立了排序筛选索引的整数或小数字段进行排序：sortFields = @"字段名"；
 *  2.系统预设的字段(忽略sortType)：
 *  _distance：坐标与中心点距离升序排序，仅在周边检索时有效；
 *  _weight：权重降序排序，当存在keywords时有效；
 *  3.默认值：
 *  当keywords存在时：默认按预设字段_weight排序；
 *  当keywords不存在时，默认按预设字段_distance排序；
 *  按建立了排序筛选索引的整数或小数字段进行排序时，若不填升降序，则默认按升序排列；
 */
@property (nonatomic, copy) NSString *sortFields;

/// 可选, 排序方式(默认升序)
@property (nonatomic, assign) AMapCloudSortType sortType;

/// 可选, 每页记录数(每页最大记录数100, 默认20)
@property (nonatomic, assign) NSInteger offset;

/// 可选, 当前页数(>=1, 默认1)
@property (nonatomic, assign) NSInteger page;

@end

#pragma mark - AMapCloudPlaceAroundSearchRequest

/// 云图周边搜请求
@interface AMapCloudPOIAroundSearchRequest : AMapCloudSearchBaseRequest

/// 必填，中心点坐标。
@property (nonatomic, copy)   AMapGeoPoint *center; //<! 必填, 中心点坐标

/// 可选，查询半径（默认值为3000），单位：米。
@property (nonatomic, assign) NSInteger     radius; //<! 可选, 查询半径(单位:米;默认:3000)

/**
 *  可选，搜索关键词。
 *  说明：
 *  1. 请先在云图数据管理台添加或删除文本索引字段，系统默认为 _name 和 _address 建立文本索引；
 *  2.支持关键字模糊检索，即对建立【文本索引字段】对应列内容进行模糊检索；如 keywords = @"工商银行"，检索返回已建立文本索引列值中包含“工商”或者“银行”或者“工商银行”关键字的POI结果集。
 *  3. 支持关键字“或”精准检索，即对建立【文本索引字段】对应列内容进行多关键字检索；如 keywords = @"招商银行|华夏银行|工商银行"，检索返回已建立索引列值中包含“招商银行”或者“华夏银行”或者“工商银行”的POI结果集，不会返回检索词切分后，如仅包含“招商”或者“银行”的POI集。
 *  4. 可赋值为空值，即 keywords = @" " 表示空值；
 *  5. 若 city = @"城市名"，keywords = @" " 或者 keywords = @"关键字"，返回对应城市的全部数据或对应关键字的数据；
 *  6. 一次请求最多返回2000条数据。
 *  注意: 所设置的keywords中不能含有&、#、%等URL的特殊符号。
 */
@property (nonatomic, copy) NSString *keywords;

@end

/// 云图polygon区域查询请求
@interface AMapCloudPOIPolygonSearchRequest : AMapCloudSearchBaseRequest

/// 必填，多边形。
@property (nonatomic, copy) AMapGeoPolygon *polygon; //<! 必填,多边形

/**
 *  可选，搜索关键词。
 *  说明：
 *  1. 请先在云图数据管理台添加或删除文本索引字段，系统默认为 _name 和 _address 建立文本索引；
 *  2.支持关键字模糊检索，即对建立【文本索引字段】对应列内容进行模糊检索；如 keywords = @"工商银行"，检索返回已建立文本索引列值中包含“工商”或者“银行”或者“工商银行”关键字的POI结果集。
 *  3. 支持关键字“或”精准检索，即对建立【文本索引字段】对应列内容进行多关键字检索；如 keywords = @"招商银行|华夏银行|工商银行"，检索返回已建立索引列值中包含“招商银行”或者“华夏银行”或者“工商银行”的POI结果集，不会返回检索词切分后，如仅包含“招商”或者“银行”的POI集。
 *  4. 可赋值为空值，即 keywords = @" " 表示空值；
 *  5. 若 city = @"城市名"，keywords = @" " 或者 keywords = @"关键字"，返回对应城市的全部数据或对应关键字的数据；
 *  6. 一次请求最多返回2000条数据。
 *  注意: 所设置的keywords中不能含有&、#、%等URL的特殊符号。
 */
@property (nonatomic, copy) NSString *keywords;

@end

/// 云图ID查询请求
@interface AMapCloudPOIIDSearchRequest : AMapCloudSearchBaseRequest

@property (nonatomic, assign) NSInteger uid; //<! 必填,POI的ID

@end

/// 云图本地查询请求
@interface AMapCloudPOILocalSearchRequest : AMapCloudSearchBaseRequest

/**
 *  必填，搜索关键词。
 *  说明：
 *  1. 请先在云图数据管理台添加或删除文本索引字段，系统默认为 _name 和 _address 建立文本索引；
 *  2.支持关键字模糊检索，即对建立【文本索引字段】对应列内容进行模糊检索；如 keywords = @"工商银行"，检索返回已建立文本索引列值中包含“工商”或者“银行”或者“工商银行”关键字的POI结果集。
 *  3. 支持关键字“或”精准检索，即对建立【文本索引字段】对应列内容进行多关键字检索；如 keywords = @"招商银行|华夏银行|工商银行"，检索返回已建立索引列值中包含“招商银行”或者“华夏银行”或者“工商银行”的POI结果集，不会返回检索词切分后，如仅包含“招商”或者“银行”的POI集。
 *  4. 可赋值为空值，即 keywords = @" " 表示空值；
 *  5. 若 city = @"城市名"，keywords = @" " 或者 keywords = @"关键字"，返回对应城市的全部数据或对应关键字的数据；
 *  6. 一次请求最多返回2000条数据。
 *  注意: 所设置的keywords中不能含有&、#、%等URL的特殊符号。
 */
@property (nonatomic, copy) NSString *keywords;

/// 必填，城市名称 说明：1. 支持全国/省/市/区县行政区划范围的检索；2. city = @"全国"，即对用户全表搜索；3. 当city值设置非法或不正确时，按照 city = @"全国"返回。
@property (nonatomic, copy) NSString *city; //<! 必填,POI所在城市

@end

#pragma mark - AMapCloudPOISearchResponse

/// 云图搜索返回
@interface AMapCloudPOISearchResponse : AMapSearchObject

@property (nonatomic, assign) NSInteger  count; //<! 返回结果总数目
@property (nonatomic, strong) NSArray<AMapCloudPOI *>   *POIs; //<! 返回的结果, AMapCloudPOI 数组

@end

#pragma mark - AMapShareSearchBaseRequest

/// 短串分享搜索请求基类, 请使用具体的子类。
@interface AMapShareSearchBaseRequest : AMapSearchObject

@end

/// 位置短串分享请求
@interface AMapLocationShareSearchRequest : AMapShareSearchBaseRequest

@property (nonatomic, copy) AMapGeoPoint *location; //<! 必填, 位置坐标
@property (nonatomic, copy) NSString     *name; //<! 位置名称，请不要包含【,%&@#】等特殊符号。

@end

/// 兴趣点短串分享请求
@interface AMapPOIShareSearchRequest : AMapShareSearchBaseRequest

@property (nonatomic, copy) NSString     *uid; //<! POI的ID，如果有ID则指定POI，否则按name查询。
@property (nonatomic, copy) AMapGeoPoint *location; //<! 坐标
@property (nonatomic, copy) NSString     *name; //<! 名称，请不要包含【,%&@#】等特殊符号。
@property (nonatomic, copy) NSString     *address; //<! 地址，请不要包含【,%&@#】等特殊符号。

@end

/// 路径规划短串分享请求
@interface AMapRouteShareSearchRequest : AMapShareSearchBaseRequest

/// 驾车:0-速度最快（时间）; 1-避免收费（不走收费路段的最快道路）; 2-距离优先; 3-不走高速; 4-结合实时交通（躲避拥堵）; 5-不走高速且避免收费; 6-不走高速且躲避拥堵; 7-躲避收费和拥堵; 8-不走高速且躲避收费和拥堵
/// 公交:0-最快捷; 1-最经济; 2-最少换乘; 3-最少步行; 4-最舒适; 5-不乘地铁;
/// 步行，无策略，均一样
@property (nonatomic, assign) NSInteger     strategy; //<! 默认为0
@property (nonatomic, assign) NSInteger     type; //<! Route的type，0为驾车，1为公交，2为步行，默认为0，超出范围为0。
@property (nonatomic, copy)   AMapGeoPoint *startCoordinate; //<! 起点坐标
@property (nonatomic, copy)   AMapGeoPoint *destinationCoordinate; //<! 终点坐标
@property (nonatomic, copy)   NSString     *startName; //<! 起点名称，默认为“已选择的位置”，请不要包含【,%&@#】等特殊符号
@property (nonatomic, copy)   NSString     *destinationName; //<! 终点名称，默认为“已选择的位置”，请不要包含【,%&@#】等特殊符号

@end

/// 导航短串分享请求
@interface AMapNavigationShareSearchRequest : AMapShareSearchBaseRequest

/// 驾车:0-速度最快（时间）; 1-避免收费（不走收费路段的最快道路）; 2-距离优先; 3-不走高速; 4-结合实时交通（躲避拥堵）; 5-不走高速且避免收费; 6-不走高速且躲避拥堵; 7-躲避收费和拥堵; 8-不走高速且躲避收费和拥堵
@property (nonatomic, assign) NSInteger     strategy; //!< 默认为0，超出范围为0

@property (nonatomic, copy)   AMapGeoPoint *startCoordinate; //<! 起点坐标，若跳转到高德地图，默认更换为定位坐标
@property (nonatomic, copy)   AMapGeoPoint *destinationCoordinate; //<! 终点坐标

@end

@interface AMapShareSearchResponse : AMapSearchObject

@property (nonatomic, copy) NSString *shareURL; //<! 转换后的短串

@end
