//
// Created by GYJZH on 7/19/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMConversation.h"
#import "EMMessage.h"
#import "LLMessageModel.h"

@import UIKit;

typedef NS_ENUM(NSInteger, LLMessageListUpdateType) {
    kLLMessageListUpdateTypeLoadMore = 0,
    kLLMessageListUpdateTypeLoadMoreComplete,
    kLLMessageListUpdateTypeNewMessage
};


@interface LLConversationModel : NSObject

//以下三个属性SDK不存储,需要由服务器提供,此处采用假数据
@property (nonatomic) NSString *avatarImageURL;
@property (nonatomic) UIImage *avatarImage;
@property (nonatomic) NSString *nickName;

@property (nonatomic) NSString *latestMessageTimeString;;

@property (nonatomic) NSTimeInterval latestMessageTimestamp;

@property (nonatomic) NSInteger unreadMessageNumber;
@property (nonatomic, copy, readonly) NSString *conversationId;

@property (nonatomic, readonly) LLConversationType conversationType;

@property (nonatomic) NSString *draft;

#pragma mark - 消息列表 -
@property (nonatomic) LLMessageModel *referenceMessageModel;
@property (nonatomic) LLMessageListUpdateType updateType;

//该Conversation已经获取到的消息数组，按照时间从过去到现在排序，最近的消息在数组最后面
@property (atomic) NSMutableArray<LLMessageModel *> *allMessageModels;

+ (LLConversationModel *)conversationModelFromPool:(EMConversation *)conversation;

#pragma mark - Server.SDK专用，Client代码不直接访问 -
@property (nonatomic) EMConversation *sdk_conversation;

- (NSString *)latestMessage;

- (LLMessageStatus)latestMessageStatus;

- (void)saveDraftToDB;

@end
