//
//  LLChatInputView.m
//  LLWeChat
//
//  Created by GYJZH on 7/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatInputView.h"
#import "LLShareInputView.h"
#import "LLEmotionInputView.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLEmotionModel.h"
#import "LLAudioManager.h"

#define SET_KEYBOARD_TYPE(_keyboardType) \
    keyboardShowHideInfo.toKeyboardType = _keyboardType; \
    self.keyboardType = _keyboardType

#define BECOME_FIRST_RESPONDER [self performSelector:@selector(textViewBecomeFirstResponder) withObject:nil afterDelay:0.1]

#define RESIGN_FIRST_RESPONDER [self performSelector:@selector(textViewResignFirstResponder) withObject:nil afterDelay:0.1]

#define TEXT_VIEW_MAX_LINE 5

#define MIN_TEXT_HEIGHT 36

#define Regular_EdgeInset UIEdgeInsetsMake(9, 6, 0, 6)
//暂不支持自由设置，
//#define Compact_EdgeInset UIEdgeInsetsMake(4, 6, 4, 6)

@interface LLChatInputView () <UITextViewDelegate, ILLEmotionInputDelegate, LLChatShareDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *chatVoiceBtn;

@property (weak, nonatomic) IBOutlet UIButton *chatEmotionBtn;

@property (weak, nonatomic) IBOutlet UIButton *chatShareBtn;

@property (weak, nonatomic) IBOutlet UIButton *chatRecordBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;

@property (nonatomic) LLShareInputView *shareInputView;

@property (nonatomic) BOOL recordPermissionGranted;

@end


@implementation LLChatInputView {
    LLKeyboardShowHideInfo keyboardShowHideInfo;
    CGFloat lineHeight;
    UIView *viewview;
    NSDictionary *attributes;
    CGFloat lineSpacing;
    
    CFTimeInterval touchDownTime;
    dispatch_block_t block;
    UIEvent *recordEvent;
    CGFloat textViewHeightConstant;
    
    BOOL textViewAddedObserver;
    BOOL hasRegisterKeyboardNotification;
    BOOL hasActivateKeyboard;
    
    BOOL canBecomeFirstResponder;
    BOOL endScrollingAnimation;
    
    NSString *_textViewText;
    CGFloat maxTextViewHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _keyboardType = kLLKeyboardTypeNone;
    touchDownTime = 0;

    //在上面加一条线
    CALayer *line = [LLUtils lineWithLength:SCREEN_WIDTH atPoint:CGPointZero];
    [self.layer addSublayer:line];
    
    self.chatInputTextView.layer.cornerRadius = 5;
    self.chatInputTextView.layer.borderWidth = 1;
    self.chatInputTextView.layer.borderColor = [UIColor colorWithHexRGB:@"#DADADA"].CGColor;
    self.chatInputTextView.textContainer.lineFragmentPadding = 0;
    self.chatInputTextView.layoutManager.allowsNonContiguousLayout = NO;
    self.chatInputTextView.textContainerInset = Regular_EdgeInset;
    self.chatInputTextView.delegate = self;
    self.chatInputTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.chatInputTextView.allowContentOffsetChange = YES;
    
    lineSpacing = 1;
    lineHeight = self.chatInputTextView.font.lineHeight + lineSpacing;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;

    
    attributes = @{
                   NSFontAttributeName:self.chatInputTextView.font,
                   NSParagraphStyleAttributeName: paragraphStyle
                   };
    self.chatInputTextView.typingAttributes = attributes;
    
    self.shareInputView = [[LLShareInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), SCREEN_WIDTH, CHAT_KEYBOARD_PANEL_HEIGHT)];
    self.shareInputView.delegate = self;
    [self.superview addSubview:self.shareInputView];
    
    [self.superview addSubview:[LLEmotionInputView sharedInstance]];
    [[LLEmotionInputView sharedInstance] setNeedsUpdateConstraints];
    [LLEmotionInputView sharedInstance].delegate = self;
    
    _chatRecordBtn.backgroundColor = [UIColor clearColor];
    [self recordActionEnd];
    _chatRecordBtn.layer.borderColor = UIColorHexRGB(@"#C2C3C7").CGColor;
    _chatRecordBtn.layer.borderWidth = 0.5;
    _chatRecordBtn.layer.cornerRadius = 5.0;
    _chatRecordBtn.layer.masksToBounds = true;

    canBecomeFirstResponder = YES;
    endScrollingAnimation = YES;
    textViewHeightConstant = MIN_TEXT_HEIGHT;
    maxTextViewHeight = TEXT_VIEW_MAX_LINE * lineHeight;
}

