//
//  LLVideoPlaybackView.m
//  LLWeChat
//
//  Created by GYJZH on 9/5/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVideoPlaybackView.h"
@import AVFoundation;

@implementation LLVideoPlaybackView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}


@end
