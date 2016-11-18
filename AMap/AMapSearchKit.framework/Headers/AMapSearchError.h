//
//  AMapSearchError.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/7/29.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#ifndef AMapSearchKit_AMapSearchError_h
#define AMapSearchKit_AMapSearchError_h

/** AMapSearch errorDomain */
extern NSString * const AMapSearchErrorDomain;

/** AMapSearch errorCode */
typedef NS_ENUM(NSInteger, AMapSearchErrorCode)
{
    AMapSearchErrorOK                     = 1000,//!< 没有错误
    AMapSearchErrorInvalidSignature       = 1001,//!< 无效签名
    AMapSearchErrorInvalidUserKey         = 1002,//!< key非法或过期
    AMapSearchErrorServiceNotAvailable    = 1003,//!< 没有权限使用相应的接口
    AMapSearchErrorDailyQueryOverLimit    = 1004,//!< 访问已超出日访问量
    AMapSearchErrorTooFrequently          = 1005,//!< 用户访问过于频繁
    AMapSearchErrorInvalidUserIP          = 1006,//!< 用户IP无效
    AMapSearchErrorInvalidUserDomain      = 1007,//!< 用户域名无效
    AMapSearchErrorInvalidUserSCode       = 1008,//!< 安全码验证错误，bundleID与key不对应
    AMapSearchErrorUserKeyNotMatch        = 1009,//!< 请求key与绑定平台不符
    AMapSearchErrorIPQueryOverLimit       = 1010,//!< IP请求超限
    AMapSearchErrorNotSupportHttps        = 1011,//!< 不支持HTTPS请求
    AMapSearchErrorInsufficientPrivileges = 1012,//!< 权限不足，服务请求被拒绝
    AMapSearchErrorUserKeyRecycled        = 1013,//!< 开发者key被删除，无法正常使用

    AMapSearchErrorInvalidResponse        = 1100,//!< 请求服务响应错误
    AMapSearchErrorInvalidEngineData      = 1101,//!< 引擎返回数据异常
    AMapSearchErrorConnectTimeout         = 1102,//!< 服务端请求链接超时
    AMapSearchErrorReturnTimeout          = 1103,//!< 读取服务结果超时
    AMapSearchErrorInvalidParams          = 1200,//!< 请求参数非法
    AMapSearchErrorMissingRequiredParams  = 1201,//!< 缺少必填参数
    AMapSearchErrorIllegalRequest         = 1202,//!< 请求协议非法
    AMapSearchErrorServiceUnknown         = 1203,//!< 其他服务端未知错误

    AMapSearchErrorClientUnknown          = 1800,//!< 客户端未知错误，服务返回结果为空或其他错误
    AMapSearchErrorInvalidProtocol        = 1801,//!< 协议解析错误，通常是返回结果无法解析
    AMapSearchErrorTimeOut                = 1802,//!< 连接超时
    AMapSearchErrorBadURL                 = 1803,//!< URL异常
    AMapSearchErrorCannotFindHost         = 1804,//!< 找不到主机
    AMapSearchErrorCannotConnectToHost    = 1805,//!< 服务器连接失败
    AMapSearchErrorNotConnectedToInternet = 1806,//!< 连接异常，通常为没有网络的情况
    AMapSearchErrorCancelled              = 1807,//!< 连接取消

    AMapSearchErrorTableIDNotExist        = 2000,//!< table id 格式不正确
    AMapSearchErrorIDNotExist             = 2001,//!< id 不存在
    AMapSearchErrorServiceMaintenance     = 2002,//!< 服务器维护中
    AMapSearchErrorEngineTableIDNotExist  = 2003,//!< key对应的table id 不存在
    AMapSearchErrorInvalidNearbyUserID    = 2100,//!< 找不到对应userID的信息
    AMapSearchErrorNearbyKeyNotBind       = 2101,//!< key未开通“附近”功能

    AMapSearchErrorOutOfService           = 3000,//!< 规划点（包括起点、终点、途经点）不在中国范围内
    AMapSearchErrorNoRoadsNearby          = 3001,//!< 规划点（包括起点、终点、途经点）附近搜不到道路
    AMapSearchErrorRouteFailed            = 3002,//!< 路线计算失败，通常是由于道路连通关系导致
    AMapSearchErrorOverDirectionRange     = 3003,//!< 起点终点距离过长

    AMapSearchErrorShareLicenseExpired    = 4000,//!< 短串分享认证失败
    AMapSearchErrorShareFailed            = 4001,//!< 短串请求失败
};

#endif
