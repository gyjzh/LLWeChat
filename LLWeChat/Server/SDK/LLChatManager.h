//
// Created by GYJZH on 7/19/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLConversationListController.h"
#import "LLChatViewController.h"
#import "LLConversationModel.h"
#import "EMChatManagerDelegate.h"
#import "EMClient.h"
#import "LLMessageModel.h"
#import "LLSDKType.h"
#import "LLSDKError.h"
#import "LLMessageSearchResultModel.h"

NS_ASSUME_NONNULL_BEGIN


#define LLMessageDownloadStatusChangedNotification @"LLMessageDownloadStatusChangedNotification"
#define LLMessageUploadStatusChangedNotification @"LLMessageUploadStatusChangedNotification"
#define LLMessageThumbnailDownloadCompleteNotification @"LLMessageThumbnailDownloadCompleteNotification"

#define LLChatManagerMessageModelKey @"LLChatManagerMessageModelKey"

//#define LLChatManagerDownloadProgressNotification @"LLChatManagerDownloadProgressNotification"
//#define LLChatManagerDownloadCompleteNotification @"LLChatManagerDownloadCompleteNotification"
//#define LLChatManagerUploadProgressNotification @"LLChatManagerUploadProgressNotification"
//#define LLChatManagerUploadCompleteNotification @"LLChatManagerUploadCompleteNotification"
//#define LLChatManagerErrorKey @"LLChatManagerErrorKey"


@protocol LLChatManagerMessageListDelegate <NSObject>

//该方法在主线程回调
- (void)loadMoreMessagesDidFinishedWithConversationModel:(LLConversationModel *)aConversationModel;

@end


@protocol LLChatManagerConversationListDelegate <NSObject>

//该方法在主线程回调
- (void)conversationListDidChanged:(NSArray<LLConversationModel *> *)conversationList;

- (void)unreadMessageNumberDidChanged;

- (NSMutableArray<LLConversationModel *> *)currentConversationList;

@end



@interface LLChatManager : NSObject <EMChatManagerDelegate>

@property (nonatomic, weak) id<LLChatManagerMessageListDelegate> messageListDelegate;
@property (nonatomic, weak) id<LLChatManagerConversationListDelegate> conversationListDelegate;

+ (instancetype)sharedManager;

- (void)getAllConversationFromDB;

- (void)getAllConversation;

- (void)loadMoreMessagesForConversationModel:(LLConversationModel *)conversationModel maxCount:(NSInteger)limit isDirectionUp:(BOOL)isDirectionUp;

- (BOOL)deleteConversation:(LLConversationModel *)conversationModel;

- (void)markAllMessagesAsRead:(LLConversationModel *)conversation;

- (LLConversationModel *)getConversationWithConversationChatter:
(NSString *)conversationChatter conversationType:(LLConversationType)conversationType;

//获取图片缩略图，SDK会自动下载缩略图，除非有必要才调用该方法
- (void)asyncDownloadMessageThumbnail:(LLMessageModel *)model
                           completion:(void (^ __nullable)(LLMessageModel *messageModel, LLSDKError *error))completion;

- (void)resendMessage:(LLMessageModel *)model
             progress:(void (^ __nullable)(LLMessageModel *model, int progress))progress
           completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

- (LLMessageModel *)sendTextMessage:(NSString *)text
                     to:(NSString *)toUser
            messageType:(LLChatType)messageType
             messageExt:(nullable NSDictionary *)messageExt
             completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

- (LLMessageModel *)sendGIFTextMessage:(NSString *)text
                                to:(NSString *)toUser
                       messageType:(LLChatType)messageType
                      emotionModel:(LLEmotionModel *)emotionModel
                        completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

- (LLMessageModel *)sendImageMessageWithData:(NSData *)imageData
                                   imageSize:(CGSize)imageSize
                     to:(NSString *)toUser
            messageType:(LLChatType)messageType
             messageExt:(nullable NSDictionary *)messageExt
               progress:(void (^ __nullable)(LLMessageModel *model, int progress))progress
             completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

//- (LLMessageModel *)sendLocationMessageWithLatitude:(double)latitude
//                longitude:(double)longitude
//                address:(NSString *)address
//                to:(NSString *)to
//                messageType:(LLChatType)messageType
//                messageExt:(nullable NSDictionary *)messageExt
//            completion:(void (^)(LLMessageModel *model, LLSDKError *error))completion;

- (LLMessageModel *)createLocationMessageWithLatitude:(double)latitude
                                            longitude:(double)longitude
                                            zoomLevel:(CGFloat)zoomLevel
                                                 name:(NSString *)name
                                              address:(NSString *)address
                                             snapshot:(UIImage *)snapshot
                                                   to:(NSString *)to
                                          messageType:(LLChatType)messageType;

- (void)updateAndSendLocationForMessageModel:(LLMessageModel *)messageModel
                             withSnapshot:(UIImage *)snapshot;

- (LLMessageModel *)sendLocationMessageWithLatitude:(double)latitude
                longitude:(double)longitude
                zoomLevel:(CGFloat)zoomLevel
                     name:(NSString *)name
                  address:(NSString *)address
                 snapshot:(UIImage *)snapshot
                       to:(NSString *)to
              messageType:(LLChatType)messageType
               completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

- (void)asynReGeocodeMessageModel:(LLMessageModel *)model
                       completion:(void (^)(LLMessageModel *messageModel, LLSDKError *error))completion;

- (void)asynDownloadMessageAttachments:(LLMessageModel *)model
                              progress:(void (^ __nullable)(LLMessageModel *model, int progress))progress
                            completion:(void (^ __nullable)(LLMessageModel *messageModel, LLSDKError *error))completion;


- (LLMessageModel *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                      duration:(NSInteger)duration
                            to:(NSString *)to
                   messageType:(LLChatType)messageType
                    messageExt:(nullable NSDictionary *)messageExt
                    completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;

- (void)changeVoiceMessageModelPlayStatus:(LLMessageModel *)model;

- (LLMessageModel *)sendVideoMessageWithLocalPath:(NSString *)localPath
               to:(NSString *)to
      messageType:(LLChatType)messageType
       messageExt:(nullable NSDictionary *)messageExt
         progress:(void (^ __nullable)(LLMessageModel *model, int progress))progress
       completion:(void (^ __nullable)(LLMessageModel *model, LLSDKError *error))completion;


- (BOOL)deleteMessage:(LLMessageModel *)model fromConversation:(LLConversationModel *)conversationModel;

- (NSMutableArray<LLMessageModel *> *)deleteMessages:(NSArray<LLMessageModel *> *)models fromConversation:(LLConversationModel *)conversationModel;

- (NSArray<NSArray<LLMessageSearchResultModel *> *> *)searchChatHistoryWithKeyword:(NSString *)keyword;

- (void)updateMessageModelWithTimestamp:(LLMessageModel *)messageModel timestamp:(CFTimeInterval)timestamp;

#pragma mark - Up/Download ，以下方法均在主线程执行-

- (void)postMessageUploadStatusChangedNotification:(LLMessageModel *)model;

- (void)postMessageDownloadStatusChangedNotification:(LLMessageModel *)model;

- (void)postThumbnailDownloadCompleteNotification:(LLMessageModel *)model;

NS_ASSUME_NONNULL_END


@end
