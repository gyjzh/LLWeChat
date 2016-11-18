//
//  LLPushOptions.h
//  LLWeChat
//
//  Created by GYJZH on 9/15/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLSDK.h"

/*!
 *  \~chinese
 *  推送消息的显示风格
 */
typedef NS_ENUM(NSInteger, LLPushDisplayStyle) {
    //简单显示"您有一条新消息"
    kLLPushDisplayStyleSimpleBanner = EMPushDisplayStyleSimpleBanner,
    //显示消息内容
    kLLPushDisplayStyleMessageSummary = EMPushDisplayStyleMessageSummary
};

/*!
 *  \~chinese
 *  推送免打扰设置
 */
typedef NS_ENUM(NSInteger, LLPushNoDisturbSetting) {
    //全天免打扰
    kLLPushNoDisturbSettingDay = EMPushNoDisturbStatusDay,
    //自定义时间段免打扰
    kLLPushNoDisturbSettingCustom = EMPushNoDisturbStatusCustom,
    //关闭免打扰
    kLLPushNoDisturbSettingClose = EMPushNoDisturbStatusClose,
};


@interface LLPushOptions : NSObject

@property (nonatomic) LLPushDisplayStyle displayStyle;

@property (nonatomic) LLPushNoDisturbSetting noDisturbSetting;


/*!
 *  \~chinese
 *  消息推送免打扰开始时间，小时，暂时只支持整点（小时）
 */
@property (nonatomic) NSInteger noDisturbingStartH;

/*!
 *  \~chinese
 *  消息推送免打扰结束时间，小时，暂时只支持整点（小时）
 */
@property (nonatomic) NSInteger noDisturbingEndH;

//消息提示时，是否允许播放声音
@property (nonatomic) BOOL isAlertSoundEnabled;

//小时提示时，是否允许振动
@property (nonatomic) BOOL isVibrateEnabled;

//朋友圈照片更新
@property (nonatomic) BOOL isMomentsUpdateEnabled;

@end