- (void)updateConstraints {
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint
                constraintWithItem:[LLEmotionInputView sharedInstance]
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                            toItem:self
                         attribute:NSLayoutAttributeBottom
                        multiplier:1
                          constant:0];
    
    
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint
                constraintWithItem:self.shareInputView
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                            toItem:self
                         attribute:NSLayoutAttributeBottom
                        multiplier:1
                          constant:0];
    
    [NSLayoutConstraint activateConstraints:@[constraint1, constraint2]];
    
    [super updateConstraints];
}

- (void)addObserverForTextView {
    textViewAddedObserver = YES;
    [self.chatInputTextView addObserver:self forKeyPath:@"text" options:kNilOptions context:nil];
}

- (void)removeObserverForTextView {
    textViewAddedObserver = NO;
    [self.chatInputTextView removeObserver:self forKeyPath:@"text"];
}

#pragma mark - 切换键盘

- (IBAction)voiceButtonPressed:(UIButton *)btn {
    switch (self.keyboardType) {
        case kLLKeyboardTypeRecord:
            SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
            self.chatRecordBtn.alpha = 1;
            self.chatInputTextView.alpha = 0;
            BECOME_FIRST_RESPONDER;
            break;
        case kLLKeyboardTypeDefault:
            SET_KEYBOARD_TYPE(kLLKeyboardTypeRecord);
            self.chatRecordBtn.alpha = 0;
            self.chatInputTextView.alpha = 1;
            RESIGN_FIRST_RESPONDER;
            break;
        case kLLKeyboardTypePanel:
        case kLLKeyboardTypeEmotion:
        case kLLKeyboardTypeNone:
        {
            SET_KEYBOARD_TYPE(kLLKeyboardTypeRecord);
            self.chatTextViewHeightConstraint.constant = MIN_TEXT_HEIGHT;
            [self layoutIfNeeded];
            keyboardShowHideInfo.keyboardHeight = 0;
            keyboardShowHideInfo.duration = 0.25;
            [self.delegate updateKeyboard:keyboardShowHideInfo];
        }
            
    }
}


- (IBAction)emotionButtonPressed:(UIButton *)sender {

    switch (self.keyboardType) {
        case kLLKeyboardTypeEmotion:
            SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
            BECOME_FIRST_RESPONDER;
            break;
        case kLLKeyboardTypeDefault:
            SET_KEYBOARD_TYPE(kLLKeyboardTypeEmotion);
            RESIGN_FIRST_RESPONDER;
            [self showEmotionKeyboard:YES];
            break;
        case kLLKeyboardTypePanel:
            self.keyboardType = kLLKeyboardTypeEmotion;
            [self showEmotionKeyboard:YES];
            break;
        case kLLKeyboardTypeNone:
        case kLLKeyboardTypeRecord:
        {
            keyboardShowHideInfo.keyboardHeight = CHAT_KEYBOARD_PANEL_HEIGHT;
            SET_KEYBOARD_TYPE(kLLKeyboardTypeEmotion);
            keyboardShowHideInfo.duration = 0.25;
            self.chatTextViewHeightConstraint.constant = textViewHeightConstant;
            [self layoutIfNeeded];
            [self.delegate updateKeyboard:keyboardShowHideInfo];
            [self showEmotionKeyboard:NO];
        }
            
    }
 
}

- (IBAction)shareButtonPressed:(id)sender {
    switch (self.keyboardType) {
        case kLLKeyboardTypePanel:
            SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
            BECOME_FIRST_RESPONDER;
            break;
        case kLLKeyboardTypeDefault:
            SET_KEYBOARD_TYPE(kLLKeyboardTypePanel);
            RESIGN_FIRST_RESPONDER;
            [self showPanelKeyboard:NO];
            break;
        case kLLKeyboardTypeEmotion:
            self.keyboardType = kLLKeyboardTypePanel;
            [self showPanelKeyboard:YES];
            break;
        case kLLKeyboardTypeNone:
        case kLLKeyboardTypeRecord:
        {
            keyboardShowHideInfo.keyboardHeight = CHAT_KEYBOARD_PANEL_HEIGHT;
            SET_KEYBOARD_TYPE(kLLKeyboardTypePanel);
            keyboardShowHideInfo.duration = 0.25;
            self.chatTextViewHeightConstraint.constant = textViewHeightConstant;
            [self layoutIfNeeded];
            [self.delegate updateKeyboard:keyboardShowHideInfo];
            [self showPanelKeyboard:NO];
        }
            
    }
    
}


