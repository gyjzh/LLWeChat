//
// Created by GYJZH on 7/19/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import "LLChatManager.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "LLPushOptions.h"
#import "LLSDKError.h"
#import "LLUserProfile.h"
#import "LLLocationManager.h"
#import "LLChatManager+MessageExt.h"
#import "LLMessageAttachmentDownloader.h"
#import "LLMessageModelManager.h"
#import "LLMessageCellManager.h"
#import "LLMessageUploader.h"
#import "LLMessageThumbnailManager.h"
#import "LLMessageCacheManager.h"
#import "LLConversationModelManager.h"

#define NEW_MESSAGE_QUEUE_LABEL "NEW_MESSAGE_QUEUE"

static NSDate *lastPlaySoundDate;

@interface LLChatManager ()

@property (nonatomic) dispatch_queue_t messageQueue;

@property (nonatomic) dispatch_queue_t uploader_queue;

@property (nonatomic) dispatch_semaphore_t uploadImageSemaphore;

@property (nonatomic) dispatch_semaphore_t uploadVideoSemaphore;

@end


@implementation LLChatManager

CREATE_SHARED_MANAGER(LLChatManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _messageQueue = dispatch_queue_create(NEW_MESSAGE_QUEUE_LABEL, DISPATCH_QUEUE_SERIAL );
        
        _uploadImageSemaphore = dispatch_semaphore_create(1);
        
        _uploadVideoSemaphore = dispatch_semaphore_create(1);
        
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

        lastPlaySoundDate = [NSDate date];
    }
    
    return self;
}

#pragma mark - 处理会话列表

- (void)processConversationList:(NSArray<EMConversation *> *)conversationList {
    NSArray<LLConversationModel *> *conversationListModels = [[LLConversationModelManager sharedManager] updateConversationListAfterLoad:conversationList];
    
    WEAK_SELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.conversationListDelegate conversationListDidChanged:conversationListModels];
    });

}


- (void)getAllConversationFromDB {
    NSLog(@"从数据库中加载会话");
    
    WEAK_SELF;
    dispatch_async(_messageQueue, ^{
        NSArray<EMConversation *> *array = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
        [weakSelf processConversationList:array];

    });
}

- (void)getAllConversation {
    NSLog(@"从内存中加载会话");
    
    WEAK_SELF;
    dispatch_async(_messageQueue, ^{
        NSArray<EMConversation *> *array = [[EMClient sharedClient].chatManager getAllConversations];
        [weakSelf processConversationList:array];

    });
}


//会话列表发生改变 来自 ChatManagerDelegate
- (void)didUpdateConversationList:(NSArray *)aConversationList {
    NSLog(@"消息列表发生改变");
}

- (BOOL)deleteConversation:(LLConversationModel *)conversationModel {
    BOOL result = [[EMClient sharedClient].chatManager deleteConversation:conversationModel.sdk_conversation.conversationId deleteMessages:YES];
    if (result) {
        [[LLMessageCacheManager sharedManager] deleteConversation:conversationModel.conversationId];
        [[LLConversationModelManager sharedManager] removeConversationModel:conversationModel];
    }
    
    return result;
}


#pragma mark - 处理消息

- (void)preprocessMessageModel:(LLMessageModel *)messageModel priority:(LLMessageDownloadPriority)priority {
    
    if (messageModel.isFromMe) {
        LLMessageStatus messageStatus = messageModel.messageStatus;
        //需要上传的消息
        if (messageStatus == kLLMessageStatusPending) {
            [self sendMessage:messageModel needInsertToDB:NO];
        }
    }else {
        //下载缩略图
        [self asyncDownloadMessageThumbnail:messageModel completion:nil];

        //需要下载附件
        if (messageModel.messageBodyType == kLLMessageBodyTypeImage) {
            if (messageModel.messageDownloadStatus == kLLMessageDownloadStatusPending) {
                [self asynDownloadMessageAttachments:messageModel progress:nil completion:nil];
            }
        }else if (messageModel.messageBodyType == kLLMessageBodyTypeFile ||
            messageModel.messageBodyType == kLLMessageBodyTypeVoice ||
            messageModel.messageBodyType == kLLMessageBodyTypeLocation) {
            LLMessageDownloadStatus attachmentDownloadStatus = messageModel.messageDownloadStatus;
            
            if (attachmentDownloadStatus == kLLMessageDownloadStatusFailed ||
                attachmentDownloadStatus == kLLMessageDownloadStatusPending) {
                [self asynDownloadMessageAttachments:messageModel progress:nil completion:nil];
            }
        }
    }
   
}


