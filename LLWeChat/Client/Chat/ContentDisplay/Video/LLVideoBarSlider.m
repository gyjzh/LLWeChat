//
//  LLVideoBarSlider.m
//  LLWeChat
//
//  Created by GYJZH on 9/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVideoBarSlider.h"

@implementation LLVideoBarSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect rect = [super trackRectForBounds:bounds];
    rect.size.height = 1.5;
    rect.origin.y += 1;
    
    return rect;
}

@end