- (void)showEmotionKeyboard:(BOOL)animated {
    [LLEmotionInputView sharedInstance].hidden = NO;
    
    if (animated) {
        [LLEmotionInputView sharedInstance].top_LL = CGRectGetMaxY(self.frame) + CHAT_KEYBOARD_PANEL_HEIGHT;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState |
                                    UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [LLEmotionInputView sharedInstance].top_LL = CGRectGetMaxY(self.frame);
                         } completion:nil];
    }else {
        [LLEmotionInputView sharedInstance].top_LL = CGRectGetMaxY(self.frame);
    }
    
}

- (void)showPanelKeyboard:(BOOL)animated {
    [LLEmotionInputView sharedInstance].hidden = YES;
    
    if (animated) {
        self.shareInputView.top_LL = CGRectGetMaxY(self.frame) + CHAT_KEYBOARD_PANEL_HEIGHT;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState |
                                    UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.shareInputView.top_LL = CGRectGetMaxY(self.frame);
                         } completion:nil];
    
    }else {
        self.shareInputView.top_LL = CGRectGetMaxY(self.frame);
    }
}


//只处理本类的UI显示,不负责键盘高度调整
- (void)setKeyboardType:(LLKeyboardType)keyboardType {
    if (_keyboardType == keyboardType)return;
    _keyboardType = keyboardType;
    
    self.chatRecordBtn.alpha = keyboardType != kLLKeyboardTypeRecord ? 0 : 1;
    self.chatInputTextView.alpha = self.chatRecordBtn.alpha == 0 ? 1 : 0;
    
    if (keyboardType == kLLKeyboardTypeEmotion) {
        [self setButton:self.chatEmotionBtn image:@"tool_keyboard_1" highlightedImage:@"tool_keyboard_2"];
    }else {
        [self setButton:self.chatEmotionBtn image:@"tool_emotion_1" highlightedImage:@"tool_emotion_2"];
    }
    
    if (keyboardType == kLLKeyboardTypeRecord) {
        [self setButton:self.chatVoiceBtn image:@"tool_keyboard_1" highlightedImage:@"tool_keyboard_2"];
    }else {
        [self setButton:self.chatVoiceBtn image:@"tool_voice_1" highlightedImage:@"tool_voice_2"];
    }
    
}

- (void)setButton:(UIButton *)button image:(NSString *)image highlightedImage:(NSString *)highlightedImage {
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
}

#pragma mark - 键盘弹出弹入 -

- (void)registerKeyboardNotification {
    if (!hasRegisterKeyboardNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
        
        hasRegisterKeyboardNotification = YES;
    }
    
}

- (void)unregisterKeyboardNotification {
    if (hasRegisterKeyboardNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
        hasRegisterKeyboardNotification = NO;
    }

}

- (void)didReceiveApplicationEnterBackgroundNotification:(NSNotification *)notify {
    if (self.keyboardType == kLLKeyboardTypeDefault) {
        hasActivateKeyboard = NO;
        keyboardShowHideInfo.keyboardHeight = 0;
        self.shareInputView.hidden = YES;
        [LLEmotionInputView sharedInstance].hidden = YES;
    }
}

- (void)keyboardFrameChange:(NSNotification *)notify {
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.chatInputTextView.isFirstResponder)
        return;
    
//    WEAK_SELF;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary *userinfo = notify.userInfo;
//        if (!userinfo)
//            return;
//
//        STRONG_SELF;
//        if (strongSelf->hasActivateKeyboard) {
//            [weakSelf handleKeyboardFrameChange:notify];
//        }else {
//            [weakSelf handleKeyboardFrameChangeWithNoAnimation:notify];
//        }
//    });
    
    NSDictionary *userinfo = notify.userInfo;
    if (!userinfo)
        return;

    if (hasActivateKeyboard) {
        [self handleKeyboardFrameChange:notify];
    }else {
        [self handleKeyboardFrameChangeWithNoAnimation:notify];
    }
}

