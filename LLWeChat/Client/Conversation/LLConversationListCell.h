//
//  LLConversationListCell.h
//  LLWeChat
//
//  Created by GYJZH on 7/20/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLConversationModel.h"

@interface LLConversationListCell : UITableViewCell

@property (nonatomic) LLConversationModel *conversationModel;

- (void)markAllMessageAsRead;

/*
 * SDK不支持该功能
 * */
- (void)markMessageAsNotRead;


@end
