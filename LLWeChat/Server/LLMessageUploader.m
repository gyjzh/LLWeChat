//
//  LLMessageUploader.m
//  LLWeChat
//
//  Created by GYJZH on 9/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageUploader.h"
#import "LLChatManager.h"
#import "LLUtils.h"


@interface LLMessageUploader ()

@property (nonatomic) dispatch_queue_t queue_upload;

@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation LLMessageUploader


+ (instancetype)imageUploader {
    static LLMessageUploader *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMessageUploader alloc] initWithQueueLabel:@"IMAGE_UPLOADER" concurrentNum:1];
    });
    
    return _instance;
}

+ (instancetype)videoUploader {
    static LLMessageUploader *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMessageUploader alloc] initWithQueueLabel:@"VIDEO_UPLOADER" concurrentNum:1];
    });
    
    return _instance;
}

+ (instancetype)defaultUploader {
    static LLMessageUploader *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMessageUploader alloc] initWithQueueLabel:@"DEFAULT_UPLOADER" concurrentNum:6];
    });
    
    return _instance;
}

- (instancetype)initWithQueueLabel:(NSString *)label concurrentNum:(long)semaphore {
    self = [super init];
    if (self) {
        _queue_upload = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_CONCURRENT);
        _semaphore = dispatch_semaphore_create(semaphore);
    }
    
    return self;
}

- (void)asynUploadMessage:(LLMessageModel *)model {
    [self upload:model];

}

- (void)upload:(LLMessageModel *)messageModel {
    WEAK_SELF;
    dispatch_async(_queue_upload, ^{
        [weakSelf uploadBlock:messageModel];
    });
}

- (void)uploadBlock:(LLMessageModel *)messageModel {
    NSLog(@"Before Wait");
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);

    BOOL needProgress = NO;
    if (messageModel.messageBodyType == kLLMessageBodyTypeVideo ||
        messageModel.messageBodyType == kLLMessageBodyTypeImage) {
        needProgress = YES;
    }
    
    BOOL needResend = NO;
    if (messageModel.sdk_message.status == kLLMessageStatusFailed)
        needResend = YES;
    
    WEAK_SELF;
    void (^progressBlock)(int _progress) = ^(int _progress) {
        messageModel.fileUploadProgress = _progress;
        [messageModel setNeedsUpdateUploadStatus];
        
        [[LLChatManager sharedManager] postMessageUploadStatusChangedNotification:messageModel];
    };
    
    void (^completeBlock)(EMMessage *message, EMError *_error) = ^(EMMessage *message, EMError *_error) {
        NSLog(@"Message Upload Complete %@", messageModel.messageId);

        dispatch_semaphore_signal(weakSelf.semaphore);
        if (!_error) {
            [messageModel updateMessage:message updateReason:kLLMessageModelUpdateReasonUploadComplete];
            messageModel.fileUploadProgress = 100;
        }
        
        LLSDKError *error = _error ? [LLSDKError errorWithEMError:_error] : nil;
        messageModel.error = error;
        [messageModel setNeedsUpdateUploadStatus];
        
        [messageModel internal_setMessageStatus:kLLMessageStatusNone];
        [[LLChatManager sharedManager] postMessageUploadStatusChangedNotification:messageModel];
    };

    if (needResend) {
        [[EMClient sharedClient].chatManager
         asyncResendMessage:messageModel.sdk_message
         progress: needProgress ? progressBlock : nil
         completion:completeBlock];
    }else {
        [[EMClient sharedClient].chatManager
         asyncSendMessage:messageModel.sdk_message
         progress: needProgress ? progressBlock : nil
         completion:completeBlock];
    }
    [messageModel internal_setMessageStatus:kLLMessageStatusDelivering];
    [[LLChatManager sharedManager] postMessageUploadStatusChangedNotification:messageModel];
 
}



@end