- (void)handleKeyboardFrameChangeWithNoAnimation:(NSNotification *)notify {
    NSDictionary *userinfo = notify.userInfo;
    
    if ([notify.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect endFrame = [(NSValue *)userinfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = CGRectGetHeight(endFrame);
        if (keyboardHeight == 0)
            return;
        
        SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
        keyboardShowHideInfo.keyboardHeight = keyboardHeight;
        keyboardShowHideInfo.duration = 0;

        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }else if ([notify.name isEqualToString:UIKeyboardDidShowNotification]) {
        CGRect beginFrame = [(NSValue *)userinfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = CGRectGetHeight(beginFrame);
        if (keyboardHeight > 0) {
            hasActivateKeyboard = YES;
            self.shareInputView.hidden = NO;
            [LLEmotionInputView sharedInstance].hidden = NO;
        }
    }
}

- (void)handleKeyboardFrameChange:(NSNotification *)notify {
    if (!self.delegate)
        return;
    NSDictionary *userinfo = notify.userInfo;
    
    CGFloat duration = [userinfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve _curve = [userinfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    keyboardShowHideInfo.curve = animationOptionsWithCurve(_curve);
    
    //FIXME: 第三方输入法会导致 UIKeyboardWillShowNotification 派发3次
    //为什么要设计成派发3次？
    if ([notify.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect toFrame = [(NSValue *)userinfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = CGRectGetHeight(toFrame);
        if (keyboardHeight == 0)
            return;

        keyboardShowHideInfo.keyboardHeight = keyboardHeight;
        SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
        keyboardShowHideInfo.duration = duration;
        
        [UIView animateWithDuration:duration
                              delay:0
                            options:keyboardShowHideInfo.curve
                         animations:^{
            self.chatInputTextView.alpha = 1;
            self.chatRecordBtn.alpha = 0;
                             self.chatTextViewHeightConstraint.constant = textViewHeightConstant;
                             [self layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }];
        
        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }else if ([notify.name isEqualToString:UIKeyboardWillHideNotification]) {
        if (keyboardShowHideInfo.toKeyboardType == kLLKeyboardTypeEmotion) {
            keyboardShowHideInfo.duration = duration;
            keyboardShowHideInfo.keyboardHeight = CHAT_KEYBOARD_PANEL_HEIGHT;
            
            [LLEmotionInputView sharedInstance].top_LL = CGRectGetMaxY(self.frame) + CHAT_KEYBOARD_PANEL_HEIGHT;
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState |
             UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [LLEmotionInputView sharedInstance].top_LL = CGRectGetMaxY(self.frame);
                             } completion:nil];
        }else if (keyboardShowHideInfo.toKeyboardType == kLLKeyboardTypePanel) {
            keyboardShowHideInfo.duration = duration;
            keyboardShowHideInfo.keyboardHeight = CHAT_KEYBOARD_PANEL_HEIGHT;
        }else if (keyboardShowHideInfo.toKeyboardType == kLLKeyboardTypeRecord) {
            //如果文字输入框有内容，需要调整高度
            [UIView animateWithDuration:duration animations:^{
                self.chatInputTextView.alpha = 0;
                self.chatRecordBtn.alpha = 1;
                self.chatTextViewHeightConstraint.constant = MIN_TEXT_HEIGHT;
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            
            keyboardShowHideInfo.keyboardHeight = 0;
            keyboardShowHideInfo.duration = duration;
        }else if (keyboardShowHideInfo.toKeyboardType == kLLKeyboardTypeNone) {
            keyboardShowHideInfo.keyboardHeight = 0;
            keyboardShowHideInfo.duration = duration;
        }else {
            SET_KEYBOARD_TYPE(kLLKeyboardTypeNone);
            keyboardShowHideInfo.keyboardHeight = 0;
            keyboardShowHideInfo.duration = duration;
        }
        
        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }

}

#pragma mark - 会话 -

- (void)textViewResignFirstResponder {
    [self.chatInputTextView resignFirstResponder];
}

- (void)textViewBecomeFirstResponder {
    canBecomeFirstResponder = YES;
    [self.chatInputTextView becomeFirstResponder];
}

- (void)dismissKeyboard {
    if (self.keyboardType == kLLKeyboardTypeRecord ||
        self.keyboardType == kLLKeyboardTypeNone)
        return;
    SET_KEYBOARD_TYPE(kLLKeyboardTypeNone);
    
    if (self.chatInputTextView.isFirstResponder) {
        [self textViewResignFirstResponder];
    }else {
        keyboardShowHideInfo.duration = 0.25;
        keyboardShowHideInfo.keyboardHeight = 0;
        keyboardShowHideInfo.curve = UIViewAnimationOptionCurveEaseInOut;
        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }

}

- (void)activateKeyboard {
    self.chatInputTextView.editable = YES;
    canBecomeFirstResponder = YES;
    [self.chatInputTextView becomeFirstResponder];
    self.chatInputTextView.text = self.draft;
    
    endScrollingAnimation = YES;
    self.chatInputTextView.allowContentOffsetChange = NO;
    if (self.chatInputTextView.contentSize.height >= maxTextViewHeight + FLT_EPSILON) {
        CGRect caretRect = [self currentCaretRectAfterAdjustment];
        CGRect containerRect = CGRectZero;
        containerRect.origin = self.chatInputTextView.contentOffset;
        containerRect.size = self.chatInputTextView.frame.size;

        if (!CGRectContainsRect(containerRect, caretRect)) {
            endScrollingAnimation = NO;
            self.chatInputTextView.allowContentOffsetChange = YES;
            [self.chatInputTextView scrollRectToVisible:caretRect animated:YES];
        }
    }
    
}

- (void)dismissKeyboardWhenConversationEnd {
    SET_KEYBOARD_TYPE(kLLKeyboardTypeNone);

    hasActivateKeyboard = NO;
    canBecomeFirstResponder = NO;
    if (textViewAddedObserver) {
        [self removeObserverForTextView];
    }
    if (hasRegisterKeyboardNotification) {
        [self unregisterKeyboardNotification];
    }
    
    self.chatInputTextView.allowContentOffsetChange = YES;
    self.chatInputTextView.text = nil;
    self.chatInputTextView.editable = NO;
}

- (void)prepareKeyboardWhenConversationWillBegin {
    if (textViewAddedObserver) {
        [self removeObserverForTextView];
    }
    
    [self layoutTextViewWithText:self.draft];
    
    if (self.draft.length > 0) {
        hasActivateKeyboard = NO;

        SET_KEYBOARD_TYPE(kLLKeyboardTypeDefault);
        keyboardShowHideInfo.duration = 0;
        self.shareInputView.hidden = YES;
        [LLEmotionInputView sharedInstance].hidden = YES;
        
    }else {
        hasActivateKeyboard = YES;

        keyboardShowHideInfo.duration = 0;
        keyboardShowHideInfo.keyboardHeight = 0;
        self.chatInputTextView.allowContentOffsetChange = NO;
        endScrollingAnimation = YES;
    }
    
    
    if (!textViewAddedObserver) {
        [self addObserverForTextView];
    }
    if (!hasRegisterKeyboardNotification) {
        [self registerKeyboardNotification];
    }

}

- (void)prepareKeyboardWhenConversationDidBegan {
    self.chatInputTextView.editable = YES;
    
}


- (void)setTextViewEditable:(BOOL)editable {
    self.chatInputTextView.editable = editable;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    return canBecomeFirstResponder;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}


#pragma mark - 处理文字输入

- (CGSize)calSize:(NSString *)text {
    static CGSize calSize;
    static CGFloat textViewWidth = 0;
    if (textViewWidth == 0) {
        textViewWidth = self.chatInputTextView.frame.size.width - self.chatInputTextView.textContainerInset.left - self.chatInputTextView.textContainerInset.right - 2 * self.chatInputTextView.textContainer.lineFragmentPadding;

        calSize = CGSizeMake(textViewWidth, MAXFLOAT);
    }

    CGRect rect = [text boundingRectWithSize:calSize
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];

    return rect.size;
}

- (NSString *)currentInputText {
    return self.chatInputTextView.text;
}


- (void)layoutTextViewWithText:(NSString *)text {
    _textViewText = text;
    [[LLEmotionInputView sharedInstance] sendEnabled:_textViewText.length > 0];
    
    CGSize size = [self calSize:_textViewText];
    
    //单行文本
    if (size.height < lineHeight + FLT_EPSILON) {
        self.chatInputTextView.scrollEnabled = YES;
        self.chatInputTextView.textContainerInset = Regular_EdgeInset;
        size.height = MIN_TEXT_HEIGHT;
        
        if (self.chatTextViewHeightConstraint.constant != size.height) {
            self.chatTextViewHeightConstraint.constant = size.height;
            textViewHeightConstant = size.height;
            [self layoutIfNeeded];
        }
        
    }else {
        if (size.height >= (TEXT_VIEW_MAX_LINE * lineHeight - lineSpacing - FLT_EPSILON)) {
            size.height = TEXT_VIEW_MAX_LINE * lineHeight - lineSpacing;
            
            self.chatInputTextView.scrollEnabled = YES;
            UIEdgeInsets inset = UIEdgeInsetsMake(lineSpacing, 6, 3, 6);
            inset.bottom += (ceil(size.height) - size.height )/2;
            inset.top += (ceil(size.height) - size.height )/2;
            self.chatInputTextView.textContainerInset = inset;
            
            maxTextViewHeight = size.height
                        + self.chatInputTextView.textContainerInset.top
                        + self.chatInputTextView.textContainerInset.bottom;
            size.height = maxTextViewHeight;
 
        }else if (size.height < (TEXT_VIEW_MAX_LINE -1) * lineHeight - lineSpacing + FLT_EPSILON) {
            self.chatInputTextView.scrollEnabled = NO;
            UIEdgeInsets inset = UIEdgeInsetsMake(3, 6, 5, 6);
            self.chatInputTextView.textContainerInset = inset;
            
            size.height = ceil(size.height) + self.chatInputTextView.textContainerInset.top
            + self.chatInputTextView.textContainerInset.bottom;
            
        }

        if (self.chatTextViewHeightConstraint.constant != size.height) {
            self.chatTextViewHeightConstraint.constant = size.height;
            textViewHeightConstant = size.height;
            [self layoutIfNeeded];
        }

    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!endScrollingAnimation && self.chatInputTextView.allowContentOffsetChange){
        endScrollingAnimation = YES;
        self.chatInputTextView.allowContentOffsetChange = NO;

    }
}

//FIXME:系统输入法，输入汉字可能派发两次textViewDidChange:事件，此时输入英文则只派发一次
//如果切换第三方输入法，输入汉字，也仅仅派发一次
- (void)textViewDidChange:(UITextView *)textView {
    if ([_textViewText isEqualToString:textView.text]) {
        return;
    }
    _textViewText = textView.text;
    [[LLEmotionInputView sharedInstance] sendEnabled:_textViewText.length > 0];
    SAFE_SEND_MESSAGE(self.delegate, textViewDidChange:) {
        [self.delegate textViewDidChange:textView];
    }
    
    keyboardShowHideInfo.curve = UIViewAnimationOptionCurveEaseInOut;
    keyboardShowHideInfo.duration = DEFAULT_DURATION;
    keyboardShowHideInfo.toKeyboardType = self.keyboardType;
    
    CGSize size = [self calSize: self.chatInputTextView.text];
    
    //单行文本
    if (size.height < lineHeight + FLT_EPSILON) {
        self.chatInputTextView.textContainerInset = Regular_EdgeInset;
        self.chatInputTextView.allowContentOffsetChange = YES;
        [self.chatInputTextView setContentOffset:CGPointZero animated:NO];
        self.chatInputTextView.allowContentOffsetChange = NO;
        
        size.height = MIN_TEXT_HEIGHT;
        
        if (self.chatTextViewHeightConstraint.constant == size.height)
            return;

        [UIView animateWithDuration:DEFAULT_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut |
                                    UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.chatTextViewHeightConstraint.constant = size.height;
                             textViewHeightConstant = size.height;
                             [self layoutIfNeeded];
                         }
                         completion:nil
         ];
        
        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }else{
        if (size.height >= (TEXT_VIEW_MAX_LINE * lineHeight - lineSpacing - FLT_EPSILON)) {
            size.height = TEXT_VIEW_MAX_LINE * lineHeight - lineSpacing;
            
            [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                self.chatInputTextView.scrollEnabled = YES;
                UIEdgeInsets inset = UIEdgeInsetsMake(lineSpacing, 6, 3, 6);
                inset.bottom += (ceil(size.height) - size.height )/2;
                inset.top += (ceil(size.height) - size.height )/2;
                self.chatInputTextView.textContainerInset = inset;
            }];
            
            size.height = size.height
                    + self.chatInputTextView.textContainerInset.top
                    + self.chatInputTextView.textContainerInset.bottom;
            maxTextViewHeight = size.height;
            
        }else if (size.height < (TEXT_VIEW_MAX_LINE -1) * lineHeight - lineSpacing + FLT_EPSILON) {
            [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                self.chatInputTextView.scrollEnabled = NO;
                UIEdgeInsets inset = UIEdgeInsetsMake(3, 6, 5, 6);
                self.chatInputTextView.textContainerInset = inset;
            }];
            
            size.height = ceil(size.height) + self.chatInputTextView.textContainerInset.top
            + self.chatInputTextView.textContainerInset.bottom;
            
        }
        
        WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf adjustTextViewPosition:YES];
        });
        
        if (self.chatTextViewHeightConstraint.constant == size.height)
            return;
        
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut |
                                    UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.chatTextViewHeightConstraint.constant = size.height;
                             textViewHeightConstant = size.height;
                             [self layoutIfNeeded];
                         }
                         completion: nil
         ];
        
        [self.delegate updateKeyboard:keyboardShowHideInfo];
    }
}