#pragma mark - 有新消息 -

- (void)didReceiveMessages:(NSArray *)aMessages {
    NSLog(@"收到%ld条新消息", (unsigned long)aMessages.count);
    
    //显示新消息通知
#if !TARGET_IPHONE_SIMULATOR
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:lastPlaySoundDate];
    if (timeInterval > DEFAULT_PLAYSOUND_INTERVAL) {
        lastPlaySoundDate = [NSDate date];
       
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
            case UIApplicationStateActive:
            case UIApplicationStateInactive:
                if ([LLUserProfile myUserProfile].pushOptions.isAlertSoundEnabled) {
                    [LLUtils playNewMessageSound];
                }
                if ([LLUserProfile myUserProfile].pushOptions.isVibrateEnabled) {
                    [LLUtils playVibration];
                }
            
                break;

            case UIApplicationStateBackground:
                [self showNotificationWithMessage:[aMessages lastObject]];
                break;
            default:
                break;
        }
    }

#endif
    WEAK_SELF;
    dispatch_async(_messageQueue, ^() {
        LLConversationModel *curConversationModel = [LLConversationModelManager sharedManager].currentActiveConversationModel;
    
        NSMutableArray<LLMessageModel *> *newMessageModels = [NSMutableArray array];
        [aMessages enumerateObjectsUsingBlock:^(EMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            if (message.chatType != EMChatTypeChat)
                return;
            
            LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
            if (curConversationModel && [message.conversationId isEqualToString:curConversationModel.conversationId]) {
                [curConversationModel.sdk_conversation markMessageAsReadWithId:message.messageId];
                [newMessageModels addObject:model];
                [self preprocessMessageModel:model priority:kLLMessageDownloadPriorityDefault];
            }else {
                [self preprocessMessageModel:model priority:kLLMessageDownloadPriorityLow];
            }

        }];
        
        if (newMessageModels.count > 0) {
            [curConversationModel.allMessageModels addObjectsFromArray:newMessageModels];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                curConversationModel.updateType = kLLMessageListUpdateTypeNewMessage;
                [weakSelf.messageListDelegate loadMoreMessagesDidFinishedWithConversationModel:curConversationModel];
            });
        }
        
        //更新会话列表
        NSArray<LLConversationModel *> *conversationList = [[LLConversationModelManager sharedManager] updateConversationListAfterReceiveNewMessages:aMessages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.conversationListDelegate conversationListDidChanged:conversationList];
        });
    
    });
    
}


