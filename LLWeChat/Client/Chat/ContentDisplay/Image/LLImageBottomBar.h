//
//  LLImageBottomBar.h
//  LLWeChat
//
//  Created by GYJZH on 9/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageModel.h"

typedef NS_ENUM(NSInteger, LLImageBottomBarStyle) {
    kLLImageBottomBarStyleHide,
    kLLImageBottomBarStyleMore,
    kLLImageBottomBarStyleDownloading,
    kLLImageBottomBarStyleDownloadFullImage
};

@interface LLImageBottomBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (nonatomic) LLImageBottomBarStyle style;

- (void)setBottomBarStyle:(LLImageBottomBarStyle)bottomBarStyle animated:(BOOL)animated;

- (void)setDownloadProgress:(NSInteger)progress;

- (void)setDownloadFullImageSize:(NSString *)sizeString;

@end
