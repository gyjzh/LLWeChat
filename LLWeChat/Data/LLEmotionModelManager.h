//
//  LLEmotionModel.h
//  LLWeChat
//
//  Created by GYJZH on 7/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLEmotionModel.h"


@interface LLEmotionModelManager : NSObject

@property (nonatomic) NSMutableArray<LLEmotionGroupModel *> *allEmotionGroups;

+ (instancetype)sharedManager;

- (void)prepareEmotionModel;

- (UIImage *)imageForEmotionModel:(LLEmotionModel *)model;

- (NSData *)gifDataForEmotionModel:(LLEmotionModel *)model;

- (NSData *)gifDataForEmotionGroup:(NSString *)groupName codeId:(NSString *)codeId;

- (NSRange)rangeOfEmojiAtEndOfString:(NSString *)string;

- (NSRange)rangeOfEmojiAtIndexOfString:(NSString *)string index:(NSInteger)index;

- (NSMutableAttributedString *)convertTextEmotionToAttachment:(NSString *)text font:(UIFont *)font;

@end

