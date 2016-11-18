//
//  LLEmotionModel.m
//  LLWeChat
//
//  Created by GYJZH on 7/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLEmotionModelManager.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"

@interface LLEmotionModelManager ()

@property (nonatomic) NSMutableString *regExpression_chs; //简体中文
@property (nonatomic) NSString *regEndExpression_chs;

@property (nonatomic) NSMutableDictionary *emotionDictionary;

@property (nonatomic) NSBundle *emotionBundle;

@end


@implementation  LLEmotionModelManager

CREATE_SHARED_MANAGER(LLEmotionModelManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allEmotionGroups = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emotion" ofType:@"bundle"];
        self.emotionBundle = [NSBundle bundleWithPath:path];
    }

    return self;
}

/**
 *  处理表情包数据, 此处简单处理
 */
- (void)prepareEmotionModel {
    if ([LLEmotionModelManager sharedManager].allEmotionGroups.count > 0)
        return;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Emotions" ofType:@"plist"];
    NSArray<NSDictionary *> *groups = [NSArray arrayWithContentsOfFile:path];

    for (NSDictionary *group in groups) {
        LLEmotionGroupModel *groupModel = [[LLEmotionGroupModel alloc] init];
        groupModel.groupName = group[@"group"];
        groupModel.groupIconName = group[@"groupicon"];
        groupModel.allEmotionModels = [NSMutableArray array];

        if ([group[@"type"] isEqualToString:@"emoji"]) {
            groupModel.type = kLLEmotionTypeEmoji;
            groupModel.groupName = group[@"group"];

            self.emotionDictionary = [NSMutableDictionary dictionary];
            NSArray<NSDictionary *> *items = group[@"items"];
            for (NSDictionary *item in items) {
                LLEmotionModel *model = [LLEmotionModel modelWithDictionary:item];
                model.group = groupModel;
                [groupModel.allEmotionModels addObject:model];
                
                self.emotionDictionary[model.text] = model.imagePNG;
            }
            
            
            self.regExpression_chs = [NSMutableString string];
            [self.regExpression_chs appendFormat:@"\\[(?:%@",groupModel.allEmotionModels[0].text];
            for (NSInteger i = 1, r = groupModel.allEmotionModels.count; i < r; i++) {
                LLEmotionModel *model = groupModel.allEmotionModels[i];
                [self.regExpression_chs appendFormat:@"|%@", model.text];
            }
            [self.regExpression_chs appendFormat:@")\\]"];
            
            self.regEndExpression_chs = [NSString stringWithFormat:@"%@$", self.regExpression_chs];
           

        }else if ([group[@"type"] isEqualToString:@"gif"]) {
            groupModel.type = kLLEmotionTypeFacialGif;
            groupModel.groupName = group[@"group"];
            
            NSArray<NSDictionary *> *items = group[@"items"];
            for (NSDictionary *item in items) {
                LLEmotionModel *model = [LLEmotionModel modelWithDictionary:item];
                model.group = groupModel;
                [groupModel.allEmotionModels addObject:model];
            }
        }

        [[LLEmotionModelManager sharedManager].allEmotionGroups addObject:groupModel];
    }

}


- (UIImage *)imageForEmotionModel:(LLEmotionModel *)model {
    return [self imageForEmotionPNGName:model.imagePNG];
}

- (UIImage *)imageForEmotionPNGName:(NSString *)pngName {
    return [UIImage imageNamed:pngName inBundle:self.emotionBundle
 compatibleWithTraitCollection:nil];
}

- (NSData *)gifDataForEmotionModel:(LLEmotionModel *)model {
    NSString *path = [self.emotionBundle pathForResource:model.imageGIF ofType:@"gif"];

    return [NSData dataWithContentsOfFile:path];
}

- (NSData *)gifDataForEmotionGroup:(NSString *)groupName codeId:(NSString *)codeId {
    for (LLEmotionGroupModel *groupModel in self.allEmotionGroups) {
        if ([groupModel.groupName isEqualToString:groupName]) {
            for (LLEmotionModel *model in groupModel.allEmotionModels) {
                if ([model.codeId isEqualToString:codeId]) {
                    return [self gifDataForEmotionModel:model];
                }
            }
            
            break;
        }
    }
    
    return nil;
}

- (NSRange)rangeOfEmojiAtEndOfString:(NSString *)string {
    NSRange range = [string rangeOfString:self.regEndExpression_chs options:NSRegularExpressionSearch];
    
    return range;
}

- (NSRange)rangeOfEmojiAtIndexOfString:(NSString *)string index:(NSInteger)index {
    NSRange range = [string rangeOfString:self.regEndExpression_chs options:NSRegularExpressionSearch range:NSMakeRange(0, index)];
    
    return range;
}


- (NSMutableAttributedString *)convertTextEmotionToAttachment:(NSString *)text font:(UIFont *)font {
    NSError *error;
    NSRegularExpression *regularExpression =
    [NSRegularExpression regularExpressionWithPattern:self.regExpression_chs
                                              options:kNilOptions
                                                error:&error];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    while(YES) {
        NSRange range = [regularExpression rangeOfFirstMatchInString:attributeString.string options:kNilOptions range:NSMakeRange(0, attributeString.string.length)];
        if (range.location == NSNotFound)
            break;
        
        NSTextAttachment *attachMent = [[NSTextAttachment alloc] init];
        NSString *imageText = [attributeString.string substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
        NSString *imageName = self.emotionDictionary[imageText];
        UIImage *image = [self imageForEmotionPNGName:imageName];
        
        attachMent.image = image;
        attachMent.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
        
        NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attachMent];
        [attributeString replaceCharactersInRange:range withAttributedString:str];
    
    }

    
    return attributeString;
}


@end
