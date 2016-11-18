//
//  LLTipDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 9/20/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLTipDelegate <NSObject>

@optional

@property (nonatomic) BOOL canCancelByTouch;

- (void)didMoveToTipLayer;

- (void)willRemoveFromTipLayer;
- (void)didRemoveFromTipLayer;

- (UIOffset)tipViewCenterPositionOffset;

@end
