//
//  LLVideoDisplayView.h
//  LLWeChat
//
//  Created by GYJZH on 9/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetDisplayView.h"
#import "LLVideoPlaybackView.h"
#import "LLChatAssetDisplayController.h"

typedef NS_ENUM(NSInteger, LLVideoDownloadStyle) {
    kLLVideoDownloadStyleNone,
    kLLVideoDownloadStylePending,
    kLLVideoDownloadStyleWaiting,
    kLLVideoDownloadStyleDownloading,
    kLLVideoDownloadStyleDownloadSuccess,
    kLLVideoDownloadStyleFailed
};

typedef NS_ENUM(NSInteger, LLVideoPlaybackStatus) {
    kLLVideoPlaybackStatusPicture = 0, //没有播放源，仅仅显示视频第一帧图片
    kLLVideoPlaybackStatusVideo, //开始播放
};

@interface LLVideoDisplayView : UIView<LLAssetDisplayView>

@property (nonatomic) LLVideoPlaybackView *videoPlaybackView;

@property (nonatomic, weak) LLChatAssetDisplayController *chatAssetDisplayController;

@property (nonatomic) BOOL needAnimation;

@property (nonatomic) LLVideoPlaybackStatus videoPlaybackStatus;

@property (nonatomic) LLVideoDownloadStyle videoDownloadStyle;

- (void)setDownloadProgress:(NSInteger)progress;

@end
