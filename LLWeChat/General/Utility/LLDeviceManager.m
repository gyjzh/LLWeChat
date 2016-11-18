//
//  LLDeviceManager.m
//  LLWeChat
//
//  Created by GYJZH on 8/31/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLDeviceManager.h"
#import "LLUtils.h"

@implementation LLDeviceManager

+ (LLDeviceManager *)sharedManager {
    static LLDeviceManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLDeviceManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}



#pragma mark - ProximitySensor -

- (BOOL)isProximitySensorEnabled {
    return [UIDevice currentDevice].proximityMonitoringEnabled;
}

- (BOOL)enableProximitySensor {
    if (!self.isProximitySensorEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        
        if (self.isProximitySensorEnabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                        selector:@selector(sensorStateChanged:)
                            name:UIDeviceProximityStateDidChangeNotification
                          object:nil];

            return YES;
        }else {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)disableProximitySensor {
    if (self.isProximitySensorEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                        name:UIDeviceProximityStateDidChangeNotification
                      object:nil];
    }
    
    return NO;
}

- (BOOL)isCloseToUser {
    return [UIDevice currentDevice].proximityState;
}

- (void)sensorStateChanged:(NSNotification *)notification {
    SAFE_SEND_MESSAGE(self.delegate, deviceIsCloseToUser:) {
        [self.delegate deviceIsCloseToUser:[self isCloseToUser]];
    }
}


@end
