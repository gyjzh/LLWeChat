//
//  LLSightCapatureController.h
//  LLWeChat
//
//  Created by GYJZH on 13/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SIGHT_VISUAL_HEIGHT 320

#define TOP_BAR_HEIGHT 20

@class LLSightCapatureController;
@protocol LLSightCapatureControllerDelegate <NSObject>

@required
- (void)sightCapatureControllerDidCancel:(LLSightCapatureController *)sightController;


@end


@interface LLSightCapatureController : UIViewController

@property (nonatomic) UIView *contentView;

@property (nonatomic, weak) id<LLSightCapatureControllerDelegate> delegate;

- (void)scrollViewPanGestureRecognizerStateChanged:(UIPanGestureRecognizer *)panGestureGecognizer;

@end