- (CGRect)currentCaretRectAfterAdjustment {
    CGRect rect = [self.chatInputTextView caretRectForPosition:self.chatInputTextView.selectedTextRange.end];
    BOOL isLastLine = CGRectGetMaxY(rect) + lineHeight > self.chatInputTextView.contentSize.height;
    
    rect.origin.y -= (self.chatInputTextView.textContainerInset.top -1);
    rect.size.height += self.chatInputTextView.textContainerInset.top -1 +
    (isLastLine ? (self.chatInputTextView.textContainerInset.bottom - 0.5) :(lineSpacing - 0.5));
    
    return rect;
}


- (void)adjustTextViewPosition:(BOOL)animated {
    if (!self.chatInputTextView.selectedTextRange) return;
    
    CGFloat _gap = CGRectGetHeight(self.chatInputTextView.frame) - (self.chatInputTextView.contentSize.height - self.chatInputTextView.contentOffset.y);
    
    if (_gap >= FLT_EPSILON) {
        [UIView animateWithDuration:animated ? DEFAULT_DURATION : 0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                                    | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.chatInputTextView.allowContentOffsetChange = YES;
                             [self.chatInputTextView setContentOffset:CGPointMake(0, self.chatInputTextView.contentSize.height - CGRectGetHeight(self.chatInputTextView.frame)) animated:NO];
                             self.chatInputTextView.allowContentOffsetChange = NO;
                             
                         }
                         completion:nil];

    }else {
        [UIView animateWithDuration:animated ? DEFAULT_DURATION : 0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                                    | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.chatInputTextView.allowContentOffsetChange = YES;
                             [self.chatInputTextView scrollRectToVisible:[self currentCaretRectAfterAdjustment] animated:NO];
                         }
                         completion:^(BOOL finished) {
                             self.chatInputTextView.allowContentOffsetChange = NO;
                         }];

    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        //KVO捕获通过TextView.text = @"", 代码方式设置文本框内容的情况
        [self textViewDidChange:self.chatInputTextView];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:
         context];
    }
    
}

