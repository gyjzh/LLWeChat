//
//  LLAudioManager.m
//  LLWeChat
//
//  Created by GYJZH on 8/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLAudioManager.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "EMVoiceConverter.h"

#define ERROR_AUDIO_DOMAIN @"LLAudioManager_Domain"

//amr临时目录
#define AMR_AUDIO_TMP_FOLDER @"amrAudioTmp"

//wav临时目录
#define WAV_AUDIO_TMP_FOLDER @"wavAudioTmp"

static LLAudioManager *instance;

@interface LLAudioManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) id<LLAudioRecordDelegate> recordDelegate;
@property (weak, nonatomic) id<LLAudioPlayDelegate> playerDelegate;
@property (nonatomic) id userinfo;

@property (nonatomic) AVAudioSession *audioSession;

@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) NSDictionary *recordSetting;

@property (nonatomic) dispatch_block_t block;

@property (nonatomic, copy) NSString *previousCategory;

@property (nonatomic) BOOL isCancelRecording;
@property (nonatomic) BOOL isFinishRecording;

@end



@implementation LLAudioManager {
    CFTimeInterval startTime;
    NSTimeInterval maxRecordTime;
    NSTimer *timer;
    
    NSDate *startDate;
//    NSDate *endDate;
    NSTimeInterval endDuration;
    BOOL isPlaySessionActive;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLAudioManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.audioSession = [AVAudioSession sharedInstance];
    }
    
    return self;
}

- (NSDictionary *)recordSetting {
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          //采样率,影响音频的质量）
                          [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                          ////设置录音格式
                          [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                          //线性采样位数  8、16、24、32
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                          //录音通道数  1 或 2
                          [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                          nil];
    }
    
    return _recordSetting;
}


#pragma mark - 录音

- (void)requestRecordPermission:(void (^)(AVAudioSessionRecordPermission recordPermission))callback {
    switch (self.audioSession.recordPermission) {
        case AVAudioSessionRecordPermissionGranted:
            callback(AVAudioSessionRecordPermissionGranted);
            break;
        case AVAudioSessionRecordPermissionDenied:
            [self promptRecordPermissionDeniedAlert];
            
            callback(AVAudioSessionRecordPermissionDenied);
            break;
        case AVAudioSessionRecordPermissionUndetermined: {
            callback(AVAudioSessionRecordPermissionUndetermined);
            
            WEAK_SELF;
            [self.audioSession requestRecordPermission:^(BOOL granted) {
               dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [weakSelf promptRecordPermissionDeniedAlert];
                    }
                    
                   callback(granted ? AVAudioSessionRecordPermissionGranted : AVAudioSessionRecordPermissionDenied);
                }); 
            }];
        }
            break;
    }
}

- (void)checkAvailabilityWithDelegate:(id<LLAudioRecordDelegate>)delegate   callback:(void (^)(NSError *error))callback {
    if (!callback)
        return;
    [self.audioSession requestRecordPermission:^(BOOL granted) {
        //第一步：拥有访问麦克风的权限
        if (!granted) {
            NSError *error = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                 code:kLLErrorRecordTypeAuthorizationDenied
                                             userInfo:nil];
            callback(error);
            return;
        }else {
            if ([delegate respondsToSelector:@selector(audioRecordAuthorizationDidGranted)]) {
                [delegate audioRecordAuthorizationDidGranted];
            }
        }
        
        //第二步：当前麦克风未使用
        if (self.isRecording) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeMultiRequest
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第三步：设置AudioSession.category
        NSError *error;
        self.previousCategory = self.audioSession.category;
        BOOL success = [self.audioSession
                        setCategory:AVAudioSessionCategoryRecord
                        withOptions:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
        
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第四步：激活AudioSession
        error = nil;
        success = [[AVAudioSession sharedInstance]
                   setActive:YES
                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                   error:&error];
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第五步：创建临时录音文件
        NSURL *tmpAudioFile = [self.class wavPathWithName:[self.class randomFileName]];
        if (!tmpAudioFile) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeCreateAudioFileFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //第六步：创建AVAudioRecorder
        error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:tmpAudioFile
                                                settings:self.recordSetting
                                                   error:&error];
        
        if(!_recorder || error) {
            _recorder = nil;
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeInitFailed
                                              userInfo:nil];
            callback(error1);
            return ;
        }
        
        //第七步：开始录音
        success = [self.recorder record];
        startTime = CACurrentMediaTime();
        startDate = [NSDate date];
        if (!success) {
            _recorder = nil;
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorRecordTypeRecordError
                                              userInfo:nil];
            callback(error1);
            return ;
            
        }
        
        callback(nil);
    }];
}


