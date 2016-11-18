//
//  UIScrollView+LLExt.m
//  LLWeChat
//
//  Created by GYJZH on 8/2/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "UIScrollView+LLExt.h"

@implementation UIScrollView (LLExt)

- (void)setInsetTop_LL:(CGFloat)top
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = top;
    self.contentInset = inset;
}

- (CGFloat)insetTop_LL
{
    return self.contentInset.top;
}

- (void)setInsetBottom_LL:(CGFloat)bottom
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = bottom;
    self.contentInset = inset;
}

- (CGFloat)insetBottom_LL
{
    return self.contentInset.bottom;
}

- (void)setInsetLeft_LL:(CGFloat)left
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = left;
    self.contentInset = inset;
}

- (CGFloat)insetLeft_LL
{
    return self.contentInset.left;
}

- (void)setInsetRight_LL:(CGFloat)right
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = right;
    self.contentInset = inset;
}

- (CGFloat)insetRight_LL
{
    return self.contentInset.right;
}

- (void)setOffsetX_LL:(CGFloat)offsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = offsetX;
    self.contentOffset = offset;
}

- (CGFloat)offsetX_LL
{
    return self.contentOffset.x;
}

- (void)setOffsetY_LL:(CGFloat)offsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = offsetY;
    self.contentOffset = offset;
}

- (CGFloat)offsetY_LL
{
    return self.contentOffset.y;
}

- (void)setContentWidth_LL:(CGFloat)contentWidth
{
    CGSize size = self.contentSize;
    size.width = contentWidth;
    self.contentSize = size;
}

- (CGFloat)contentWidth_LL
{
    return self.contentSize.width;
}

- (void)setContentHeight_LL:(CGFloat)contentHeight
{
    CGSize size = self.contentSize;
    size.height = contentHeight;
    self.contentSize = size;
}

- (CGFloat)contentHeight_LL
{
    return self.contentSize.height;
}


#pragma mark - Actions

- (BOOL)isAtTop {
    return self.contentOffset.y <= -self.contentInset.top;
}

- (BOOL)isAtBottom {
    return  self.contentSize.height - self.contentOffset.y + self.contentInset.bottom <= CGRectGetHeight(self.frame);
}

- (void)scrollToTopAnimated:(BOOL)animated {
    [self setContentOffset:CGPointMake(0, -self.contentInset.top) animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    [self setContentOffset:CGPointMake(0, self.contentSize.height - (CGRectGetHeight(self.frame) - self.contentInset.bottom)) animated:animated];
}

- (CGFloat)minHeightRequiredToScroll {
    return CGRectGetHeight(self.frame) - self.contentInset.top - self.contentInset.bottom;
}

- (CGFloat)minWidthRequiredToScroll {
    return CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right;
}

@end
