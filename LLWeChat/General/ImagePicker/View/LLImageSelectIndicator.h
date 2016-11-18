//
//  LLImageSelectIndicator.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLImageSelectIndicator: UIView

@property (nonatomic, getter=isSelected) BOOL selected;

- (void)addTarget:(id)target action:(SEL)action;

@end
