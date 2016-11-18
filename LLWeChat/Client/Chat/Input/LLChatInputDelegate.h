//
//  LLChatInputDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 8/12/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLEmotionModel.h"

typedef NS_ENUM(NSInteger, LLKeyboardType) {
    kLLKeyboardTypeDefault = 0, //系统默认键盘
    kLLKeyboardTypeEmotion,     //表情输入键盘
    kLLKeyboardTypePanel,       //提供照片、视频等功能的Panel
    kLLKeyboardTypeRecord,      //按住说话
    kLLKeyboardTypeNone         //当前没有显示键盘
};

struct LLKeyboardShowHideInfo {
    NSInteger keyboardHeight;        //键盘高度
    //    LLKeyboardType fromKeyboardType;  //当前显示的键盘类型
    LLKeyboardType toKeyboardType;    //需要显示/隐藏的键盘类型
    //    BOOL animated;              //是否需要动画效果
    UIViewAnimationOptions curve;
    CGFloat duration;
};

typedef struct LLKeyboardShowHideInfo LLKeyboardShowHideInfo;

@protocol LLChatInputDelegate <NSObject>

- (void)updateKeyboard:(LLKeyboardShowHideInfo) keyboardInfo;


@optional
- (void)sendTextMessage:(NSString *)text;

- (void)sendGifMessage:(LLEmotionModel *)model;

- (void)textViewDidChange:(UITextView *)textView;


#pragma mark - 录音

- (void)voiceRecordingShouldStart;

- (void)voiceRecordingShouldCancel;

- (void)voicRecordingShouldFinish;

- (void)voiceRecordingDidDraginside;

- (void)voiceRecordingDidDragoutside;

- (void)voiceRecordingTooShort;

@end
