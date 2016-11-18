//
//  MAMapURLSearchType.h
//  MAMapKitNew
//
//  Created by xiaoming han on 15/5/25.
//  Copyright (c) 2015年 xiaoming han. All rights reserved.
//

/// 驾车策略
typedef NS_ENUM(NSInteger, AMapDrivingStrategy)
{
    AMapDrivingStrategyFastest  = 0, //速度最快
    AMapDrivingStrategyMinFare  = 1, //避免收费
    AMapDrivingStrategyShortest = 2, //距离最短
    
    AMapDrivingStrategyNoHighways   = 3, //不走高速
    AMapDrivingStrategyAvoidCongestion = 4, //躲避拥堵
    
    AMapDrivingStrategyAvoidHighwaysAndFare    = 5, //不走高速且避免收费
    AMapDrivingStrategyAvoidHighwaysAndCongestion = 6, //不走高速且躲避拥堵
    AMapDrivingStrategyAvoidFareAndCongestion  = 7, //躲避收费和拥堵
    AMapDrivingStrategyAvoidHighwaysAndFareAndCongestion = 8 //不走高速躲避收费和拥堵
};

/// 公交策略
typedef NS_ENUM(NSInteger, AMapTransitStrategy)
{
    AMapTransitStrategyFastest = 0,//最快捷
    AMapTransitStrategyMinFare = 1,//最经济
    AMapTransitStrategyMinTransfer = 2,//最少换乘
    AMapTransitStrategyMinWalk = 3,//最少步行
    AMapTransitStrategyMostComfortable = 4,//最舒适
    AMapTransitStrategyAvoidSubway = 5,//不乘地铁
};

/// 路径规划类型
typedef NS_ENUM(NSInteger, AMapRouteSearchType)
{
    AMapRouteSearchTypeDriving = 0, //驾车
    AMapRouteSearchTypeTransit = 1, //公交
    AMapRouteSearchTypeWalking = 2, //步行
};


