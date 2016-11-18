//
//  LLUtils+Audio.h
//  LLWeChat
//
//  Created by GYJZH on 9/14/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"

typedef NS_ENUM(NSInteger, LLSoundVolumeLevel) {
    kLLSoundVolumeLevelHight = 13,
    kLLSoundVolumeLevelMiddle = 8,
    kLLSoundVolumeLevelLow = 3,
    kLLSoundVolumeLevelMute = 0
};

@interface LLUtils (Audio)

//是否支持声音输入
+ (BOOL)hasMicphone;

//系统音量，只能有用户设置，分为16个等级，返回值范围为：0-1
+ (float)currentVolumn;

+ (NSInteger)currentVolumeLevel;

+ (void)playShortSound:(NSString *)soundName soundExtension:(NSString *)soundExtension;

// 播放接收到新消息时的声音
+ (void)playNewMessageSound;

//播放发送消息成功时的声音
+ (void)playSendMessageSound;

// 震动
+ (void)playVibration;

+ (void)playNewMessageSoundAndVibration;

+ (void)configAudioSessionForPlayback;

@end
