//
//  UIView+LLExt.m
//  LLWeChat
//
//  Created by GYJZH on 7/31/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "UIView+LLExt.h"
#import "LLUtils.h"
#import "MBProgressHUD.h"

@implementation UIView (LLExt)

- (CGFloat)left_LL {
    return CGRectGetMinX(self.frame);
}

- (void)setLeft_LL:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top_LL {
    return CGRectGetMinY(self.frame);
}

- (void)setTop_LL:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right_LL {
    return CGRectGetMaxX(self.frame);
}

- (void)setRight_LL:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom_LL {
    return CGRectGetMaxY(self.frame);
}

- (void)setBottom_LL:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width_LL {
    return CGRectGetWidth(self.frame);
}

- (void)setWidth_LL:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height_LL {
    return CGRectGetHeight(self.frame);
}

- (void)setHeight_LL:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX_LL {
    return self.center.x;
}

- (void)setCenterX_LL:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY_LL {
    return self.center.y;
}

- (void)setCenterY_LL:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin_LL {
    return self.frame.origin;
}

- (void)setOrigin_LL:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size_LL {
    return self.frame.size;
}

- (void)setSize_LL:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


#pragma mark - 

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tap];
    
    return tap;
}

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action target:(id)target {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tap];
    
    return tap;
}

- (UILongPressGestureRecognizer *)addLongPressGestureRecognizer:(SEL)action duration:(CGFloat)duration {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:action];
    longPress.minimumPressDuration = duration;
    [self addGestureRecognizer:longPress];
    
    return longPress;
}

- (UILongPressGestureRecognizer *)addLongPressGestureRecognizer:(SEL)action target:(id)target duration:(CGFloat)duration {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    longPress.minimumPressDuration = duration;
    [self addGestureRecognizer:longPress];
    
    return longPress;
}

//- (void)showActionSuccessDialog:(NSString *)title {
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
//    [self addSubview:HUD];
//    HUD.removeFromSuperViewOnHide = YES;
//
//    HUD.mode = MBProgressHUDModeCustomView;
//    UIImage *image = [UIImage imageNamed:@"operationbox_successful"];
//    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    HUD.customView = [[UIImageView alloc] initWithImage:image];
//    HUD.square = YES;
//    HUD.margin = 8;
//    HUD.minSize = CGSizeMake(120, 120);
//
//    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    HUD.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
//    HUD.label.text = title;
//    HUD.label.font = [UIFont systemFontOfSize:14];
//    HUD.contentColor = [UIColor colorWithWhite:1 alpha:1];
//
//    [HUD layoutIfNeeded];
//    HUD.label.top_LL += 10;
//
//    [HUD showAnimated:YES];
//    [HUD hideAnimated:YES afterDelay:2];
//
//}
//
//- (void)showTextDialog:(NSString *)text {
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
//    [self addSubview:HUD];
//
//    HUD.mode = MBProgressHUDModeText;
//    HUD.margin = 8;
//    HUD.minSize = CGSizeMake(120, 30);
//
//    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    HUD.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
//    HUD.contentColor = [UIColor colorWithWhite:1 alpha:1];
//
//    HUD.label.text = text;
//    HUD.label.font = [UIFont systemFontOfSize:15];
//
//    [HUD layoutIfNeeded];
//    HUD.bezelView.bottom_LL = SCREEN_HEIGHT - 60;
//
//    [HUD showAnimated:YES];
//    [HUD hideAnimated:YES afterDelay:2];
//
//}


- (void)showRoundingCornersWithRadiusAt:(CGFloat)radius topLeft:(BOOL)topLeft topRight:(BOOL)topRight bottomLeft:(BOOL)bottomLeft bottomRight:(BOOL)bottomRight {
    if (topLeft && topRight && bottomLeft && bottomRight) {
        self.layer.cornerRadius = radius;
        return;
    }
    UIRectCorner corners = 0;
    if (topLeft)
        corners |= UIRectCornerTopLeft;
    if (topRight)
        corners |= UIRectCornerTopRight;
    if (bottomLeft)
        corners |= UIRectCornerBottomLeft;
    if (bottomRight)
        corners |= UIRectCornerBottomRight;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (BOOL)isVisible {
    return !self.hidden;
}

- (void)setVisible:(BOOL)visible {
    self.hidden = !visible;
}

@end
