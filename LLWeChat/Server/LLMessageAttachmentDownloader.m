//
//  LLMessageAttachmentDownloader.m
//  LLWeChat
//
//  Created by GYJZH on 9/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageAttachmentDownloader.h"
#import "LLChatManager.h"
#import "LLUtils.h"

//最多允许多少线程同时下载，默认为一条
#define MAX_CONCURRENT_NUM 1

@interface LLMessageAttachmentDownloader ()

@property (nonatomic) dispatch_queue_t queue_download;

@property (nonatomic) NSMutableArray<LLMessageModel *> *queue_default_priority;

@property (nonatomic) NSMutableArray<LLMessageModel *> *queue_high_priority;

@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation LLMessageAttachmentDownloader

+ (instancetype)imageDownloader {
    static LLMessageAttachmentDownloader *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMessageAttachmentDownloader alloc] initWithQueueLabel:@"IMAGE_DOWNLOADER" concurrentNum:1];
    });
    
    return _instance;
}

+ (instancetype)videoDownloader {
    static LLMessageAttachmentDownloader *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLMessageAttachmentDownloader alloc] initWithQueueLabel:@"VIDEO_DOWNLOADER" concurrentNum:1];
    });
    
    return _instance;
}

- (instancetype)initWithQueueLabel:(NSString *)label concurrentNum:(long)semaphore {
    self = [super init];
    if (self) {
        _queue_download = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_CONCURRENT);
        _semaphore = dispatch_semaphore_create(semaphore);
        
        _queue_default_priority = [NSMutableArray arrayWithCapacity:10];
        _queue_high_priority = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (void)asynDownloadMessageAttachmentsWithDefaultPriority:(LLMessageModel *)model {
    @synchronized (self) {
        if ([self.queue_high_priority containsObject:model] || [self.queue_default_priority containsObject:model])
        return;
    
        NSLog(@"准备下载%@", model.messageBodyType == kLLMessageBodyTypeVideo ? @"视频" : @"图片");
        [self.queue_default_priority addObject:model];
        [self download];
    }
    
}

- (void)asynDownloadMessageAttachmentsWithHighPriority:(LLMessageModel *)model {
    @synchronized (self) {
        if ([self.queue_high_priority containsObject:model] || [self.queue_default_priority containsObject:model])
            return;

        [self.queue_high_priority addObject:model];
        [self download];
    }    
    
}

- (void)download {
    WEAK_SELF;
     dispatch_async(_queue_download, ^{
         [weakSelf downloadBlock];
    });
}

- (void)downloadBlock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    LLMessageModel *messageModel;
    @synchronized (self) {
        for (LLMessageModel *model in self.queue_high_priority) {
            if (!model.isDownloadingAttachment) {
                messageModel = model;
                messageModel.isDownloadingAttachment = YES;
                break;
            }
        }
        
        if (!messageModel) {
            for (LLMessageModel *model in self.queue_default_priority) {
                if (!model.isDownloadingAttachment) {
                    messageModel = model;
                    messageModel.isDownloadingAttachment = YES;
                    break;
                }
            }
        }
    }
    
    if (messageModel) {
        BOOL needProgress = NO;
        if (messageModel.messageBodyType == kLLMessageBodyTypeVideo ||
            messageModel.messageBodyType == kLLMessageBodyTypeImage) {
            needProgress = YES;
        }
        
        WEAK_SELF;
        [[EMClient sharedClient].chatManager
         asyncDownloadMessageAttachments:messageModel.sdk_message
         progress:!needProgress ? nil : ^(int _progress) {
             messageModel.fileDownloadProgress = _progress;
             [messageModel setNeedsUpdateDownloadStatus];
             [[LLChatManager sharedManager] postMessageDownloadStatusChangedNotification:messageModel];
         }
         
         completion:^(EMMessage *message, EMError *_error) {
             NSLog(@"%@下载%@", message.body.type == EMMessageBodyTypeVideo ? @"视频" :@"图片", _error? @"出错":@"成功");
             dispatch_semaphore_signal(weakSelf.semaphore);
             
             @synchronized (weakSelf) {
                 messageModel.isDownloadingAttachment = NO;
                 [weakSelf.queue_default_priority removeObject:messageModel];
                 [weakSelf.queue_high_priority removeObject:messageModel];
             }
             
             if (!_error) {
                 [messageModel updateMessage:message updateReason:kLLMessageModelUpdateReasonAttachmentDownloadComplete];
                 messageModel.fileDownloadProgress = 100;
             }
             
             LLSDKError *error = _error ? [LLSDKError errorWithEMError:_error] : nil;
             messageModel.error = error;
             [messageModel setNeedsUpdateDownloadStatus];
             [messageModel internal_setMessageDownloadStatus:kLLMessageDownloadStatusNone];
             
             [[LLChatManager sharedManager] postMessageDownloadStatusChangedNotification:messageModel];
             [messageModel internal_setIsFetchingAttachment:NO];
         }];
        messageModel.error = nil;
        [messageModel internal_setMessageDownloadStatus:kLLMessageDownloadStatusDownloading];
        [[LLChatManager sharedManager] postMessageDownloadStatusChangedNotification:messageModel];

    }else {
        dispatch_semaphore_signal(_semaphore);
    }
}



@end
