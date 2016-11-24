//
//  LLAudioRecordDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLAudioRecordDelegate <NSObject>
@optional

- (void)audioRecordAuthorizationDidGranted;

/*
 * 录音是否成功开始
 * error=nil:录音开始，没有错误；否则录音启动失败，error包含错误信息
 *
 */
- (void)audioRecordDidStartRecordingWithError:(NSError *)error;

/*
 * averagePower，录音音量
 */
- (void)audioRecordDidUpdateVoiceMeter:(double)averagePower;

//录音时长变化，以秒为单位
- (void)audioRecordDurationDidChanged:(NSTimeInterval)duration;

//录音最长时间，默认为MAX_RECORD_TIME_ALLOWED = 60秒
- (NSTimeInterval)audioRecordMaxRecordTime;

- (void)audioRecordDidFinishSuccessed:(NSString *)voiceFilePath duration:(CFTimeInterval)duration;

- (void)audioRecordDidFailed;

- (void)audioRecordDidCancelled;

- (void)audioRecordDurationTooShort;

//当设置的最长录音时间到后，派发该消息，但不停止录音，由delegate停止录音
//方便delegate做一些倒计时之类的动作
- (void)audioRecordDurationTooLong;

@end
