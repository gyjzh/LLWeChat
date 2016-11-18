//
//  LLVideoPlaybackController.m
//  LLWeChat
//
//  Created by GYJZH on 9/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVideoPlaybackController.h"
#import "LLUtils.h"


static void *LLVideoPlaybackRateObservationContext = &LLVideoPlaybackRateObservationContext;
static void *LLVideoPlaybackStatusObservationContext = &LLVideoPlaybackStatusObservationContext;
static void *LLVideoPlaybackCurrentItemObservationContext = &LLVideoPlaybackCurrentItemObservationContext;

#define TOLERANCE_TIME_INTERVAL 1


@interface LLVideoPlaybackController () <UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableDictionary<NSString*, AVPlayerItem *> *allVideoItems;

@property (nonatomic, readonly) AVPlayer *player;

@property (weak, nonatomic) IBOutlet UIView *controlContentView;

@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *scrubber;

@property (weak, nonatomic) IBOutlet UIView *playStopButtonView;

@property (weak, nonatomic) IBOutlet UIView *sliderView;

@property (weak, nonatomic) IBOutlet UIView *moreButtonView;


@end

@implementation LLVideoPlaybackController {
    float minValue;
    float maxValue;
    
    float mRestoreAfterScrubbingRate;
    id mTimeObserver;
    BOOL isSeeking;
    BOOL isPlayStopButtonEnabled;
    BOOL isSliderEnabled;
    BOOL isStoping;
    
    UIColor *backgroundColor;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _allVideoItems = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    self.view.backgroundColor = backgroundColor;
    
    [self.scrubber setThumbImage:[UIImage imageNamed:@"playerplan_button"] forState:UIControlStateNormal];
    [self.scrubber setThumbImage:[UIImage imageNamed:@"playerplan_button"] forState:UIControlStateHighlighted];
    
    _player = [AVPlayer playerWithPlayerItem:nil];
    
    /* Observe the AVPlayer "currentItem" property to find out when any
     AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
     occur.*/
    [_player addObserver:self
              forKeyPath:@"currentItem"
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:LLVideoPlaybackCurrentItemObservationContext];
    
    /* Observe the AVPlayer "rate" property to update the scrubber control. */
    [_player addObserver:self
              forKeyPath:@"rate"
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:LLVideoPlaybackRateObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                         selector:@selector(playerItemDidReachEnd:)
                             name:AVPlayerItemDidPlayToEndTimeNotification
                           object:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setVideoURL:(NSURL *)videoURL {
    AVPlayerItem *playerItem = _allVideoItems[videoURL.path];

    if (!playerItem) {
        _videoURL = [videoURL copy];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        WEAK_SELF;
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [weakSelf prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];
    }else {
        if (![videoURL.path isEqualToString:_videoURL.path]) {
            _videoURL = [videoURL copy];
            [self play:playerItem];
            if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [self playerReadyToPlay:videoURL];
            }else {
                [self playerPrepareToPlayFailed:self.videoURL];
            }
        }
    }
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            [self playerPrepareToPlayFailed:self.videoURL];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable) {
        /* Display the error to the user. */
        [self playerPrepareToPlayFailed:self.videoURL];
        
        return;
    }
    

    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    _allVideoItems[asset.URL.path] = playerItem;
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionInitial |
                            NSKeyValueObservingOptionNew
                    context:LLVideoPlaybackStatusObservationContext];
    
    [self play:playerItem];
}

- (void)play:(AVPlayerItem *)playerItem {
    [self.player seekToTime:kCMTimeZero];
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (_player.currentItem != playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [_player replaceCurrentItemWithPlayerItem:playerItem];
    }
}

#pragma mark - 状态监听/回调

- (NSURL *)videoURLForAVPlayerItem:(AVPlayerItem *)playerItem {
    NSURL *videoURL;
    for (NSString *key in _allVideoItems) {
        if ([_allVideoItems[key] isEqual:playerItem]) {
            videoURL = [NSURL fileURLWithPath:key];
            break;
        }
    }
    return videoURL;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = (AVPlayerItem *)notification.object;
    NSURL *videoURL = [self videoURLForAVPlayerItem:playerItem];
    
    [self playerDidPlayToEnd:videoURL];

}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == LLVideoPlaybackStatusObservationContext)
    {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        NSURL *videoURL = [self videoURLForAVPlayerItem:playerItem];
        
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because
             it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
                break;
                
            case AVPlayerItemStatusReadyToPlay: {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                [self playerReadyToPlay:videoURL];
            }
                break;
                
            case AVPlayerItemStatusFailed: {
                [self playerPrepareToPlayFailed:videoURL];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == LLVideoPlaybackRateObservationContext)
    {
        [self playerRateDidChanged];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == LLVideoPlaybackCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
        }else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.playbackView setPlayer:self.player];
