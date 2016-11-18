//
//  LLMessageCacheManager.m
//  LLWeChat
//
//  Created by GYJZH on 23/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageCacheManager.h"
#import "LLUtils.h"

#import "LLMessageThumbnailManager.h"
#import "LLMessageCellManager.h"
#import "LLMessageModelManager.h"
#import "LLConversationModelManager.h"

@interface LLMessageCacheManager ()

@end


@implementation LLMessageCacheManager

CREATE_SHARED_MANAGER(LLMessageCacheManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                 selector:@selector(didReceiveEnterBackgroundNotification:)
                     name:UIApplicationDidEnterBackgroundNotification
                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                 selector:@selector(didReceiveMemoryWarningNotification:)
                     name:UIApplicationDidReceiveMemoryWarningNotification
                   object:nil];

    }
    
    return self;
}

#pragma mark - 会话缓存管理 -

- (void)deleteConversation:(NSString *)conversationId {
    [[LLMessageModelManager sharedManager] deleteConversation:conversationId];
    [[LLMessageCellManager sharedManager] deleteConversation:conversationId];
    [[LLMessageThumbnailManager sharedManager] deleteConversation:conversationId];
}

- (void)prepareCacheWhenConversationBegin:(LLConversationModel *)conversationModel {
    [[LLMessageThumbnailManager sharedManager] prepareCacheWhenConversationBegin:conversationModel.conversationId];
    [[LLMessageCellManager sharedManager] prepareCacheWhenConversationBegin:conversationModel.conversationId];
    
    [LLConversationModelManager sharedManager].currentActiveConversationModel = conversationModel;
}

- (void)cleanCacheWhenConversationExit:(LLConversationModel *)conversationModel {
    [[LLMessageCellManager sharedManager] cleanCacheWhenConversationExit:conversationModel.conversationId];
    [[LLMessageThumbnailManager sharedManager] cleanCacheWhenConversationExit:conversationModel.conversationId];
    
    [LLConversationModelManager sharedManager].currentActiveConversationModel = nil;
}

#pragma mark - 删除消息 -

- (void)deleteMessageModel:(LLMessageModel *)messageModel {
    [[LLMessageModelManager sharedManager] deleteMessageModel:messageModel];
    [[LLMessageCellManager sharedManager] removeCellForMessageModel:messageModel];
    [[LLMessageThumbnailManager sharedManager] removeThumbnailForMessageModel:messageModel removeFromDisk:YES];
}

- (void)deleteMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels {
    [[LLMessageModelManager sharedManager] deleteMessageModelsInArray:messageModels];
    [[LLMessageCellManager sharedManager] removeCellsForMessageModelsInArray:messageModels];
    [[LLMessageThumbnailManager sharedManager] removeThumbnailForMessageModelsInArray:messageModels removeFromDisk:YES];
}

#pragma mark - 系统消息 -

- (void)didReceiveEnterBackgroundNotification:(NSNotification *)notification {
    [[LLMessageThumbnailManager sharedManager] clearAllMemCache];
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    [[LLMessageCellManager sharedManager] deleteAllCells];
    [[LLMessageThumbnailManager sharedManager] clearAllMemCache];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
