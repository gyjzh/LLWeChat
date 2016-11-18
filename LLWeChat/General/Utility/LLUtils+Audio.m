//
//  LLUtils+Audio.m
//  LLWeChat
//
//  Created by GYJZH on 9/14/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils+Audio.h"
@import AVFoundation;

/**
 *  系统铃声播放完成后的回调
 */
void _SystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}

@implementation LLUtils (Audio)

+ (BOOL)hasMicphone {
    return [AVAudioSession sharedInstance].isInputAvailable;
}


#pragma mark 获得当前的音量
+ (float)currentVolumn {
    float volume;
    //以下API已废弃
//    UInt32 dataSize = sizeof(float);
//    
//    AudioSessionGetProperty (kAudioSessionProperty_CurrentHardwareOutputVolume,
//                             &dataSize,
//                             &volume);
    volume = [AVAudioSession sharedInstance].outputVolume;
    
    return volume;
}

+ (NSInteger)currentVolumeLevel {
    return round(16 *[self currentVolumn]);
}

// 播放短声音
+ (void)playShortSound:(NSString *)soundName soundExtension:(NSString *)soundExtension {
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:soundName withExtension:soundExtension];
    // 创建系统声音，同时返回一个ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          _SystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(soundID);
    
}

// 震动
+ (void)playVibration
{
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
            NULL, // uses the main run loop
            NULL, // uses kCFRunLoopDefaultMode
            _SystemSoundFinishedPlayingCallback, // the name of our custom callback function
            NULL // for user data, but we don't need to do that in this case, so we just pass NULL
    );

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


+ (void)playNewMessageSound {
    [self playShortSound:@"in" soundExtension:@"caf"];
}

+ (void)playSendMessageSound {
    [self playShortSound:@"sendmsg" soundExtension:@"caf"];
}

+ (void)playNewMessageSoundAndVibration {
    // 收到消息时，播放音频
    [self playNewMessageSound];
    // 收到消息时，震动
    [self playVibration];
}

+ (void)configAudioSessionForPlayback {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
    
}


@end
