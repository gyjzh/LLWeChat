//
//  LLVideoPlaybackView.h
//  LLWeChat
//
//  Created by GYJZH on 9/5/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@class AVPlayer;

@interface LLVideoPlaybackView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