- (void)loadMoreMessagesForConversationModel:(LLConversationModel *)conversationModel maxCount:(NSInteger)limit isDirectionUp:(BOOL)isDirectionUp {
    BOOL shouldAsyncLoadMessage = conversationModel.referenceMessageModel != nil;
//    || conversationModel.draft.length > 0;

    WEAK_SELF;
    void (^block)() = ^() {
        BOOL hasLoadedEarliestMessage = NO;
        NSArray<LLMessageModel *> *newMessageModels = [[LLMessageModelManager sharedManager] loadMoreMessagesForConversationModel:conversationModel limit:(int)limit isDirectionUp:isDirectionUp hasLoadedEarliestMessage:&hasLoadedEarliestMessage];
        
        NSString *fromId = conversationModel.referenceMessageModel.messageId;
        if (newMessageModels.count > 0) {
            [conversationModel.allMessageModels insertObjects:newMessageModels atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newMessageModels.count)]];
            fromId = newMessageModels[0].messageId;
        }
        
        //消息已经全部在缓存中
        if (newMessageModels.count == limit || hasLoadedEarliestMessage) {
            conversationModel.updateType = hasLoadedEarliestMessage ? kLLMessageListUpdateTypeLoadMoreComplete : kLLMessageListUpdateTypeLoadMore;
            
            void (^loadCompleteBlock)() = ^() {
                [weakSelf.messageListDelegate loadMoreMessagesDidFinishedWithConversationModel:conversationModel];
            };
            
            if (shouldAsyncLoadMessage) {
                dispatch_async(dispatch_get_main_queue(), loadCompleteBlock);
            }else {
//                loadCompleteBlock();
            }
            
            return;
        }
        
        //从数据库中加载消息
        NSInteger num = limit - newMessageModels.count;
        NSArray *messageList = [conversationModel.sdk_conversation loadMoreMessagesFromId:fromId limit:(int)num direction:EMMessageSearchDirectionUp];
        
        NSLog(@"从数据库中获取到%ld条消息", (unsigned long)messageList.count);
        LLMessageListUpdateType updateType = kLLMessageListUpdateTypeLoadMore;
        //从数据库中全部获取了历史消息
        if (messageList.count < num) {
            updateType = kLLMessageListUpdateTypeLoadMoreComplete;
            [[LLMessageModelManager sharedManager] markEarliestMessageLoadedForConversation:conversationModel.conversationId];
        }
        
        if (messageList.count > 0){
            NSMutableArray<LLMessageModel *> *newMessageModels = [NSMutableArray arrayWithCapacity:messageList.count];
            [messageList enumerateObjectsUsingBlock:^(EMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL shouldIgnore = NO;
                //FIXME:现在还有必要做这个判断吗？
                switch (message.body.type) {
                    case EMMessageBodyTypeImage:{
                        EMImageMessageBody *imageBody = (EMImageMessageBody *)message.body;
                        if (imageBody.size.width == 0 || imageBody.size.height == 0){
                            shouldIgnore = YES;
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
                
                if (!shouldIgnore) {
                    LLMessageModel *model = [[LLMessageModel alloc] initWithMessage:message];
                    [newMessageModels addObject:model];
                    
                    [weakSelf preprocessMessageModel:model priority:kLLMessageDownloadPriorityDefault];
                }
            }];
            
            [[LLMessageModelManager sharedManager] addMessageList:newMessageModels toConversation:conversationModel.conversationId isAppend:NO];
            
            [conversationModel.allMessageModels insertObjects:newMessageModels atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newMessageModels.count)]];
        }
        
        conversationModel.updateType = updateType;

    };
    
    if (shouldAsyncLoadMessage) {
        dispatch_async(_messageQueue, ^() {
            block();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.messageListDelegate loadMoreMessagesDidFinishedWithConversationModel:conversationModel];
            });
        });
    }else {
        block();
    }

}


- (void)markAllMessagesAsRead:(LLConversationModel *)conversation {
    [conversation.sdk_conversation markAllMessagesAsRead];

    SAFE_SEND_MESSAGE(self.conversationListDelegate, unreadMessageNumberDidChanged) {
        [self.conversationListDelegate unreadMessageNumberDidChanged];
    }
}

- (LLConversationModel *)getConversationWithConversationChatter:
    (NSString *)conversationChatter conversationType:(LLConversationType)conversationType {
    EMConversation *_conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:(EMConversationType)conversationType createIfNotExist:YES];
    LLConversationModel *model = [LLConversationModel conversationModelFromPool:_conversation];
    
    return model;
}

#pragma mark - 消息状态改变

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError {
    NSLog(@"消息状态改变 %d", aMessage.status);
}

