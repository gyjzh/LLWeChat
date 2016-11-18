//
//  LLVideoDownloadStatusHUD.h
//  LLWeChat
//
//  Created by GYJZH on 9/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define PROGRESS_END 101
//#define PROGRESS_NOT_START -1
//#define PROGRESS_FAIL 102

typedef NS_ENUM(NSInteger, LLVideoDownloadHUDStatus) {
    kLLVideoDownloadHUDStatusPending,
    kLLVideoDownloadHUDStatusWaiting,
    kLLVideoDownloadHUDStatusDownloading,
    kLLVideoDownloadHUDStatusSuccess,
    kLLVideoDownloadHUDStatusFailed
};


#define ROTATION_ANIMATION_KEY @"rotationAnimation"

@interface LLVideoDownloadStatusHUD : UIView

@property (nonatomic) NSInteger progress;

@property (nonatomic) LLVideoDownloadHUDStatus status;

- (void)setText:(NSString *)text forStatus:(LLVideoDownloadHUDStatus)status;

- (void)playZoomAnimation;

- (void)playQuickProgressAnimationTo:(NSInteger)finalProgress;

@end