- (void)startRecordingWithDelegate:(id<LLAudioRecordDelegate>)delegate
{
    [self checkAvailabilityWithDelegate:delegate callback:^(NSError *error) {
        if (!error) {
            self.recordDelegate = delegate;
            self.isFinishRecording = NO;
            self.isCancelRecording = NO;
            self.isRecording = YES;
            self.recorder.delegate = self;
            
            [timer invalidate];
            SAFE_SEND_MESSAGE(self.recordDelegate, audioRecordDurationDidChanged:) {
                timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }
            
            //开启仪表计数功能,可以获取当前录音音量大小
            self.recorder.meteringEnabled = YES;
            maxRecordTime = MAX_RECORD_TIME_ALLOWED;
            SAFE_SEND_MESSAGE(delegate, audioRecordMaxRecordTime) {
                maxRecordTime = [delegate audioRecordMaxRecordTime];
            }
            
            //录音音量变化
            [self updateVoiceMeter];
            
            if ([delegate respondsToSelector:@selector(audioRecordDidStartRecordingWithError:)]) {
    
                _block = dispatch_block_create(0, ^{
                    [delegate audioRecordDidStartRecordingWithError:nil];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((MIN_RECORD_TIME_REQUIRED + 0.25) * NSEC_PER_SEC)), dispatch_get_main_queue(), _block);
            }
            
        
            
        }else {
            SAFE_SEND_MESSAGE(delegate, audioRecordDidStartRecordingWithError:) {
                [delegate audioRecordDidStartRecordingWithError:error];
            }
            
            switch (error.code) {
                case kLLErrorRecordTypeAuthorizationDenied: {
                    [self promptRecordPermissionDeniedAlert];
                    break;
                }
                case kLLErrorRecordTypeInitFailed: {
                    [LLUtils showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                    actionTitle:@"确定"];
                    break;
                }
                case kLLErrorRecordTypeMultiRequest:
                    [LLUtils showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                   actionTitle:@"确定"];
                    break;
                case kLLErrorRecordTypeCreateAudioFileFailed:
                    [LLUtils showMessageAlertWithTitle:@"无法录音" message:@"创建录音文件出错"
                                   actionTitle:@"确定"];
                    break;
                case kLLErrorRecordTypeRecordError:
                    [LLUtils showMessageAlertWithTitle:@"无法录音" message:@"无法正常访问您的麦克风"
                                   actionTitle:@"确定"];
                    break;
                default:
                    break;
                    
            }
        }
        
    }];
    
}

- (void)promptRecordPermissionDeniedAlert {
    [LLUtils showMessageAlertWithTitle:@"无法录音" message:RECORD_AUTHORIZATION_DENIED_TEXT
                           actionTitle:@"好"];
}

//处理音量变化
- (void)updateVoiceMeter {
    WEAK_SELF;
    __block BOOL isSendMsg = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(weakSelf.isRecording) {
            [weakSelf.recorder updateMeters];
            float averagePower = [weakSelf.recorder peakPowerForChannel:0];
            double lowPassResults = pow(10, (0.05 * averagePower)) * 10;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.recordDelegate audioRecordDidUpdateVoiceMeter:lowPassResults];
            });
            
            if (weakSelf.recorder.currentTime >= maxRecordTime &&!isSendMsg) {
                isSendMsg = YES;
                SAFE_SEND_MESSAGE(weakSelf.recordDelegate, audioRecordDurationTooLong) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.recordDelegate audioRecordDurationTooLong];
                    });
                }
            }
            
            [NSThread sleepForTimeInterval:0.05];
        }
    });
}

- (void)timerHandler:(NSTimer *)timer {
    [self.recordDelegate audioRecordDurationDidChanged:self.recorder.currentTime];
}

/**
 *  停止录音
 */
- (void)stopRecording {
    if(!self.isRecording){
        return;
    }
    
    //录音时间过短，按照取消录音对待
    if(self.recorder.currentTime < MIN_RECORD_TIME_REQUIRED){
        self.isFinishRecording = NO;
        self.isCancelRecording = YES;
        
        [self willStopRecord];
        SAFE_SEND_MESSAGE(self.recordDelegate, audioRecordDurationTooShort) {
            [self.recordDelegate audioRecordDurationTooShort];
        }
        
    }else {
        self.isFinishRecording = YES;
        self.isCancelRecording = NO;
    
        [self willStopRecord];
    }
    
}


/**
 *  取消录音
 */