//缩略图下载成功后调用该方法，图片、视频附件下载完毕后不调用该方法
//语言消息下载完毕后同样调用该方法
//FIXME: 是否可以认为只要是SDK自动下载的都会回调该方法，用户主动下载的不回调该方法？？
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)aMessage
                                     error:(EMError *)aError {
    NSLog(@"消息附件状态改变 ");
    if (aMessage.direction == EMMessageDirectionSend)
        return;
    
    BOOL needPostNotification = NO;
    switch (aMessage.body.type) {
        case EMMessageBodyTypeVideo: {
            EMImageMessageBody *body = (EMImageMessageBody *)aMessage.body;
            if (body.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                needPostNotification = YES;
            }
            break;
        }
        case EMMessageBodyTypeImage: {
            EMVideoMessageBody *body = (EMVideoMessageBody *)aMessage.body;
            if (body.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                needPostNotification = YES;
            }
            break;
        }
        case EMMessageBodyTypeVoice: {
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)aMessage.body;
            if (body.downloadStatus == EMDownloadStatusSuccessed) {
                needPostNotification = YES;
            }
            break;
        }
           
        default:
            break;
    }
    if (!needPostNotification)
        return;

    LLMessageModel *model = [[LLMessageModelManager sharedManager] messageModelForEMMessage:aMessage];
    if (!model) {
        NSLog(@"FIXME：发生未知错误");
        return;
    }
    if (!aError) {
        switch (model.messageBodyType) {
            case kLLMessageBodyTypeImage:
            case kLLMessageBodyTypeVideo: {
                [model updateMessage:aMessage updateReason:kLLMessageModelUpdateReasonThumbnailDownloadComplete];
                break;
            }
            case kLLMessageBodyTypeVoice:{
                [model updateMessage:aMessage updateReason:kLLMessageModelUpdateReasonAttachmentDownloadComplete];
                break;
            }
                
            default:
                break;
        }
  
    }
    
    LLSDKError *error = aError ? [LLSDKError errorWithEMError:aError] : nil;
    model.error = error;
    switch (model.messageBodyType) {
        case kLLMessageBodyTypeImage:
        case kLLMessageBodyTypeVideo: {
            [self postThumbnailDownloadCompleteNotification:model];
            break;
        }
        case kLLMessageBodyTypeVoice: {
            [self postMessageDownloadStatusChangedNotification:model];
            break;
        }
        default:
            break;
    }

}


#pragma mark - Download/Upload Notification

- (void)postMessageUploadStatusChangedNotification:(LLMessageModel *)model {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:LLMessageUploadStatusChangedNotification
     object:self
     userInfo:@{LLChatManagerMessageModelKey:model}];
}

- (void)postMessageDownloadStatusChangedNotification:(LLMessageModel *)model {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:LLMessageDownloadStatusChangedNotification
     object:self
     userInfo:@{LLChatManagerMessageModelKey:model}];
}

- (void)postThumbnailDownloadCompleteNotification:(LLMessageModel *)model {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:LLMessageThumbnailDownloadCompleteNotification
     object:self
     userInfo:@{LLChatManagerMessageModelKey:model}];
}


#pragma mark - 获取缩略图

- (void)asyncDownloadMessageThumbnail:(LLMessageModel *)model
                           completion:(void (^)(LLMessageModel *messageModel, LLSDKError *error))completion {
    if (model.isFetchingThumbnail)
        return;
    
    EMDownloadStatus thumbnailDownloadStatus = EMDownloadStatusSuccessed;;
    switch (model.messageBodyType) {
        case kLLMessageBodyTypeImage: {
            EMImageMessageBody *body = (EMImageMessageBody *)model.sdk_message.body;
            thumbnailDownloadStatus = body.thumbnailDownloadStatus;
            break;
        }
        case kLLMessageBodyTypeVideo: {
            EMVideoMessageBody *body = (EMVideoMessageBody *)model.sdk_message.body;
            thumbnailDownloadStatus = body.thumbnailDownloadStatus;
            break;
        }
        default:
            break;
    }
    if (thumbnailDownloadStatus == EMDownloadStatusSuccessed ||
        thumbnailDownloadStatus == EMDownloadStatusDownloading)
        return;

    [model internal_setIsFetchingThumbnail:YES];
    [[EMClient sharedClient].chatManager
     asyncDownloadMessageThumbnail:model.sdk_message
                          progress:nil
                        completion:^(EMMessage *message, EMError *aError) {
        LLSDKError *error = aError ? [LLSDKError errorWithEMError:aError] : nil;
        if (!aError) {
            [model updateMessage:message updateReason:kLLMessageModelUpdateReasonThumbnailDownloadComplete];
        }
        
        model.error = error;
        if (completion) {
            completion(model, error);
        }else
            [self postThumbnailDownloadCompleteNotification:model];
        [model internal_setIsFetchingThumbnail:NO];
    }];
    
}

