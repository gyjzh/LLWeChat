//
//  AMapSearchServices.h
//  AMapSearchKit
//
//  Created by xiaoming han on 15/6/18.
//  Copyright (c) 2015年 xiaoming han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMapServices : NSObject

+ (AMapServices *)sharedServices;

/**
 *  APIkey。设置key，需要绑定对应的bundle id。
 */
@property (nonatomic, copy) NSString *apiKey;

/**
 *  是否开启HTTPS，默认为NO。
 *  目前已支持服务：key鉴权、云图（不支持iOS9 SSL限制）、搜索（短串分享除外）。
 */
@property (nonatomic, assign) BOOL enableHTTPS;

/**
 *  是否启用崩溃日志上传。默认为YES, 只有在真机上设置有效。
 *  开启崩溃日志上传有助于我们更好的了解SDK的状况，可以帮助我们持续优化和改进SDK。
 *  需要注意的是，我是通过设置NSUncaughtExceptionHandler来捕获异常的，如果您的APP中使用了其他收集崩溃日志的SDK，或者自己有设置NSUncaughtExceptionHandler的话，请保证 AMapServices 的初始化是在其他设置NSUncaughtExceptionHandler操作之后进行的，我们的handler会再处理完异常后调用前一次设置的handler，保证之前设置的handler会被执行。
 */
@property (nonatomic, assign) BOOL crashReportEnabled;

@end
