//
//  LLImageAnimationView.m
//  LLWeChat
//
//  Created by GYJZH on 9/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageAnimationView.h"
#import "LLUtils.h"

#define ROTATION_ANIMATION_KEY @"rotationAnimation"

#define CIRCLE_LINE_WIDTH 4

@implementation LLImageAnimationView {
    UIView *view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CABasicAnimation *rotationAnimation = (CABasicAnimation *)[self.layer animationForKey:ROTATION_ANIMATION_KEY];
        if (!rotationAnimation) {
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
            rotationAnimation.duration = 1;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = HUGE_VALF;
            rotationAnimation.removedOnCompletion = NO;
            
            [self.layer addAnimation:rotationAnimation forKey:ROTATION_ANIMATION_KEY];
        }
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, CIRCLE_LINE_WIDTH);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.4].CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(CIRCLE_LINE_WIDTH, CIRCLE_LINE_WIDTH, CGRectGetWidth(rect) - 2*CIRCLE_LINE_WIDTH, CGRectGetHeight(rect) - 2*CIRCLE_LINE_WIDTH));
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect)/2 - CIRCLE_LINE_WIDTH, 0, DEGREES_TO_RADIANS(120), 0);
    CGContextStrokePath(context);
}

@end
