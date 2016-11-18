//
//  LLChatImageScrollView.h
//  LLWeChat
//
//  Created by GYJZH on 8/16/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetDisplayView.h"

#define MinimumZoomScale 1
#define MaximumZoomScale 2


@interface LLChatImageScrollView : UIScrollView<LLAssetDisplayView>

@property (nonatomic) CGSize imageSize;

- (void)layoutImageView:(CGSize)size;

- (void)setDownloadFailImage;

- (BOOL)shouldZoom;

@end
