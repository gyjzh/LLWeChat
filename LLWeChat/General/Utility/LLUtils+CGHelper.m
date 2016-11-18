//
//  LLUtils+CGHelper.m
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils+CGHelper.h"
#import "UIKit+LLExt.h"
@import ImageIO;

CGFloat SCREEN_WIDTH;
CGFloat SCREEN_HEIGHT;
CGSize SCREEN_SIZE;

CGRect SCREEN_FRAME;
CGPoint SCREEN_CENTER;


CGFloat CGPointDistanceBetween(CGPoint point1, CGPoint point2) {
    CGFloat dtx = point1.x - point2.x;
    CGFloat dty = point1.y - point2.y;
    CGFloat distance = sqrt(dtx * dtx + dty * dty);
    return distance;
}


@implementation LLUtils (CGHelper)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SCREEN_FRAME = [UIScreen mainScreen].bounds;
        SCREEN_SIZE = SCREEN_FRAME.size;
        SCREEN_WIDTH = SCREEN_SIZE.width;
        SCREEN_HEIGHT = SCREEN_SIZE.height;
        
        SCREEN_CENTER = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    });
}

+ (CGFloat)screenScale {
    static CGFloat _scale = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scale = [UIScreen mainScreen].scale;
    });
    
    return _scale;
}

+ (CGRect)screenFrame {
    return [UIScreen mainScreen].bounds;
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)pixelAlignForFloat:(CGFloat)position {
    CGFloat scale = [LLUtils screenScale];
    return round(position * scale) / scale;
}

+ (CGPoint)pixelAlignForPoint:(CGPoint)point {
    CGFloat scale = [LLUtils screenScale];
    CGFloat x = round(point.x * scale) / scale;
    CGFloat y = round(point.x * scale) / scale;
    
    return CGPointMake(x, y);
}

+ (CGSize)convertPointSizeToPixelSize:(CGSize)pointSize {
    CGFloat scale = [self screenScale];
    return CGSizeMake(pointSize.width * scale, pointSize.height * scale);
}


+ (CALayer *)lineWithLength:(CGFloat)length atPoint:(CGPoint)point {
    CALayer *line = [CALayer layer];
    line.backgroundColor = UIColorRGB(221, 221, 221).CGColor;
    
    line.frame = CGRectMake(point.x, point.y, length, 1/[self screenScale]);
    
    return line;
}


+ (UIColor *)colorAtPoint:(CGPoint)point fromImageView:(UIImageView *)imageView {
    if (!CGRectContainsPoint(imageView.bounds, point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = imageView.image.CGImage;
    NSUInteger width = CGRectGetWidth(imageView.frame);
    NSUInteger height = CGRectGetHeight(imageView.frame);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


+ (CGSize)GIFDimensionalSize:(CGImageSourceRef)imgSourceRef {
    if(!imgSourceRef){
        return CGSizeZero;
    }
    
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imgSourceRef, 0, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    
    NSNumber* pixelWidth = (dict[(NSString*)kCGImagePropertyPixelWidth]);
    NSNumber* pixelHeight = (dict[(NSString*)kCGImagePropertyPixelHeight]);
    
    CGSize size = CGSizeMake([pixelWidth floatValue], [pixelHeight floatValue]);
    
    CFRelease(dictRef);
    
    return size;
}

@end
