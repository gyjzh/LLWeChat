//
//  LLAudioManager.h
//  LLWeChat
//
//  Created by GYJZH on 8/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLAudioRecordDelegate.h"
#import "LLAudioPlayDelegate.h"
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LLErrorRecordType) {
    kLLErrorRecordTypeAuthorizationDenied,
    kLLErrorRecordTypeInitFailed,
    kLLErrorRecordTypeCreateAudioFileFailed,
    kLLErrorRecordTypeMultiRequest,
    kLLErrorRecordTypeRecordError,
};

typedef NS_ENUM(NSInteger, LLErrorPlayType) {
    kLLErrorPlayTypeInitFailed = 0,
    kLLErrorPlayTypeFileNotExist,
    kLLErrorPlayTypePlayError,
};


@interface LLAudioManager : NSObject

@property (nonatomic) BOOL isRecording;

@property (nonatomic) BOOL isPlaying;


+ (instancetype)sharedManager;

- (void)startRecordingWithDelegate:(id<LLAudioRecordDelegate>)delegate;

- (void)stopRecording;

- (void)cancelRecording;

- (void)requestRecordPermission:(void (^)(AVAudioSessionRecordPermission recordPermission))callback;

- (void)startPlayingWithPath:(NSString *)aFilePath
                        delegate:(id<LLAudioPlayDelegate>)delegate
                        userinfo:(id)userinfo
                 continuePlaying:(BOOL)continuePlaying;

//关闭整个播放Session
- (void)stopPlaying;

//仅仅停止当前文件的播放，不关闭Session
- (void)stopCurrentPlaying;

@end

NS_ASSUME_NONNULL_END
