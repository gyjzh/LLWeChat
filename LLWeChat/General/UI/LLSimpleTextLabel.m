//
//  LLSimpleTextLabel.m
//  LLWeChat
//
//  Created by GYJZH on 8/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSimpleTextLabel.h"
#import "LLColors.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "LLEmotionModelManager.h"

#define TOUCH_DELAYED_TIME 0.2

@interface LLLabelGestureRecognizer : UIGestureRecognizer

- (void)swallowTouch;

@end

@interface LLLabelRichTextData ()

@property (nonatomic) NSMutableArray<NSValue *> *rects;

@end

@implementation LLLabelRichTextData

- (instancetype)initWithType:(LLLabelRichTextType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    
    return self;
}

@end


@interface LLSimpleTextLabel ()  <UIGestureRecognizerDelegate>
@property (nonatomic) UIColor *selectedBackgroundColor; //用户选中时的背景颜色
@property (nonatomic) LLLabelRichTextData *data;

@property (nonatomic) NSMutableArray<LLLabelRichTextData *> *richTextDatas;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic) LLLabelGestureRecognizer *labelGestureRecognizer;

@property (nonatomic) NSTimer *timer;

@end

@implementation LLSimpleTextLabel {
    UIGestureRecognizerState longPressGestureRecognizerState;
    BOOL hasParsedRects;
    UIEdgeInsets userDefinedEdgeInset;
    NSMutableDictionary<NSNumber *, LLLabelRichTextData *> *cache;
    dispatch_block_t delayBlock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = nil;
        cache = [NSMutableDictionary dictionary];
        _richTextDatas = [NSMutableArray array];
        _selectedBackgroundColor = [UIColor colorWithWhite:0.4 alpha:0.3];
        
        _longPressDuration = 0.8;
        _tapGestureRecognizer = [self addTapGestureRecognizer:@selector(tapHandler:)];
        _tapGestureRecognizer.delaysTouchesBegan = NO;
        _tapGestureRecognizer.delaysTouchesEnded = NO;
        _tapGestureRecognizer.cancelsTouchesInView = YES;
        _tapGestureRecognizer.delegate = self;
        
        _labelGestureRecognizer = [[LLLabelGestureRecognizer alloc] initWithTarget:self action:@selector(labelGestureHandler:)];
        _labelGestureRecognizer.delaysTouchesBegan = NO;
        _labelGestureRecognizer.delaysTouchesEnded = NO;
        _labelGestureRecognizer.cancelsTouchesInView = YES;
        _labelGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_labelGestureRecognizer];
        
        longPressGestureRecognizerState = UIGestureRecognizerStatePossible;
        [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];

    }
    
    return self;
}

- (void)dealloc {
    [self.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
}

//FIXME:SDK自带的DataDetector对URL识别并不是太精确
//本来想自己提供正则式，由于精力有限，最终还是采用SDK现成的
- (void)parseText:(NSAttributedString *)attributedString {
    [self.richTextDatas removeAllObjects];
    
    //    NSError *error = nil;
    //    static NSRegularExpression *mailRegular;
    //    static NSRegularExpression *webURLRegular;
    //
    //    //匹配邮箱
    //    if (!mailRegular) {
    //        /**
    //         *  邮箱正则表达式，官方正式版最精确但也太过复杂，不适合这里用，
    //         *  参考网址：http://www.regular-expressions.info/email.html
    //         *  下面的正则保证如下几点：
    //         *  1、用户名部分以字母数字开头，总长不超过64字符
    //         *  2、网址子域名不超过5个，5个可以满足绝大多数情况。注：合法的邮箱子域名没有这个限制
    //         *  3、子域名以字母数字开头，以字母数字结尾，中间可以包括“-”，总长不超过64字符。
    //         *
    //         *  以下规则没有保证：
    //         *  1、邮箱合法长度不超过254个字符，这个表达式最多匹配447个字符
    //         *  2、子域名不能有连续的“-”，这个没有保证
    //         *  3、字符国际化等没有保证
    //         *
    //         *  对于长文本应该先用一个粗略的正则式尽快找出所有可能的邮箱地址，
    //         *  然后对找到的结果应用精确的正则式，但是IM文本消息长度一般都不超过几百字
    //         *  所有这里直接用下面的正则式查找
    //         */
    //
    //        NSString *emailRegex = @"[A-Z0-9][A-Z0-9._%+-]{0,63}@(?:[A-Z0-9](?:[A-Z0-9-]{0,62}[A-Z0-9])?\\.){1,5}[A-Z]{2,63}";
    //        mailRegular = [NSRegularExpression regularExpressionWithPattern:emailRegex options:NSRegularExpressionCaseInsensitive error:&error];
    //    }
    //    NSArray *resultArray = [mailRegular matchesInString:attributedString.string options:0 range:NSMakeRange(0, attributedString.string.length)];
    //    for(NSTextCheckingResult *match in resultArray) {
    //        NSRange range = [match range];
    //        [attributedString addAttribute:NSForegroundColorAttributeName value:kLLTextLinkColor range:range];
    //    }
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:kNilOptions
                                           range:NSMakeRange(0, attributedString.string.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
    
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString:URL_MAIL_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTP_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTPS_SCHEME]) {
                LLLabelRichTextData *data = [[LLLabelRichTextData alloc] initWithType:kLLLabelRichTextTypeURL];
                data.range = matchRange;
                data.url = url;
                data.rects = [self calculateRectsForCharacterRange:matchRange];
                [self.richTextDatas addObject:data];
            }else {
                continue;
            }
        
        }else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            
            LLLabelRichTextData *data = [[LLLabelRichTextData alloc] initWithType:kLLLabelRichTextTypePhoneNumber];
            data.range = matchRange;
            data.phoneNumber = phoneNumber;
            data.rects = [self calculateRectsForCharacterRange:matchRange];
            
            [self.richTextDatas addObject:data];
            
        }
        
    }
    
}


- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [cache removeAllObjects];
    hasParsedRects = NO;
    
    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
}


- (void)layoutSubviews  {
    [super layoutSubviews];
   
    if (!hasParsedRects) {
        hasParsedRects = YES;
        
        [self parseText:self.attributedText];
    }

}

- (NSMutableArray<NSValue *> *)calculateRectsForCharacterRange:(NSRange)range {
    NSMutableArray<NSValue *> *rects = [NSMutableArray array];
    NSParagraphStyle *paragraphStyle = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    NSInteger lineSpace = paragraphStyle ? paragraphStyle.lineSpacing : 0;
    NSInteger lineSpaceOffset = lineSpace > 2 ? 1 - lineSpace : 0;

    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    
    CGRect startRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location, 1) inTextContainer:self.textContainer];
    
    CGRect endRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location + glyphRange.length - 1, 1) inTextContainer:self.textContainer];
    
    CGFloat lineHeight = self.font.lineHeight + lineSpace;
    NSInteger lineNumber = round((CGRectGetMaxY(endRect) - CGRectGetMinY(startRect)) / lineHeight);
    
    CGRect lineRect;
    CGRect drawRect;
    BOOL needAdjustInset = self.textContainerInset.top > 0 || self.textContainerInset.left > 0;
    
    //计算第一行
    if (lineNumber == 1) {
        drawRect = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), CGRectGetMaxX(endRect) - CGRectGetMinX(startRect), CGRectGetHeight(startRect) + lineSpaceOffset );
    }else {
        lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
        drawRect = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), CGRectGetWidth(lineRect) - CGRectGetMinX(startRect), CGRectGetHeight(startRect) + lineSpaceOffset );
    }
    
    if (needAdjustInset) {
        CGRect rect = CGRectOffset(drawRect, self.textContainerInset.left, self.textContainerInset.top);
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }else {
        [rects addObject:[NSValue valueWithCGRect:drawRect]];
    }
    

    //计算最后一行
    if (lineNumber >= 2) {
        drawRect = CGRectMake(self.textContainerInset.left, CGRectGetMinY(endRect) + self.textContainerInset.top, CGRectGetMaxX(endRect), CGRectGetHeight(endRect) + lineSpaceOffset);

        [rects addObject:[NSValue valueWithCGRect:drawRect]];
    }
    
    //计算中间行
    for (NSInteger i = 1; i < lineNumber - 1; i++) {
        NSInteger glyphIndex = [self.layoutManager glyphIndexForPoint:CGPointMake(0 , CGRectGetMinY(startRect) + lineHeight * i) inTextContainer:self.textContainer];
        lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:nil];
        lineRect.size.height += lineSpaceOffset;
        
        if (needAdjustInset) {
            CGRect rect = CGRectOffset(lineRect, self.textContainerInset.left, self.textContainerInset.top);
            [rects addObject:[NSValue valueWithCGRect:rect]];
        }else {
            [rects addObject:[NSValue valueWithCGRect:lineRect]];
        }
    }
    
    return rects;
}


- (void)drawRect:(CGRect)rect {
    if (!self.data)
        return;
    
    NSArray<NSValue *> *rects = self.data.rects;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.selectedBackgroundColor.CGColor);
    for (NSValue *value in rects) {
        CGContextFillRect(context, value.CGRectValue);
    }
    
}

- (LLLabelRichTextData *)richTextDataAtPoint:(CGPoint)point {
    CGFloat fraction;
    NSInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceThroughGlyph:&fraction];
    LLLabelRichTextData *data = cache[@(glyphIndex)];
    if (data) {
        return data;
    }
    
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:self.textContainer];
    
    if (!CGRectContainsPoint(rect, point)) {
        return nil;
    }
    
    NSInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    for (LLLabelRichTextData *data in self.richTextDatas) {
        if (characterIndex >= data.range.location && characterIndex < data.range.location + data.range.length) {
            cache[@(glyphIndex)] = data;
            return data;
        }
    }
    
    return nil;
}