- (void)dealloc {
    if (textViewAddedObserver) {
        [self removeObserverForTextView];
    }
}

#pragma mark - 发送文字消息

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [self sendTextMessage:textView.text];
        return NO;
    }
    
    return YES;
}


- (void)sendTextMessage:(NSString *)text {
    if (text.length > 0) {
        NSString * str = [text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str.length == 0) {
            [LLUtils showMessageAlertWithTitle:nil message:@"不能发送空白消息"];
        }else {
            self.chatInputTextView.text = nil;
            WEAK_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.delegate sendTextMessage:text];
            });
        }
    }
    
}


#pragma mark - 输入表情

- (void)emojiCellDidSelected:(LLEmotionModel *)model {
    NSMutableString *text = [self.chatInputTextView.text mutableCopy];
    NSRange selectedRange = self.chatInputTextView.selectedRange;
    NSString *emotionString = [NSString stringWithFormat:@"[%@]", model.text];
                               
    [text insertString:emotionString atIndex:selectedRange.location];
    self.chatInputTextView.text = text;
    self.chatInputTextView.selectedRange = NSMakeRange(selectedRange.location + emotionString.length, selectedRange.length);
}

- (void)gifCellDidSelected:(LLEmotionModel *)model {
    [self.delegate sendGifMessage:model];
}

