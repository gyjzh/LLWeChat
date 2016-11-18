//
//  LLMessageCacheManager.h
//  LLWeChat
//
//  Created by GYJZH on 23/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LLMessageModel;
@class LLConversationModel;

@interface LLMessageCacheManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 会话 -

- (void)deleteConversation:(NSString *)conversationId;

- (void)prepareCacheWhenConversationBegin:(LLConversationModel *)conversationModel;

- (void)cleanCacheWhenConversationExit:(LLConversationModel *)conversationModel;

#pragma mark - 删除消息 - 

- (void)deleteMessageModel:(LLMessageModel *)messageModel;

- (void)deleteMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels;

@end