- (void)_setNeedsDisplay:(LLLabelRichTextData *)data {
    self.data = data;
    [self setNeedsDisplay];
}


#pragma mark - AttributedString -

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing {
    //解析Emotion字符串为NSTextAttachment
    NSMutableAttributedString *attributedString =
        [[LLEmotionModelManager sharedManager]
            convertTextEmotionToAttachment:emotionString
                                      font:font];
    
    //段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    //高亮链接
    attributedString = [LLUtils highlightDefaultDataTypes:attributedString];
    
    return attributedString;
}

#pragma mark - 手势 -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.panGestureRecognizer && [keyPath isEqualToString:@"state"]) {
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        if (state == UIGestureRecognizerStateBegan) {
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            
            if (self.timer) {
                [self invalidateTimer];
            }
        }
        
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_labelGestureRecognizer == gestureRecognizer) {
        return YES;
    }
    
    CGPoint point = [touch locationInView:self];
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    if (gestureRecognizer == _tapGestureRecognizer) {
        LLLabelRichTextData *data = [self richTextDataAtPoint:point];
        if (data) {
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            self.data = data;
            
            WEAK_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOUCH_DELAYED_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf delayedCallback:touch];
            });
            
            return YES;
        }else {
            return NO;
        }
    }

    return YES;
}

- (void)delayedCallback:(UITouch *)touch {
    if (!self.data || !touch || touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled || ![touch.gestureRecognizers containsObject:_tapGestureRecognizer])
        return;
    
    [self invalidateTimer];
    self.timer = [NSTimer timerWithTimeInterval:self.longPressDuration - TOUCH_DELAYED_TIME target:self selector:@selector(longPressRecognized:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self _setNeedsDisplay:self.data];
}

- (void)longPressRecognized:(NSTimer *)timer {
    if (self.longPressAction && self.data) {
        longPressGestureRecognizerState = UIGestureRecognizerStateBegan;
        self.longPressAction(self.data, UIGestureRecognizerStateBegan);
        
        self.tapGestureRecognizer.enabled = NO;
    }
}

- (void)labelGestureHandler:(LLLabelGestureRecognizer *)labelGesture {
    switch (labelGesture.state) {
        case UIGestureRecognizerStateBegan:
//            if (self.longPressAction && self.data) {
//                self.longPressAction(self.data, labelGesture.state);
//            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            break;
        case UIGestureRecognizerStateEnded:
//            if (self.longPressAction && self.data) {
//                self.longPressAction(self.data, labelGesture.state);
//            }
            
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            
            
        default:
            break;
    }

}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.timer) {
            [self invalidateTimer];
        }
        
        if (self.data && self.tapAction) {
            self.tapAction(self.data);
            
            [self _setNeedsDisplay:self.data];
            WEAK_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOUCH_DELAYED_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf clearLinkBackground];
            });
        }
    }
}


- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    self.tapGestureRecognizer.enabled = YES;
    longPressGestureRecognizerState = UIGestureRecognizerStatePossible;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer.delaysTouchesBegan = NO;
    gestureRecognizer.delaysTouchesEnded = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.data && (_labelGestureRecognizer.state != UIGestureRecognizerStateBegan && _labelGestureRecognizer.state != UIGestureRecognizerStateChanged && _labelGestureRecognizer.state != UIGestureRecognizerStateEnded)) {
        [self _setNeedsDisplay:nil];
    }
    
    if (self.timer) {
        [self invalidateTimer];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (longPressGestureRecognizerState == UIGestureRecognizerStateBegan) {
        if (self.longPressAction && self.data) {
            longPressGestureRecognizerState = UIGestureRecognizerStateEnded;
            self.longPressAction(self.data, UIGestureRecognizerStateEnded);
        }
    }
    
    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
    
    if (self.timer) {
        [self invalidateTimer];
    }
}


- (BOOL)shouldReceiveTouchAtPoint:(CGPoint)point {
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    LLLabelRichTextData *data = [self richTextDataAtPoint:point];
    
    if (!data)return NO;
    return YES;

}

- (void)swallowTouch {
    [_labelGestureRecognizer swallowTouch];
}


- (void)clearLinkBackground {
    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
}

#pragma mark - 布局Delegate -



@end

////////////////////////////////////////////////////


@interface LLLabelGestureRecognizer ()

@property (nonatomic) UITouch *touch;

@end

@implementation LLLabelGestureRecognizer

- (void)reset {
    [super reset];
    
    self.touch = nil;
}

- (void)swallowTouch {
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.touch = [touches anyObject];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateCancelled;
}

@end
