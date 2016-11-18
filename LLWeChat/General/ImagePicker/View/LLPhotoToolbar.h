//
//  LLPhotoToolbar.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LLPhotoToolbarStyle) {
    kLLPhotoToolbarStyle1,
    kLLPhotoToolbarStyle2
};


@interface LLPhotoToolbar : UIView

@property (nonatomic) NSInteger number;

- (instancetype)initWithStyle:(LLPhotoToolbarStyle)style;

- (void)addTarget:(id)target previewAction:(SEL)action1 finishAction:(SEL)action2;
@end
