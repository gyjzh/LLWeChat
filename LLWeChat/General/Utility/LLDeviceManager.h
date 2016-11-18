//
//  LLDeviceManager.h
//  LLWeChat
//
//  Created by GYJZH on 8/31/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LLDeviceManagerDelegate <NSObject>

/**
* @brief 当手机靠近或者离开耳朵时,回调该方法
*
*/
- (void)deviceIsCloseToUser:(BOOL)isCloseToUser;

@end


@interface LLDeviceManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<LLDeviceManagerDelegate> delegate;

- (BOOL)isCloseToUser;
- (BOOL)isProximitySensorEnabled;
- (BOOL)enableProximitySensor;
- (BOOL)disableProximitySensor;

@end
