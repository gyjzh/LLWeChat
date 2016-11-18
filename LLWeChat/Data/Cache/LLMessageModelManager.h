//
//  LLMessageModelManager.h
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessageModel.h"
#import "LLConversationModel.h"
#import "EMSDK.h"

@interface LLMessageModelManager : NSObject

+ (instancetype)sharedManager;

- (void)deleteAllMessageModels;

//TODO：返回的数据中不包括referenceModel，暂时只支持DirectionUp，
//就是只支持下拉刷新，不支持上拉刷新
- (NSArray<LLMessageModel *> *)loadMoreMessagesForConversationModel:(LLConversationModel *)conversationModel limit:(int)limit isDirectionUp:(BOOL)isDirectionUp hasLoadedEarliestMessage:(BOOL *)hasLoadedEarliestMessage;

- (void)markEarliestMessageLoadedForConversation:(NSString *)conversationId;

- (void)addMessageList:(NSArray<LLMessageModel *> *)newMessageModels toConversation:(NSString *)conversationId isAppend:(BOOL)isAppend;

- (void)addMessageModelToConversaion:(LLMessageModel *)messageModel;

- (void)deleteMessageModel:(LLMessageModel *)messageModel;

- (void)deleteMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels;

- (LLMessageModel *)messageModelForEMMessage:(EMMessage *)message;

- (void)deleteConversation:(NSString *)conversationId;

@end
