//
// Created by GYJZH on 7/19/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import "LLConversationModel.h"
#import "EMMessage.h"
#import "LLUtils.h"
#import "NSDate+LLExt.h"
#import "EMMessage.h"
#import "EMTextMessageBody.h"
#import "LLChatManager.h"
#import "LLConversationModelManager.h"

@interface LLConversationModel ()
{
    NSString *_draft;
}


@end


@implementation LLConversationModel

@synthesize draft = _draft;

- (instancetype)initWithConversation:(EMConversation *)conversation {
    self = [super init];
    if (self) {
        _sdk_conversation = conversation;
        _conversationType = (LLConversationType)conversation.type;
    
        _unreadMessageNumber = -1;
        _allMessageModels = [[NSMutableArray alloc] init];
    }

    return self;
}

+ (LLConversationModel *)conversationModelFromPool:(EMConversation *)conversation {
    LLConversationModel *conversationModel = [[LLConversationModelManager sharedManager] conversationModelForConversationId:conversation.conversationId];
    if (!conversationModel) {
        conversationModel = [[LLConversationModel alloc] initWithConversation:conversation];
        [[LLConversationModelManager sharedManager] addConversationModel:conversationModel];
    }else if (conversationModel.sdk_conversation != conversation) {
        [conversationModel updateConversationModel:conversation];
    }

    return conversationModel;
}

- (void)updateConversationModel:(EMConversation *)conversation {
    NSAssert([_sdk_conversation.conversationId isEqualToString:conversation.conversationId], @"更新会话数据时，conversationId发生改变");
    
    _sdk_conversation = conversation;
    
}

- (NSTimeInterval)latestMessageTimestamp {
    long long timestamp = self.sdk_conversation.latestMessage.timestamp;
    return [LLUtils adjustTimestampFromServer:timestamp];
}

- (NSString *)latestMessageTimeString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self latestMessageTimestamp]];
    
    return [date timeIntervalBeforeNowShortDescription];
}

- (NSString *)conversationId {
    return self.sdk_conversation.conversationId;
}

- (NSString *)nickName {
    return self.conversationId;
}

- (NSInteger)unreadMessageNumber {
    return self.sdk_conversation.unreadMessagesCount;
}

- (NSString *)latestMessage {
    EMMessage *latestMessage = self.sdk_conversation.latestMessage;
    return [LLMessageModel messageTypeTitle:latestMessage];
}

- (LLMessageStatus)latestMessageStatus {
    EMMessage *latestMessage = self.sdk_conversation.latestMessage;
    return (LLMessageStatus)latestMessage.status;
}

- (NSString *)draft {
    if (_draft == nil) {
        NSDictionary *ext = _sdk_conversation.ext;
        _draft = ext[CONVERSATION_DRAFT_KEY];
        if (_draft == nil)
            _draft = @"";
    }
    
    return _draft;
}

- (void)setDraft:(NSString *)draft {
    if (![_draft isEqualToString:draft]) {
        _draft = [draft copy];
    }
}

- (void)saveDraftToDB {
    NSDictionary *ext = _sdk_conversation.ext;
    NSString *oldDraft = ext[CONVERSATION_DRAFT_KEY];
    
    if (![_draft isEqualToString:oldDraft]) {
        NSMutableDictionary *mExt = ext ? [ext mutableCopy] : [NSMutableDictionary dictionary];
        mExt[CONVERSATION_DRAFT_KEY] = _draft;
        [_sdk_conversation setExt:mExt];
    }
}

@end