#pragma mark - 异步下载Attachment -

- (void)asynDownloadMessageAttachments:(LLMessageModel *)model
                              progress:(void (^)(LLMessageModel *model, int progress))progress
                            completion:(void (^)(LLMessageModel *messageModel, LLSDKError *error))completion {
    if (model.isFetchingAttachment)
        return;
    
    EMMessageBody *body = model.sdk_message.body;
    if (![body isKindOfClass:[EMFileMessageBody class]]) {
        return;
    }
    
    EMFileMessageBody *fileMessageBody = (EMFileMessageBody *)body;
    
    if (fileMessageBody.downloadStatus == EMDownloadStatusPending ||
      fileMessageBody.downloadStatus == EMDownloadStatusFailed) {
        [model internal_setIsFetchingAttachment:YES];
        //FIXME:SDK不支持断点下载，所以此处设置为0
        model.fileDownloadProgress = 0;
        //开始下载前，清空原来错误消息
        model.error = nil;
        [model internal_setMessageDownloadStatus:kLLMessageDownloadStatusWaiting];
        
        [self postMessageDownloadStatusChangedNotification:model];
        switch (model.messageBodyType) {
            case kLLMessageBodyTypeVideo:
                [[LLMessageAttachmentDownloader videoDownloader] asynDownloadMessageAttachmentsWithDefaultPriority:model];
                break;
            case kLLMessageBodyTypeImage:
            case kLLMessageBodyTypeVoice:
            case kLLMessageBodyTypeFile:
            case kLLMessageBodyTypeLocation: {
                [[LLMessageAttachmentDownloader imageDownloader] asynDownloadMessageAttachmentsWithDefaultPriority:model];
                break;
            }
            default:
                break;
        }
    }
  
}

#pragma mark - 发送消息

- (void)sendMessage:(LLMessageModel *)messageModel needInsertToDB:(BOOL)needInsertToDB {
    if (needInsertToDB) {
        LLConversationModel *conversation = [[LLConversationModelManager sharedManager] conversationModelForConversationId:messageModel.conversationId];
      [conversation.sdk_conversation insertMessage:messageModel.sdk_message];
    }
 
    [messageModel internal_setMessageStatus:kLLMessageStatusWaiting];
    //FIXME: SDK不支持断点重传，所以这是重置为0
    messageModel.fileUploadProgress = 0;
    messageModel.error = nil;
    [self postMessageUploadStatusChangedNotification:messageModel];
    
    switch (messageModel.messageBodyType) {
        case kLLMessageBodyTypeImage:
            [[LLMessageUploader imageUploader] asynUploadMessage:messageModel];
            break;
        case kLLMessageBodyTypeVideo:
            [[LLMessageUploader videoUploader] asynUploadMessage:messageModel];
            break;
        default:
            [[LLMessageUploader defaultUploader] asynUploadMessage:messageModel];
            break;
    }
    
}

- (void)resendMessage:(LLMessageModel *)messageModel
             progress:(void (^)(LLMessageModel *model, int progress))progress
           completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion {
    [self sendMessage:messageModel needInsertToDB:NO];
}


#pragma mark - 发送文字消息

- (LLMessageModel *)sendTextMessage:(NSString *)text
                            to:(NSString *)toUser
                   messageType:(LLChatType)messageType
                    messageExt:(NSDictionary *)messageExt
                    completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion {
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    [self sendMessage:model needInsertToDB:YES];

    return model;
}

