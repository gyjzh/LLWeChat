//
//  UIImage+LLExt.h
//  LLWeChat
//
//  Created by GYJZH on 8/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LLExt)

+ (UIImage *)imageWithView:(UIView *)view;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)resizableImage;

- (UIImage *)resizeImageToSize:(CGSize)size;

- (UIImage *)resizeImageToSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale;

- (UIImage *)createWithImageInRect:(CGRect)rect;

- (UIImage *)getGrayImage;

- (UIImage *)darkenImage;

- (UIImage *) partialImageWithPercentage:(float)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest;

- (CGSize)pixelSize;

- (NSInteger)imageFileSize;

@end