//            /* Specifies that the player should preserve the video’s aspect ratio and
//             fit the video within the layer’s bounds. */
//            [self.playbackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            NSURL *videoURL = [self videoURLForAVPlayerItem:newPlayerItem];
            SAFE_SEND_MESSAGE(self.delegate, playerCurrentItemDidChangedTo:) {
                [self.delegate playerCurrentItemDidChangedTo:videoURL];
            }
            
        }
    }else {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}


#pragma mark - 播放控制 -

- (void)play {
    [self.player play];
    self.player.volume = 1.f;
    [self addPlayerTimeObserver];
    [self showStopButton];
}

- (void)pause {
    [self.player pause];
    [self showPlayButton];
}

- (void)stop {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    isStoping = NO;
    self.player.volume = 1.f;
    
    [self showPlayButton];
}

- (void)willStop {
    //TODO：此时暂停播放，带来的主线程延迟很小，那究竟暂不暂停，待定
//    [self.player pause];
    if (!isStoping) {
        isStoping = YES;
        [self removePlayerTimeObserver];
        self.player.volume = 0.f;
    }

}

- (BOOL)isPlaying {
    return !isStoping && ([self.player rate] != 0.f);
}

- (void)setPlaybackView:(LLVideoPlaybackView *)playbackView {
    if (_playbackView != playbackView) {
        [_playbackView setPlayer:nil];
        _playbackView = playbackView;
//        [_playbackView setPlayer:_player];
    }
}


- (void)playerPrepareToPlayFailed:(NSURL *)videoURL {
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    [LLUtils showMessageAlertWithTitle:@"无法播放" message:@"无法播放视频,请稍后再试"];
    
    SAFE_SEND_MESSAGE(self.delegate, playerPrepareToPlayFailed:) {
        [self.delegate playerPrepareToPlayFailed:videoURL];
    }
}


- (void)playerReadyToPlay:(NSURL *)videoURL {
    [self initScrubberTimer];
    [self initTimeLable];
    
    self.player.volume = 1.f;
    [self enableScrubber];
    [self enablePlayerButtons];
    
    SAFE_SEND_MESSAGE(self.delegate, playerReadyToPlay:) {
        [self.delegate playerReadyToPlay:videoURL];
    }
}

- (void)playerRateDidChanged {
    if (self.player.rate == 0) {
        [self showPlayButton];
    }else {
        [self showStopButton];
    }
    
    NSURL *videoURL = [self videoURLForAVPlayerItem:self.player.currentItem];
    SAFE_SEND_MESSAGE(self.delegate, playerRateDidChanged:currentRate:) {
        [self.delegate playerRateDidChanged:videoURL currentRate:self.player.rate];
    }
}


/* After the movie has played to its end time, seek back to time zero
 to play it again. */
- (void)playerDidPlayToEnd:(NSURL *)videoURL {
    WEAK_SELF;
    [self disablePlayerButtons];
    [self disableScrubber];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.scrubber setValue:0 animated:YES];
            weakSelf.currentTimeLabel.text = @"00:00";
            [weakSelf showPlayButton];
        }];
        
        [weakSelf enableScrubber];
        [weakSelf enablePlayerButtons];
    });
    
    SAFE_SEND_MESSAGE(self.delegate, playerDidPlayToEnd:) {
        [self.delegate playerDidPlayToEnd:videoURL];
    }
}

#pragma mark - 播放控制UI -

- (void)initVideoBottomBarWithDuration:(CGFloat)duration {
    [self showPlayButton];
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = [self convertTimetoString:round(duration)];
    [self.scrubber setValue:0 animated:NO];
}

- (void)setBackgroundViewVisible:(BOOL)visible {
    self.view.backgroundColor = visible ? backgroundColor : [UIColor clearColor];
}

- (void)hideControlView:(BOOL)animated {
    void (^block)() = ^() {
        self.controlContentView.hidden = YES;
        isPlayStopButtonEnabled = NO;
        isSliderEnabled = NO;
    };
    
    if (animated) {
        [UIView animateWithDuration:DEFAULT_DURATION animations:block];
    }else {
        block();
    }
}

- (void)showControlView:(BOOL)animated {
    void (^block)() = ^() {
        [self syncPlayPauseButtons];
        self.controlContentView.hidden = NO;
        isPlayStopButtonEnabled = YES;
        isSliderEnabled = YES;
    };
    
    if (animated) {
        [UIView animateWithDuration:DEFAULT_DURATION animations:block];
    }else {
        block();
    }
}

- (BOOL)isControlViewHidden {
    return self.controlContentView.hidden;
}


#pragma mark - 播放时间 - 

- (void)initTimeLable {
    self.totalTimeLabel.text = @"00:00";
    self.currentTimeLabel.text = @"00:00";
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        self.totalTimeLabel.text = [self convertTimetoString:round(duration)];
    }
    self.currentTimeLabel.text = [self convertTimetoString:round([self getCurrentPlayerTime])];
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