- (void)cancelRecording {
    if(!self.isRecording){
        return;
    }

    self.isFinishRecording = NO;
    self.isCancelRecording = YES;
    [self willStopRecord];
    SAFE_SEND_MESSAGE(self.recordDelegate, audioRecordDidCancelled) {
        [self.recordDelegate audioRecordDidCancelled];
    }
}


- (void)willStopRecord {
    endDuration = _recorder.currentTime;
    if (_recorder.isRecording)
        [self.recorder stop]; //stop后会调用代理finishing方法
//    endDate = [NSDate date];
    self.isRecording = NO;
    
    if (!dispatch_block_testcancel(_block))
        dispatch_block_cancel(_block);
    _block = nil;
}

- (void)didStopRecord {
    _recorder.delegate = nil;
    _recorder = nil;
    self.recordDelegate = nil;
    self.isRecording = NO;
    self.isFinishRecording = NO;
    self.isCancelRecording = NO;
    maxRecordTime = 1<<10;
    startDate = nil;
//    endDate = nil;
    endDuration = 0;

    if (self.previousCategory.length > 0) {
        [self.audioSession setCategory:self.previousCategory error:nil];
        self.previousCategory = nil;
    }
    
    [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}


#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
    NSString *recordPath = [[_recorder url] path];
    
    if (!flag) {
        if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailed)]) {
            [self.recordDelegate audioRecordDidFailed];
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordPath error:nil];

    }else if (self.isFinishRecording) {
        //录音格式转换，从wav转为amr
        NSString *amrFilePath = [[recordPath stringByDeletingPathExtension]
                                 stringByAppendingPathExtension:@"amr"];
        BOOL convertResult = [self convertWAV:recordPath toAMR:amrFilePath];
        if (convertResult) {
            if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFinishSuccessed:duration:)]) {
                [self.recordDelegate audioRecordDidFinishSuccessed:amrFilePath duration:endDuration];
            }
        }else {
            if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailed)]) {
                [self.recordDelegate audioRecordDidFailed];
            }
        }
        
        // 删除录的wav
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordPath error:nil];
    }else if (self.isCancelRecording) {
        // 删除录的wav
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordPath error:nil];
    }
    
    [self didStopRecord];

}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur");
    if ([self.recordDelegate respondsToSelector:@selector(audioRecordDidFailed)]) {
        [self.recordDelegate audioRecordDidFailed];
    }
    
    [self didStopRecord];
}




#pragma mark - 播放录音

- (void)checkAvailabilityWithFile:(NSString *)amrFileName callback:(void (^)(NSError *error))callback {
    [self stopCurrentPlaying];
    
    NSError *error;
    if (!isPlaySessionActive) {
        //设置AudioSession.category
        error = nil;
        self.previousCategory = self.audioSession.category;
        BOOL success = [self.audioSession
                        setCategory:AVAudioSessionCategoryPlayback
                        withOptions:AVAudioSessionCategoryOptionDuckOthers
                        error:&error];
        
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorPlayTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }
        
        //激活AudioSession
        error = nil;
        success = [[AVAudioSession sharedInstance]
                   setActive:YES
                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                   error:&error];
        if (!success || error) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorPlayTypeInitFailed
                                              userInfo:nil];
            
            callback(error1);
            return;
        }

    }

        
    //保证WAV格式录音文件存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *wavFilePath = [[amrFileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    if (![fileManager fileExistsAtPath:wavFilePath]) {
        BOOL covertRet = [self convertAMR:amrFileName toWAV:wavFilePath];
        if (!covertRet) {
            NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                                  code:kLLErrorPlayTypeFileNotExist
                                              userInfo:nil];
            
            callback(error1);
            return ;
        }
    }
    
    //创建AVAudioPlayer
    error = nil;
    NSURL *wavURL = [NSURL URLWithString:wavFilePath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:wavURL error:&error];
    if(!_audioPlayer || error) {
        _audioPlayer = nil;
        NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                              code:kLLErrorPlayTypeInitFailed
                                          userInfo:nil];
        callback(error1);
        return ;
    }
    
    //开始播放
    _audioPlayer.delegate = self;
    BOOL success = [_audioPlayer play];
    if (!success) {
        NSError *error1 = [NSError errorWithDomain:ERROR_AUDIO_DOMAIN
                                              code:kLLErrorPlayTypePlayError
                                          userInfo:nil];
        callback(error1);
        return ;
        
    }

    callback(nil);
}


