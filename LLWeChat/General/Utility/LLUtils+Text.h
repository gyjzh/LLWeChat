//
//  LLUtils+Text.h
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLUtils (Text)

+ (CGFloat)widthForSingleLineString:(NSString *)text font:(UIFont *)font;

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinLetterOfString:(NSString *)aString;
//获取拼音
+ (NSString *)pinyinOfString:(NSString *)aString;

+ (NSString *)sizeStringWithStyle:(nullable id)style size:(long long)size;

+ (NSDictionary *)textMessageExtForEmotionModel:(LLEmotionModel *)model;

+ (CGSize)boundingSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;

+ (NSMutableAttributedString *)highlightDefaultDataTypes:(NSMutableAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
