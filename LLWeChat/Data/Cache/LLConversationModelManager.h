//
//  LLConversationModelManager.h
//  LLWeChat
//
//  Created by GYJZH on 30/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLConversationModel.h"

@interface LLConversationModelManager : NSObject

+ (instancetype)sharedManager;

//当前处于活动状态的会话Model
@property (nonatomic) LLConversationModel *currentActiveConversationModel;

- (void)addConversationModel:(LLConversationModel *)conversationModel;

- (void)removeConversationModel:(LLConversationModel *)conversationModel;

- (LLConversationModel *)conversationModelForConversationId:(NSString *)conversationId;

- (NSArray<LLConversationModel *> *)updateConversationListAfterReceiveNewMessages:(NSArray *)aMessages;

- (NSArray<LLConversationModel *> *)updateConversationListAfterLoad:(NSArray<EMConversation *> *)aConversations;

- (void)reloadConversationModelToTop:(LLConversationModel *)conversationModel;

@end
