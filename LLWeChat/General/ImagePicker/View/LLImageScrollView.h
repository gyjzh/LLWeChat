//
//  LLImageScrollView.h
//  LLPickImageDemo
//
//  Created by GYJZH on 7/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetModel.h"


#define MinimumZoomScale 1
#define MaximumZoomScale 2


@interface LLImageScrollView : UIScrollView

@property (nonatomic) NSInteger assetIndex;
@property (nonatomic) LLAssetModel *assetModel;

@property (nonatomic) CGSize imageSize;

@property (nonatomic, readonly) BOOL isImageExist;

@property (nonatomic) UIImageView *imageView;

- (void)setContentWithImage:(UIImage *)image;

@end
