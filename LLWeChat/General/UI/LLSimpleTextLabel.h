//
//  LLSimpleTextLabel.h
//  LLWeChat
//
//  Created by GYJZH on 8/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLLabelRichTextData;

typedef void (^LLLabelTapAction)(LLLabelRichTextData *data);

typedef void (^LLLabelLongPressAction)(LLLabelRichTextData *data, UIGestureRecognizerState state);


typedef NS_ENUM(NSInteger, LLLabelRichTextType) {
    kLLLabelRichTextTypeURL = 0,
    kLLLabelRichTextTypePhoneNumber
};

@class LLSimpleTextLabel;

@interface LLLabelRichTextData : NSObject

@property (nonatomic) NSRange range;

@property (nonatomic) LLLabelRichTextType type;

@property (nonatomic) NSURL *url;

@property (nonatomic, copy) NSString *phoneNumber;

- (instancetype)initWithType:(LLLabelRichTextType)type;

@end


/**
 *  实现的功能：
 *  1、可以识别电话号码、WebURL、邮件
 *  2、以上链接支持点击、长按两种操作
 *  3、可以显示Emotion，可以设置字体、行间距
 *
 *  既然取名Simple就标明这个类功能很有限
 *  1、目前只支持整个文本一种字体、一个行间距
 *  2、没有提供其他属性接口
 *  3、通用性不好，应该使用createAttributedStringWithEmotionString:font:lineSpacing
 *  来构造赋值的属性字符串
 *
 *
 */
@interface LLSimpleTextLabel : UITextView

//派发longPress事件需要的最短事件，默认为0.8秒
@property (nonatomic) CGFloat longPressDuration;

@property (nonatomic, copy) LLLabelTapAction tapAction;

@property (nonatomic, copy) LLLabelLongPressAction longPressAction;

- (BOOL)shouldReceiveTouchAtPoint:(CGPoint)point;

- (void)swallowTouch;

- (void)clearLinkBackground;

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing;

@end
