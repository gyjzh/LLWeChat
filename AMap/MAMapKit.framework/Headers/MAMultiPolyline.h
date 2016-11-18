//
//  MAMultiPolyline.h
//  MapKit_static
//
//  Created by yi chen on 12/11/15.
//  Copyright © 2015 songjian. All rights reserved.
//

#import "MAPolyline.h"

/*!
 @brief 此类用于定义一个由多个点相连的多段线，绘制时支持分段采用不同颜色绘制，点与点之间尾部相连但第一点与最后一个点不相连, 通常MAMultiPolyline是MAMultiColoredPolylineRenderer（分段颜色绘制）model
 */
@interface MAMultiPolyline : MAPolyline

/*!
 @brief 颜色索引数组，成员为NSNumber,且为非负数，负数按0处理
 */
@property (nonatomic, strong, readonly) NSArray *drawStyleIndexes;

/*!
 @brief 分段绘制，根据map point数据生成多段线
 
 分段颜色绘制：其对应的MAMultiColoredPolylineRenderer必须设置strokeColors属性
 
 @param points 指定的直角坐标点数组
 @param count 坐标点的个数
 @param drawStyleIndexes 颜色索引数组，成员为NSNumber,且为非负数，负数按0处理
 @return 新生成的折线对象
 */
+ (instancetype)polylineWithPoints:(MAMapPoint *)points count:(NSUInteger)count drawStyleIndexes:(NSArray*)drawStyleIndexes;

/*!
 @brief 分段绘制，根据经纬度坐标数据生成多段线
 
 分段颜色绘制：其对应的MAMultiColoredPolylineRenderer必须设置strokeColors属性
 
 @param coords 指定的经纬度坐标点数组
 @param count 坐标点的个数
 @param drawStyleIndexes 颜色索引数组，成员为NSNumber,且为非负数，负数按0处理
 @return 新生成的折线对象
 */
+ (instancetype)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count drawStyleIndexes:(NSArray*)drawStyleIndexes;

@end
