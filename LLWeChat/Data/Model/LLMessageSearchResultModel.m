//
//  LLMessageSearchResultModel.m
//  LLWeChat
//
//  Created by GYJZH on 06/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageSearchResultModel.h"
#import "LLUtils.h"


@implementation LLMessageSearchResultModel

- (instancetype)initWithMessage:(EMMessage *)message {
    self = [super init];
    if (self) {
        _sdk_message = message;
        _nickName = [message.conversationId copy];
        _timestamp = adjustTimestampFromServer(message.timestamp);
    }
    
    return self;
}

@end
