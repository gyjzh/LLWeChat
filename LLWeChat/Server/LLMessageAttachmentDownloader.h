//
//  LLMessageAttachmentDownloader.h
//  LLWeChat
//
//  Created by GYJZH on 9/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageModel.h"

typedef NS_ENUM(NSInteger, LLMessageDownloadPriority) {
    kLLMessageDownloadPriorityLow = 0,
    kLLMessageDownloadPriorityDefault,
    kLLMessageDownloadPriorityHigh   //暂未使用
};

@interface LLMessageAttachmentDownloader : NSObject

+ (instancetype)imageDownloader;

+ (instancetype)videoDownloader;

- (void)asynDownloadMessageAttachmentsWithDefaultPriority:(LLMessageModel *)model;

- (void)asynDownloadMessageAttachmentsWithHighPriority:(LLMessageModel *)model;

@end