#pragma mark - 发送Gif消息

- (LLMessageModel *)sendGIFTextMessage:(NSString *)text
                                 to:(NSString *)toUser
                        messageType:(LLChatType)messageType
                         emotionModel:(LLEmotionModel *)emotionModel
                         completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion {
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSMutableDictionary *messageExt = [self encodeGifMessageExtForEmotionModel:emotionModel];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    [self sendMessage:model needInsertToDB:YES];
    
    return model;
}


#pragma mark - 发送图片消息

- (LLMessageModel *)sendImageMessageWithData:(NSData *)imageData
                                   imageSize:(CGSize)imageSize
                                          to:(NSString *)toUser
                                 messageType:(LLChatType)messageType
                                  messageExt:(NSDictionary *)messageExt
                                    progress:(void (^)(LLMessageModel *model, int progress))progress
                                  completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion {
    
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:imageData displayName:@"image.png"];
    body.size = imageSize;
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    [self sendMessage:model needInsertToDB:YES];
    
    return model;
}



#pragma mark - 发送地址消息
//- (LLMessageModel *)sendLocationMessageWithLatitude:(double)latitude
//                                     longitude:(double)longitude
//                                       address:(NSString *)address
//                                            to:(NSString *)to
//                                   messageType:(LLChatType)messageType
//                                    messageExt:(NSDictionary *)messageExt
//                                    completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion
//{
//    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude longitude:longitude address:address];
//    NSString *from = [[EMClient sharedClient] currentUsername];
//    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
//    message.chatType = (EMChatType)messageType;
//    
//    LLMessageModel *model = [[LLMessageModel alloc] initWithMessage:message];
//    
//    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
//            if (completion) {
//                [model updateMessage:aMessage];
//                completion(model, aError ? [LLSDKError errorWithEMError:aError] : nil);
//            }
//    }];
//    
//    return model;
//}


- (LLMessageModel *)sendLocationMessageWithLatitude:(double)latitude
                                          longitude:(double)longitude
                                          zoomLevel:(CGFloat)zoomLevel
                                               name:(NSString *)name
                                            address:(NSString *)address
                                           snapshot:(UIImage *)snapshot
                                                 to:(NSString *)to
                                        messageType:(LLChatType)messageType
                                         completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion
{
    NSData *data = UIImageJPEGRepresentation(snapshot, 1);
    EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithData:data displayName:nil];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSDictionary *messageExt = [self encodeLocationMessageExt:latitude longitude:longitude address:address name:name zoomLevel:zoomLevel defaultSnapshot:!snapshot];
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    [self sendMessage:model needInsertToDB:YES];
    
    return model;
}

- (LLMessageModel *)createLocationMessageWithLatitude:(double)latitude
                                            longitude:(double)longitude
                                            zoomLevel:(CGFloat)zoomLevel
                                                 name:(NSString *)name
                                              address:(NSString *)address
                                             snapshot:(UIImage *)snapshot
                                                   to:(NSString *)to
                                          messageType:(LLChatType)messageType
{
    NSData *data;
    if (snapshot) {
        data = UIImageJPEGRepresentation(snapshot, 1);
    }
    
    EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithData:data displayName:nil];
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSDictionary *messageExt = [self encodeLocationMessageExt:latitude longitude:longitude address:address name:name zoomLevel:zoomLevel defaultSnapshot:NO];
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    
    return model;
}