- (void)sendCellDidSelected {
    [self sendTextMessage:self.chatInputTextView.text];
}

- (void)deleteCellDidSelected {
    NSMutableString *text = [self.chatInputTextView.text mutableCopy];
    if (text.length == 0) return;
    
    NSRange selectedRange = self.chatInputTextView.selectedRange;
    
    if (selectedRange.length > 0) {
        [text deleteCharactersInRange:selectedRange];
        self.chatInputTextView.text = text;
        self.chatInputTextView.selectedRange = NSMakeRange(selectedRange.location, 0);
        
    }else if (selectedRange.length == 0 && selectedRange.location != 0) {
        //删除前面一个字符或Emotion字符串
        NSRange range = [[LLEmotionModelManager sharedManager] rangeOfEmojiAtIndexOfString:text index:selectedRange.location];
        
        if (range.location == NSNotFound) {
            NSRange backward = NSMakeRange(selectedRange.location - 1, 1);
            [text deleteCharactersInRange:backward];
            self.chatInputTextView.text = text;
            self.chatInputTextView.selectedRange = NSMakeRange(selectedRange.location - 1, 0);
        }else {
            [text deleteCharactersInRange:range];
            self.chatInputTextView.text = text;
            self.chatInputTextView.selectedRange = NSMakeRange(range.location, 0);
        }
    }

}