- (double)getCurrentPlayerTime {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return 0;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    double time = CMTimeGetSeconds([self.player currentTime]);
    if (time < 0)
        time = 0;
    else if (time >= duration + FLT_EPSILON)
        time = duration;
    
    return time;
}


#pragma mark 播放/暂停按钮 -

-(void)showStopButton {
    self.playButton.hidden = YES;
    self.stopButton.hidden = NO;
}

-(void)showPlayButton {
    self.playButton.hidden = NO;
    self.stopButton.hidden = YES;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    if ([self.playStopButtonView pointInside:[tap locationInView:self.playStopButtonView] withEvent:nil]) {
        if (!isPlayStopButtonEnabled)
            return;
        [self togglePlayButtons];
    }
    
}

- (void)togglePlayButtons {
    if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        NSLog(@"先简单做：点击播放按钮时，播放源尚未准备好");
        return;
    }
    
    if ([self isPlaying]) {
        [self pause];
    }else {
        [self play];
    }
}

- (void)syncPlayPauseButtons { //FIXME:如果没有声音却依然在播放，当前认为是播放停止
    if ([self isPlaying] && _player.volume >= FLT_EPSILON) {
        [self showStopButton];
    }else {
        [self showPlayButton];
    }
}

-(void)enablePlayerButtons {
    isPlayStopButtonEnabled = YES;
}

-(void)disablePlayerButtons {
    isPlayStopButtonEnabled = NO;
}


#pragma mark 播放器进度条控制 -

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer {
    minValue = [self.scrubber minimumValue];
    maxValue = [self.scrubber maximumValue];
    [self syncScrubber];
    
//    CMTime playerDuration = [self playerItemDuration];
//    if (CMTIME_IS_INVALID(playerDuration))
//    {
//        return;
//    }

    [self addPlayerTimeObserver];
    isSliderEnabled = YES;
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        [self.scrubber setValue:0 animated:NO];
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        double playerTime = [self getCurrentPlayerTime];
        float value = [self.scrubber value];
        double scrubTime = round(duration) * (value - minValue) / (maxValue - minValue);
        
        double time;
        if (playerTime > scrubTime - FLT_EPSILON) {
            time = playerTime;
        }else {
            time = scrubTime;
        }
        if (round(time) >= round(duration))
            time = round(duration);
        
        [self.scrubber setValue:(maxValue - minValue) * time / round(duration) + minValue];
        
        self.currentTimeLabel.text = [self convertTimetoString:floor(time)];
    }

}


-(void)removePlayerTimeObserver {
    if (mTimeObserver)
    {
        [self.player removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

- (void)addPlayerTimeObserver {
    if (!mTimeObserver) {
        WEAK_SELF;
        mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(TOLERANCE_TIME_INTERVAL, NSEC_PER_SEC)
                    queue:NULL /* If you pass NULL, the main queue is used. */
               usingBlock:^(CMTime time) {
                  [weakSelf syncScrubber];
               }];
    }
}


- (IBAction)beginScrubbing:(id)sender {
    if (!isSliderEnabled)
        return;
    isPlayStopButtonEnabled = NO;
    mRestoreAfterScrubbingRate = [self.player rate];
    
    [self.player setRate:0];
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
    
    SAFE_SEND_MESSAGE(self.delegate, playerScrubberWillChange:) {
        [self.delegate playerScrubberWillChange:self.videoURL];
    }
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(UISlider *)slider {
    if (!isSliderEnabled)
        return;
    
    if (!isSeeking)
    {
        isSeeking = YES;
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            float value = [self.scrubber value];
            double scrubTime = round(duration) * (value - minValue) / (maxValue - minValue);
            
            if (round(scrubTime) >= round(duration))
                scrubTime = round(duration);
            
            WEAK_SELF;
            //由于SeekToTime本身就不精确，那么就大致着来就行
            [self.player seekToTime:CMTimeMakeWithSeconds(scrubTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    STRONG_SELF;
                    strongSelf->isSeeking = NO;
                    weakSelf.currentTimeLabel.text = [weakSelf convertTimetoString:floor(scrubTime)];
                });
            }];
        }
        
    }
}


- (IBAction)endScrubbing:(id)sender {
    if (!isSliderEnabled)
        return;
    
    if (!mTimeObserver)
    {
        [self.player setRate:mRestoreAfterScrubbingRate];
        isPlayStopButtonEnabled = YES;
        
        [self addPlayerTimeObserver];
        
    }
    
}


-(void)enableScrubber {
    isSliderEnabled = YES;
}

-(void)disableScrubber {
    isSliderEnabled = NO;
}


#pragma mark - 其他 -

- (NSString *)convertTimetoString:(NSInteger)time {
    if (time==0) {
        return @"00:00";
    }
    
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;
    
    NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    return timeString;
}

- (void)dealloc {
    for (AVPlayerItem *playerItem in _allVideoItems.allValues) {
        [playerItem removeObserver:self forKeyPath:@"status"];
    }
    
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