- (void)updateAndSendLocationForMessageModel:(LLMessageModel *)messageModel
                                    withSnapshot:(UIImage *)snapshot {
    NSData *data = UIImageJPEGRepresentation(snapshot, 1);
    EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithData:data displayName:nil];
    
    if (snapshot) {
        NSMutableDictionary *messageExt = [messageModel.sdk_message.ext mutableCopy];
        messageExt[@"defaultSnapshot"] = @(NO);
        messageModel.defaultSnapshot = NO;
        messageModel.sdk_message.ext = messageExt;
    }else {
        messageModel.defaultSnapshot = YES;
    }

    messageModel.sdk_message.body = body;
   
    BOOL result = [[EMClient sharedClient].chatManager updateMessage:messageModel.sdk_message];

    NSLog(@"更新LocationMessage缩略图 %@", result? @"成功": @"失败");

    [self sendMessage:messageModel needInsertToDB:NO];
}


- (void)asynReGeocodeMessageModel:(LLMessageModel *)model
                       completion:(void (^)(LLMessageModel *messageModel, LLSDKError *error))completion {
    [[LLLocationManager sharedManager] reGeocodeFromCoordinate:model.coordinate2D
            completeCallback:^(AMapReGeocode *reGeoCode, CLLocationCoordinate2D coordinate2D) {
              if (!reGeoCode) {
                  if (completion) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          model.address = LOCATION_EMPTY_ADDRESS;
                          model.locationName = LOCATION_EMPTY_NAME;
                          model.error = [LLSDKError errorWithDescription:@"逆地理失败" code:LLSDKErrorGeneral];
                          [model setNeedsUpdateForReuse];
                          completion(model, model.error);
                      });
                  }
                  return;
              }
              
              NSString *address;
              NSString *name;
              [[LLLocationManager sharedManager] getLocationNameAndAddressFromReGeocode:reGeoCode name:&name address:&address];
              
              NSMutableDictionary *dict = [model.sdk_message.ext mutableCopy];
              dict[@"name"] = name;
              dict[@"address"] = address;
              model.sdk_message.ext = dict;
              BOOL result = [[EMClient sharedClient].chatManager updateMessage:model.sdk_message];
              NSLog(@"更新LocationMessage %@", result? @"成功": @"失败");
              
              [model updateMessage:model.sdk_message updateReason:kLLMessageModelUpdateReasonReGeocodeComplete];
              if (completion) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      model.error = nil;
                      [model setNeedsUpdateForReuse];
                      completion(model, model.error);
                  });
              }
          }];

}


#pragma mark - 发送语音消息

- (LLMessageModel *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                    duration:(NSInteger)duration
                                          to:(NSString *)to
                                 messageType:(LLChatType)messageType
                                  messageExt:(NSDictionary *)messageExt
                                  completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:localPath displayName:@"audio"];
    body.duration = (int)duration;
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:messageExt];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    model.needAnimateVoiceCell = YES;
    
    [self sendMessage:model needInsertToDB:YES];
    
    return model;
}


- (void)changeVoiceMessageModelPlayStatus:(LLMessageModel *)model {
    if (model.messageBodyType != kLLMessageBodyTypeVoice)
        return;
    model.isMediaPlaying = !model.isMediaPlaying;
    if (!model.isMediaPlayed) {
        model.isMediaPlayed = YES;
        EMMessage *chatMessage = model.sdk_message;
        NSMutableDictionary *dict;
        if (chatMessage.ext)
            dict = [chatMessage.ext mutableCopy];
        else
            dict = [NSMutableDictionary dictionary];
        
        dict[@"isPlayed"] = @(YES);
        chatMessage.ext = dict;
        [[EMClient sharedClient].chatManager updateMessage:chatMessage];
        
    }
    
}

#pragma mark - 发送视频消息

- (LLMessageModel *)sendVideoMessageWithLocalPath:(NSString *)localPath
                                               to:(NSString *)to
                                      messageType:(LLChatType)messageType
                                       messageExt:(NSDictionary *)messageExt
                                         progress:(void (^)(LLMessageModel *model, int progress))progress
                                       completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:localPath displayName:@"video.mp4"];
    NSString *from = [[EMClient sharedClient] currentUsername];

    body.thumbnailSize = [LLUtils getVideoSize:localPath];
    body.duration = round([LLUtils getVideoLength:localPath]);
    body.fileLength = [LLUtils getFileSize:localPath];
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = (EMChatType)messageType;
    
    LLMessageModel *model = [LLMessageModel messageModelFromPool:message];
    [self sendMessage:model needInsertToDB:YES];
    
    return model;
}


