//
//  AMapNearbyUploadInfo.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/9/6.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/// 上传经纬度类型
typedef NS_ENUM(NSInteger, AMapSearchCoordinateType)
{
    AMapSearchCoordinateTypeGPS   = 1, //!< 标准GPS坐标
    AMapSearchCoordinateTypeAMap  = 2, //!< 高德坐标
};


/// 附近搜索上传信息
@interface AMapNearbyUploadInfo : NSObject<NSCopying>

/**
 *  用户唯一标识，不能为空，否则上传会失败。
 *  长度不超过32字符，只能包含英文、数字、下划线、短横杠.
 */
@property (nonatomic, copy) NSString *userID;

/// 坐标类型，默认是 AMapSearchCoordinateTypeAMap
@property (nonatomic, assign) AMapSearchCoordinateType coordinateType;

/// 用户位置经纬度。
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
