//
//  LLImageBottomBar.m
//  LLWeChat
//
//  Created by GYJZH on 9/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageBottomBar.h"
#import "UIKit+LLExt.h"
#import "LLUtils.h"

@interface LLImageBottomBar ()
@end

@implementation LLImageBottomBar

- (void)awakeFromNib {
    [super awakeFromNib];
    self.downloadButton.layer.borderColor = UIColorRGB(90, 90, 90).CGColor;
    self.downloadButton.layer.borderWidth = 1;
    self.downloadButton.layer.cornerRadius = 3;
    self.downloadButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.downloadButton.alpha = 0;

}

- (void)setBottomBarStyle:(LLImageBottomBarStyle)bottomBarStyle animated:(BOOL)animated {
    _style = bottomBarStyle;
    
    [UIView animateWithDuration:animated ? DEFAULT_DURATION : 0
                     animations:^{
                         switch (bottomBarStyle) {
                                case kLLImageBottomBarStyleHide:
                                    self.moreButton.alpha = 0;
                                    self.downloadButton.alpha = 0;
                                    break;
                                    
                                case kLLImageBottomBarStyleMore:
                                    self.moreButton.alpha = 1;
                                    self.downloadButton.alpha = 0;
                                    break;
                                    
                                case kLLImageBottomBarStyleDownloading:
                                    self.moreButton.alpha = 0;
                                    self.downloadButton.alpha = 1;
                                    break;
                                    
                                case kLLImageBottomBarStyleDownloadFullImage:
                                    self.moreButton.alpha = 1;
                                    self.downloadButton.alpha = 1;
                                    break;
                            }

                     }];
    
}

- (void)setDownloadProgress:(NSInteger)progress {
    NSString *str = progress >= 100 ? @"已完成" : [NSString stringWithFormat:@"%ld%%", (long)progress];
    
    [self.downloadButton setTitle:str forState:UIControlStateNormal];
}

- (void)setDownloadFullImageSize:(NSString *)sizeString {
    [self.downloadButton setTitle:[NSString stringWithFormat:@"查看原图(%@)", sizeString] forState:UIControlStateNormal];
}

@end
