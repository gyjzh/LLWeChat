//
//  LLConversationModelManager.m
//  LLWeChat
//
//  Created by GYJZH on 30/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLConversationModelManager.h"
#import "LLChatManager.h"
#import "LLUtils.h"

@interface LLConversationModelManager ()

@property (nonatomic) NSMutableDictionary<NSString *, LLConversationModel *> *allConversationModels;

@end

@implementation LLConversationModelManager {
    NSSortDescriptor *conversationListSortDescriptor;
}

CREATE_SHARED_MANAGER(LLConversationModelManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _allConversationModels = [NSMutableDictionary dictionary];
        conversationListSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sdk_conversation.latestMessage.timestamp" ascending:NO];
    }
    
    return self;
}

- (void)addConversationModel:(LLConversationModel *)conversationModel {
    _allConversationModels[conversationModel.conversationId] = conversationModel;
}

- (void)removeConversationModel:(LLConversationModel *)conversationModel {
    [_allConversationModels removeObjectForKey:conversationModel.conversationId];
}

- (LLConversationModel *)conversationModelForConversationId:(NSString *)conversationId {
    return _allConversationModels[conversationId];
}

- (NSArray<LLConversationModel *> *)updateConversationListAfterReceiveNewMessages:(NSArray *)aMessages {
     NSMutableSet<NSString *> *conversationIdSet = [NSMutableSet set];
    
    [aMessages enumerateObjectsUsingBlock:^(EMMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        //TODO:目前只支持单聊
        if (message.chatType != EMChatTypeChat)
            return;
        [conversationIdSet addObject:message.conversationId];
        
    }];
    
    //所有需要更新的会话
    NSMutableArray<LLConversationModel *> *newConversationList = [NSMutableArray array];
    for (NSString *conversationId in conversationIdSet) {
        LLConversationModel *conversationModel = [self conversationModelForConversationId:conversationId];
        if (!conversationModel) {
            conversationModel = [[LLChatManager sharedManager] getConversationWithConversationChatter:conversationId conversationType:kLLConversationTypeChat];
        }
        [newConversationList addObject:conversationModel];
    }
    if (newConversationList.count > 1)
        [newConversationList sortUsingDescriptors:@[conversationListSortDescriptor]];
    
    //更新会话列表
    NSMutableArray<LLConversationModel *> *conversationList = [[LLChatManager sharedManager].conversationListDelegate currentConversationList];
    [conversationList removeObjectsInArray:newConversationList];
    [conversationList insertObjects:newConversationList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newConversationList.count)]];
    
    return conversationList;
}

- (NSArray<LLConversationModel *> *)updateConversationListAfterLoad:(NSArray<EMConversation *> *)aConversations {
    NSMutableArray<LLConversationModel *> *conversationListModels = [NSMutableArray arrayWithCapacity:aConversations.count];
    
    [aConversations enumerateObjectsUsingBlock:^(EMConversation * _Nonnull conversation, NSUInteger idx, BOOL * _Nonnull stop) {
        //FIXME: 会话的最新消息为空，这种情况会出现吗？
        if(conversation.latestMessage == nil){
            [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:YES];
        }else {
            LLConversationModel *conversationModel = [LLConversationModel conversationModelFromPool:conversation];
            [conversationListModels addObject:conversationModel];
        }
        
    }];
    
    return conversationListModels;
}

- (void)reloadConversationModelToTop:(LLConversationModel *)conversationModel {
    NSMutableArray<LLConversationModel *> *conversationListModels = [[LLChatManager sharedManager].conversationListDelegate currentConversationList];
    
    if (conversationListModels.firstObject == conversationModel)
        return;
    
    if (conversationModel) {
        [conversationListModels removeObject:conversationModel];
        [conversationListModels insertObject:conversationModel atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LLChatManager sharedManager].conversationListDelegate conversationListDidChanged:conversationListModels];
    });
}

@end
