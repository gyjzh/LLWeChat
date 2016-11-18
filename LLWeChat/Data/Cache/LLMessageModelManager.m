//
//  LLMessageModelManager.m
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageModelManager.h"
#import "LLUtils.h"

@interface LL_MessagePool_Data : NSObject

@property (nonatomic, copy) NSString *conversationId;

@property (nonatomic) NSMutableArray<LLMessageModel *> *allMessageModels;

//是否获取了最早的消息记录
@property (nonatomic) BOOL loadedEarliestMessage;

@end

@implementation LL_MessagePool_Data

- (instancetype)init {
    self = [super init];
    if (self) {
        _allMessageModels = [NSMutableArray array];
    }
    
    return self;
}

@end

/////////////////////////////////////////////

@interface LLMessageModelManager ()

@property (nonatomic) NSMutableSet<LL_MessagePool_Data *> *allMessagePoolData;

@end

@implementation LLMessageModelManager

CREATE_SHARED_MANAGER(LLMessageModelManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _allMessagePoolData = [NSMutableSet set];
    }
    
    return self;
}

- (void)deleteAllMessageModels {
    [_allMessagePoolData removeAllObjects];
}

#pragma mark - 批量获取MessageModel -

//返回的数据中不包括referenceModel
- (NSArray<LLMessageModel *> *)loadMoreMessagesForConversationModel:(LLConversationModel *)conversationModel limit:(int)limit isDirectionUp:(BOOL)isDirectionUp hasLoadedEarliestMessage:(BOOL *)hasLoadedEarliestMessage {

    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:conversationModel.conversationId];
    if (data.allMessageModels.count == 0) {
        *hasLoadedEarliestMessage = data.loadedEarliestMessage;
        return nil;
    }
    
    NSInteger startIndex, endIndex;
    if (!conversationModel.referenceMessageModel) {
        endIndex = data.allMessageModels.count;
    }else {
        endIndex = [data.allMessageModels indexOfObject:conversationModel.referenceMessageModel];
        NSAssert(endIndex != NSNotFound, @"从缓存中读取MessageModel出错");
    }

    startIndex = endIndex - limit;
    if (startIndex < 0) {
        startIndex = 0;
    }
    
    if (startIndex == 0) {
        *hasLoadedEarliestMessage = data.loadedEarliestMessage;
    }else {
        *hasLoadedEarliestMessage = NO;
    }
    
    return [data.allMessageModels subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];

}

- (void)markEarliestMessageLoadedForConversation:(NSString *)conversationId {
    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:conversationId];
    data.loadedEarliestMessage = YES;
}


- (void)addMessageList:(NSArray<LLMessageModel *> *)newMessageModels toConversation:(NSString *)conversationId isAppend:(BOOL)isAppend {
    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:conversationId];
    
    if (isAppend) {
        [data.allMessageModels addObjectsFromArray:newMessageModels];
    }else {
        [data.allMessageModels insertObjects:newMessageModels atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newMessageModels.count)]];
    }
    
}


- (void)deleteConversation:(NSString *)conversationId {
   for (LL_MessagePool_Data *data in self.allMessagePoolData) {
        if ([data.conversationId isEqualToString:conversationId]) {
            [self.allMessagePoolData removeObject:data];
            break;
        }
    }
}

#pragma mark - 单个MessageModel -

- (void)addMessageModelToConversaion:(LLMessageModel *)messageModel {
    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:messageModel.conversationId];
    [data.allMessageModels addObject:messageModel];
}

- (void)deleteMessageModel:(LLMessageModel *)messageModel {
    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:messageModel.conversationId];
    [data.allMessageModels removeObject:messageModel];
}

- (void)deleteMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels {
    if (messageModels.count > 0) {
        LL_MessagePool_Data *data = [self messagePoolDataForConversationId:messageModels[0].conversationId];
        [data.allMessageModels removeObjectsInArray:messageModels];
    }
}


- (LLMessageModel *)messageModelForEMMessage:(EMMessage *)message {
    LL_MessagePool_Data *data = [self messagePoolDataForConversationId:message.conversationId];
    for (LLMessageModel *model in data.allMessageModels) {
        if ([model.messageId isEqualToString:message.messageId]) {
            return model;
        }
    }
    
    return nil;
}

#pragma mark - 内部方法 -

- (LL_MessagePool_Data *)messagePoolDataForConversationId:(NSString *)conversationId {
    for (LL_MessagePool_Data *data in self.allMessagePoolData) {
        if ([data.conversationId isEqualToString:conversationId]) {
            return data;
        }
    }
    
    LL_MessagePool_Data *data = [[LL_MessagePool_Data alloc] init];
    data.conversationId = conversationId;
    [self.allMessagePoolData addObject:data];
    
    return data;
}


@end