- (void)cellWithTagDidTapped:(NSInteger)tag {
    [self.delegate cellWithTagDidTapped:tag];
}

#pragma mark - 录音

- (BOOL)recordButtonTouchEventEnded {
    UITouch *touch = [recordEvent.allTouches anyObject];
    if (touch == nil || touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded) {
        return YES;
    }
    
    return NO;
}

- (IBAction)recordButtonTouchDown:(id)sender {
    WEAK_SELF;
    
    self.recordPermissionGranted = NO;
    __block BOOL firstUseMicrophone = NO;
    [[LLAudioManager sharedManager] requestRecordPermission:^(AVAudioSessionRecordPermission recordPermission) {
        if (recordPermission == AVAudioSessionRecordPermissionUndetermined) {
            firstUseMicrophone = YES;
        }else if (recordPermission == AVAudioSessionRecordPermissionGranted) {
        //第一次录音时，会请求麦克风权限。
        //1、用户抬离手指后同意访问麦克风，这种情况不继续录音，因为用户已经离开录音按钮了
        //2、用户保持手指按压录音按钮，用其他手指同意访问麦克风，则从获取授权的时间点开始录音
            if (!firstUseMicrophone || ![weakSelf recordButtonTouchEventEnded]) {
                weakSelf.recordPermissionGranted = YES;
                [weakSelf setRecordButtonBackground:YES];
                STRONG_SELF;
                
                strongSelf->touchDownTime = CACurrentMediaTime();
                if ([weakSelf.delegate respondsToSelector:@selector(voiceRecordingShouldStart)]) {
                    strongSelf->block = dispatch_block_create(0, ^{
                        [weakSelf setRecordButtonTitle:YES];
                        [weakSelf.delegate voiceRecordingShouldStart];
                    });
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->block);
                }
            }
        }
    }];
    
}

- (IBAction)recordButtonTouchUpinside:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (currentTime - touchDownTime < MIN_RECORD_TIME_REQUIRED + 0.25) {
        self.chatRecordBtn.enabled = NO;
        if (!dispatch_block_testcancel(block))
            dispatch_block_cancel(block);
        block = nil;
        
        if ([self.delegate respondsToSelector:@selector(voiceRecordingTooShort)]) {
            [self.delegate voiceRecordingTooShort];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN_RECORD_TIME_REQUIRED * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.chatRecordBtn.enabled = YES;
            [self recordActionEnd];
        });
        
    }else {
        [self recordActionEnd];
        if ([self.delegate respondsToSelector:@selector(voicRecordingShouldFinish)]) {
            [self.delegate voicRecordingShouldFinish];
        }
    }

}

- (IBAction)recordButtonTouchUpoutside:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    [self recordActionEnd];
    
    if (!dispatch_block_testcancel(block))
        dispatch_block_cancel(block);
    block = nil;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingShouldCancel)]) {
        [self.delegate voiceRecordingShouldCancel];
    }

}

- (IBAction)recordButtonTouchCancelled:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    [self recordButtonTouchUpinside:sender];
}

- (void)cancelRecordButtonTouchEvent {
    [self.chatRecordBtn cancelTrackingWithEvent:nil];
    [self recordActionEnd];
}

- (IBAction)recordButtonDragEnter:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingDidDraginside)]) {
        [self.delegate voiceRecordingDidDraginside];
    }
}

- (IBAction)recordButtonDragExit:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingDidDragoutside)]) {
        [self.delegate voiceRecordingDidDragoutside];
    }
}

- (void)recordActionEnd {
    [self setRecordButtonTitle:NO];
    [self setRecordButtonBackground:NO];
    recordEvent = nil;
}

- (void)setRecordButtonBackground:(BOOL)isRecording {
    if (isRecording) {
        _chatRecordBtn.backgroundColor = UIColorHexRGB(@"#C6C7CB");
    }else {
        _chatRecordBtn.backgroundColor = UIColorHexRGB(@"#F3F4F8");
    }
}

- (void)setRecordButtonTitle:(BOOL)isRecording {
    if (isRecording) {
        [_chatRecordBtn setTitle:@"松开 结束" forState:UIControlStateNormal];
    }else {
        [_chatRecordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.chatRecordBtn) {
        recordEvent = event;
    }else if (view == self.chatInputTextView) {
        canBecomeFirstResponder = YES;
    }
    
    return view;
}


@end



