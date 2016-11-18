//
//  LLGIFImageView.h
//  LLWeChat
//
//  Created by GYJZH on 17/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLGIFImageView : UIImageView

@property (nonatomic) NSData *gifData;

//GIF动画开始播放的帧索引，默认为0;在GIFImageView重用时，以便恢复到上次动画停止的状态
@property (nonatomic) NSInteger startShowIndex;

//GIF动画当前正在显示的帧索引
@property (nonatomic, readonly) NSInteger currentShowIndex;

//GIF动画帧总数
@property (nonatomic, readonly) NSInteger totalFrameCount;

- (void)startGIFAnimating;

- (void)stopGIFAnimating;

- (BOOL)isGIFAnimating;

@end
