//
//  LLUtils+Text.m
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils+Text.h"

@implementation LLUtils (Text)

+ (NSString *)sizeStringWithStyle:(id)style size:(long long)size {
    if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%ldK", (long)size/1024];
    }else {
        return [NSString stringWithFormat:@"%.1fM", size/(1024 * 1024.0)];
    }
}

+ (NSDictionary *)textMessageExtForEmotionModel:(LLEmotionModel *)emotionModel {
    return @{@"groupName":emotionModel.group.groupName,
             @"codeId": emotionModel.codeId};
}

+ (CGSize)boundingSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    CGSize calSize = CGSizeMake(maxWidth, MAXFLOAT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    
    
    CGRect rect = [text boundingRectWithSize:calSize
                                     options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect.size;
}

+ (CGFloat)widthForSingleLineString:(NSString *)text font:(UIFont *)font {
    //    stringWidth =[text
    //            boundingRectWithSize:size
    //                         options:NSStringDrawingUsesLineFragmentOrigin
    //                      attributes:@{NSFontAttributeName:self.font}
    //                         context:nil].size.width;
    
    CGRect rect = [text
                   boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                   options:0
                   attributes:@{NSFontAttributeName:font}
                   context:nil];
    return rect.size.width;
    
}


//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinLetterOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //首字符就是字母
    unichar C = [aString characterAtIndex:0];
    if((C<= 'Z' && C>='A') || (C <= 'z' && C >= 'a')) {
        //转化为大写拼音
        NSString *pinYin = [[aString substringToIndex:1] capitalizedString];
        //获取并返回首字母
        return pinYin;
    }
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:[aString substringToIndex:1]];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinCharactorOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:[aString substringToIndex:1]];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return pinYin;
}


//获取拼音
+ (NSString *)pinyinOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return pinYin;
}


+ (NSMutableAttributedString *)highlightDefaultDataTypes:(NSMutableAttributedString *)attributedString {    
    
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink
                                error:&error];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:kNilOptions
                                           range:NSMakeRange(0, [attributedString length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        BOOL shouldHighlight = NO;
            
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString:URL_MAIL_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTP_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTPS_SCHEME]) {
                shouldHighlight = YES;
            }
        }else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            shouldHighlight = YES;
        }
        
        if (shouldHighlight) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:kLLTextLinkColor range:matchRange];
        }
        
    }
    
    return attributedString;
}


@end
