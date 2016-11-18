//
//  LLSDKError.m
//  LLWeChat
//
//  Created by GYJZH on 8/16/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSDKError.h"

@implementation LLSDKError

+ (instancetype)errorWithEMError:(EMError *)error {
    LLSDKError *_error = [[LLSDKError alloc] initWithDescription:error.errorDescription code:(LLSDKErrorCode)error.code];
    return _error;
}

- (instancetype)initWithDescription:(NSString *)aDescription code:(LLSDKErrorCode)aCode {
    self = [super init];
    if (self) {
        self.errorDescription = aDescription;
        self.errorCode = aCode;
    }
    
    return self;
}

+ (instancetype)errorWithDescription:(NSString *)aDescription code:(LLSDKErrorCode)aCode {
    LLSDKError *error = [[LLSDKError alloc] initWithDescription:aDescription code:aCode];
    return error;
}

@end
