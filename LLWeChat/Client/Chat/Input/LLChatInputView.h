//
//  LLChatInputView.h
//  LLWeChat
//
//  Created by GYJZH on 7/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLChatInputDelegate.h"
#import "LLChatShareDelegate.h"
#import "LLChatTextView.h"


@interface LLChatInputView : UIView

@property (weak, nonatomic) id<LLChatInputDelegate, LLChatShareDelegate> delegate;

@property (nonatomic) LLKeyboardType keyboardType;

@property (weak, nonatomic) IBOutlet LLChatTextView *chatInputTextView;

@property (nonatomic) NSString *draft;

@property (nonatomic, readonly) NSString *currentInputText;

- (void)registerKeyboardNotification;

- (void)unregisterKeyboardNotification;

- (void)dismissKeyboard;

- (void)activateKeyboard;

- (void)dismissKeyboardWhenConversationEnd;

- (void)prepareKeyboardWhenConversationWillBegin;

- (void)prepareKeyboardWhenConversationDidBegan;

- (void)setTextViewEditable:(BOOL)editable;

- (NSString *)currentInputText;

//当录音时间过长时，由APP主动取消录音按钮的按压事件，结束录音
- (void)cancelRecordButtonTouchEvent;

@end
