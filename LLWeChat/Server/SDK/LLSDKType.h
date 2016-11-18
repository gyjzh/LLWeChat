//
//  LLSDKType.h
//  LLWeChat
//
//  Created by GYJZH on 8/4/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#ifndef LLSDKType_h
#define LLSDKType_h

#import "EMMessage.h"
#import "EMMessageBody.h"
#import "EMConversation.h"
#import "EMFileMessageBody.h"

static NSString *LLConnectionStateDidChangedNotification = @"LLConnectionStateDidChangedNotification";

typedef NS_ENUM(NSInteger, LLConnectionState) {
    kLLConnectionStateConnected = 0,
    kLLConnectionStateDisconnected,
};

typedef NS_ENUM(NSInteger, LLMessageBodyType) {
    kLLMessageBodyTypeText = EMMessageBodyTypeText,
    kLLMessageBodyTypeImage = EMMessageBodyTypeImage,
    kLLMessageBodyTypeVideo = EMMessageBodyTypeVideo,
    kLLMessageBodyTypeVoice = EMMessageBodyTypeVoice,
    kLLMessageBodyTypeEMLocation = EMMessageBodyTypeLocation,
    kLLMessageBodyTypeFile = EMMessageBodyTypeFile,
    kLLMessageBodyTypeDateTime,
    kLLMessageBodyTypeGif,
    kLLMessageBodyTypeLocation,
    kLLMessageBodyTypeRecording, //表示正在录音的Cell
    
};

typedef NS_ENUM(NSInteger, LLMessageDownloadStatus) {
    kLLMessageDownloadStatusDownloading = EMDownloadStatusDownloading,
    kLLMessageDownloadStatusSuccessed = EMDownloadStatusSuccessed,
    kLLMessageDownloadStatusFailed = EMDownloadStatusFailed,
    kLLMessageDownloadStatusPending = EMDownloadStatusPending,
    kLLMessageDownloadStatusWaiting = 10086,
    kLLMessageDownloadStatusNone
};

typedef NS_ENUM(NSInteger, LLMessageStatus) {
    kLLMessageStatusPending  = EMMessageStatusPending,
    kLLMessageStatusDelivering = EMMessageStatusDelivering,
    kLLMessageStatusSuccessed = EMMessageStatusSuccessed,
    kLLMessageStatusFailed = EMMessageStatusFailed,
    kLLMessageStatusWaiting = 10086,
    kLLMessageStatusNone
};

typedef NS_ENUM(NSInteger, LLChatType) {
    kLLChatTypeChat   = EMChatTypeChat,   /*! \~chinese 单聊消息 \~english Chat */
    kLLChatTypeGroupChat = EMChatTypeGroupChat,
    kLLChatTypeChatRoom = EMChatTypeChatRoom
};

typedef NS_ENUM(NSInteger, LLConversationType) {
    kLLConversationTypeChat = EMConversationTypeChat,
    kLLConversationTypeGroupChat = EMConversationTypeGroupChat,
    kLLConversationTypeChatRoom = EMConversationTypeChatRoom
};

typedef NS_ENUM(NSInteger, LLMessageDirection) {
    kLLMessageDirectionSend = EMMessageDirectionSend,
    kLLMessageDirectionReceive = EMMessageDirectionReceive
};

static inline LLChatType chatTypeForConversationType(LLConversationType conversationType) {
    switch (conversationType) {
        case kLLConversationTypeChat:
            return kLLChatTypeChat;
        case kLLConversationTypeChatRoom:
            return kLLChatTypeChatRoom;
        case kLLConversationTypeGroupChat:
            return kLLChatTypeGroupChat;
    }
}


#endif /* LLSDKType_h */