- (void)updateMessageModelWithTimestamp:(LLMessageModel *)messageModel timestamp:(CFTimeInterval)timestamp {
    if (!messageModel)
        return;
    
    //INFO: 环信SDK时间戳单位是毫秒，所以此处乘以1000
    messageModel.sdk_message.timestamp = timestamp * 1000;
    messageModel.timestamp = timestamp;
    BOOL result = [[EMClient sharedClient].chatManager updateMessage:messageModel.sdk_message];
    NSLog(@"更新Message时间戳 %@", result? @"成功": @"失败");
    
}


#pragma mark - 删除消息 -

- (BOOL)deleteMessage:(LLMessageModel *)model fromConversation:(LLConversationModel *)conversationModel {
    BOOL result = [conversationModel.sdk_conversation deleteMessageWithId:model.messageId];
    if (result) {
        [[LLMessageCacheManager sharedManager] deleteMessageModel:model];
    }
    return result;
}

//INFO: 环信SDK没有提供批量删除消息的接口，所以需要一条一条删
- (NSMutableArray<LLMessageModel *> *)deleteMessages:(NSArray<LLMessageModel *> *)models fromConversation:(LLConversationModel *)conversationModel {
    NSMutableArray<LLMessageModel *> *deleteModels = [NSMutableArray array];
    for (LLMessageModel *model in models) {
        BOOL result = [conversationModel.sdk_conversation deleteMessageWithId:model.messageId];
        if (result) {
            [deleteModels addObject:model];
        }
    }
    
    if (deleteModels.count > 0) {
        [[LLMessageCacheManager sharedManager] deleteMessageModelsInArray:deleteModels];
    }
    
    return deleteModels;
}


#pragma mark - 消息通知 -

- (void)showNotificationWithMessage:(EMMessage *)message
{
    LLPushOptions *options = [LLUserProfile myUserProfile].pushOptions;
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间

    if (options.displayStyle == kLLPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                if (!message.ext)
                    messageStr = ((EMTextMessageBody *)messageBody).text;
                else {
                    messageStr = @"发来一个表情";
                }
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"发来一张图片";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"分享了一个地理位置";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"发来一段语音";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = @"发来一段视频";
            }
                break;
            default:
                break;
        }
    
        if (messageBody.type == EMMessageBodyTypeText) {
            notification.alertBody = [NSString stringWithFormat:@"%@:%@", message.from, messageStr];
        }else {
            notification.alertBody = [NSString stringWithFormat:@"%@%@", message.from, messageStr];
        }
        
    }else {
        notification.alertBody = @"您有一条新消息";
    }
    
//去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    if (options.isVibrateEnabled) {
        [LLUtils playVibration];
    }
    if (options.isAlertSoundEnabled) {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }
    notification.alertTitle = message.from;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


#pragma mark - 消息查找 -

- (NSArray<NSArray<LLMessageSearchResultModel *> *> *)searchChatHistoryWithKeyword:(NSString *)keyword {
    NSArray<EMConversation *> *allConversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray<NSArray *> *result = [NSMutableArray array];
    
    for (EMConversation *conversation in allConversations) {
        NSArray<EMMessage *> *messageList = [conversation loadMoreMessagesContain:keyword before:-1 limit:-1 from:nil direction:EMMessageSearchDirectionUp];

        if (messageList.count > 0) {
            NSMutableArray<LLMessageSearchResultModel *> *messageModels = [NSMutableArray arrayWithCapacity:messageList.count];
 
            [messageList enumerateObjectsUsingBlock:^(EMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
                LLMessageSearchResultModel *model = [[LLMessageSearchResultModel alloc] initWithMessage:message];
                [messageModels addObject:model];
            }];
            
            [result addObject:messageModels];
        }
    }
    
    return result;
}


#pragma mark - 其他



@end