// 播放音频，播放音频不需要特殊权限
- (void)startPlayingWithPath:(NSString *)aFilePath
                        delegate:(id<LLAudioPlayDelegate>)delegate
                    userinfo:(id)userinfo continuePlaying:(BOOL)continuePlaying {
    
    [self checkAvailabilityWithFile:aFilePath callback:^(NSError *error) {
        if (!error) {
            self.playerDelegate = delegate;
            self.userinfo = userinfo;
            self.isPlaying = YES;
            isPlaySessionActive = YES;
            
            SAFE_SEND_MESSAGE(delegate, audioPlayDidStarted:) {
                [delegate audioPlayDidStarted:self.userinfo];
            }
            
            if (!continuePlaying && [LLUtils currentVolumeLevel] <= kLLSoundVolumeLevelLow) {
                SAFE_SEND_MESSAGE(delegate, audioPlayVolumeTooLow) {
                    [delegate audioPlayVolumeTooLow];
                }
            }
            
        }else {
            switch (error.code) {
                case kLLErrorPlayTypeInitFailed:
                case kLLErrorPlayTypeFileNotExist:
                case kLLErrorPlayTypePlayError:
                {
                    NSString *msg = @"遇到问题，暂时无法播放";
                    [LLUtils showMessageAlertWithTitle:@"无法播放" message:msg
                                   actionTitle:@"确定"];
                    break;
                }
                default:
                    break;
            }
            
            [self _stopPlaying];
        }
        
    }];


}

- (void)stopPlaying {
    if (!isPlaySessionActive) {
        return;
    }

    [self _stopPlaying];
    SAFE_SEND_MESSAGE(self.playerDelegate, audioPlayDidStopped:) {
        [self.playerDelegate audioPlayDidStopped:self.userinfo];
    }
    self.playerDelegate = nil;
    self.userinfo = nil;
    
}

- (void)_stopPlaying {
    [self _stopCurrentPlaying];
   
    if (self.previousCategory.length > 0) {
        [self.audioSession setCategory:self.previousCategory error:nil];
        self.previousCategory = nil;
    }
    
    [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    isPlaySessionActive = NO;
}

- (void)stopCurrentPlaying {
    if (!self.isPlaying)
        return;
    
    [self _stopCurrentPlaying];
    SAFE_SEND_MESSAGE(self.playerDelegate, audioPlayDidStopped:) {
        [self.playerDelegate audioPlayDidStopped:self.userinfo];
    }
}

- (void)_stopCurrentPlaying {
    if (_audioPlayer.isPlaying)
        [_audioPlayer stop]; //stop后不会调用delegate
    
    _audioPlayer = nil;
    self.isPlaying = NO;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    if (flag) {
        [self _stopCurrentPlaying];
        
        if ([self.playerDelegate respondsToSelector:@selector(audioPlayDidFinished:)]) {
            [self.playerDelegate audioPlayDidFinished:self.userinfo];
        }
    }else {
        [self _stopPlaying];
        
        if ([self.playerDelegate respondsToSelector:@selector(audioPlayDidFailed:)]) {
            [self.playerDelegate audioPlayDidFailed:self.userinfo];
        }
        self.playerDelegate = nil;
        self.userinfo = nil;

    }
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    
    [self _stopPlaying];
    SAFE_SEND_MESSAGE(self.playerDelegate, audioPlayDidFailed:) {
        [self.playerDelegate audioPlayDidFailed:self.userinfo];
    }
    
    self.playerDelegate = nil;
    self.userinfo = nil;
}


#pragma mark - 录音文件存储

+ (NSString *)randomFileName {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    return fileName;
}


+ (NSURL *)amrPathWithName:(NSString *)fileName {
    NSURL *amrTmpFolder = [LLUtils createFolderWithName:AMR_AUDIO_TMP_FOLDER inDirectory:[LLUtils dataPath]];
    if (!amrTmpFolder) {
        return nil;
    }
    
    NSString *filePathName = [NSString stringWithFormat:@"%@.amr", fileName];
    NSURL *filePath = [amrTmpFolder URLByAppendingPathComponent:filePathName];
    
    return filePath;
}


+ (NSURL *)wavPathWithName:(NSString *)fileName {
    NSURL *wavTmpFolder = [LLUtils createFolderWithName:WAV_AUDIO_TMP_FOLDER inDirectory:[LLUtils dataPath]];
    if (!wavTmpFolder) {
        return nil;
    }
    
    NSString *filePathName = [NSString stringWithFormat:@"%@.wav", fileName];
    NSURL *filePath = [wavTmpFolder URLByAppendingPathComponent:filePathName];
    
    return filePath;
}


#pragma mark - Convert

- (BOOL)convertAMR:(NSString *)amrFilePath
             toWAV:(NSString *)wavFilePath
{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [EMVoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [EMVoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}


@end
