//
//  UINavigationBar+LLExt.m
//  LLWeChat
//
//  Created by GYJZH on 03/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "UINavigationBar+LLExt.h"

@implementation UINavigationBar (LLExt)

- (CGFloat)barAlpha {
    return self.subviews[0].alpha;
}

- (void)setBarAlpha:(CGFloat)alpha {
    self.subviews[0].alpha = alpha;
}

@end
