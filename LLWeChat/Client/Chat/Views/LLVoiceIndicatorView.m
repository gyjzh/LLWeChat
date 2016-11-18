//
//  LLVoiceIndicatorView.m
//  LLWeChat
//
//  Created by GYJZH on 8/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLVoiceIndicatorView.h"
#import "UIKit+LLExt.h"
#import "LLColors.h"

#define kLLVoiceNoteText_ToRecord @"手指上滑，取消发送"
#define kLLVoiceNoteText_ToCancel @"松开手指，取消发送"
#define kLLVoiceNoteText_TooShort @"说话时间太短"
#define kLLVoiceNoteText_TooLong @"说话时间超长"
#define kLLVoiceNoteText_VolumeTooLow @"请调大音量后播放"

#define ImageNamed_Cancel @"RecordCancel"
#define ImageNamed_TimeTooShortOrLong @"MessageTooShort"
#define ImageNamed_VolumeTooLow @"volume_smalltipsicon"

@interface LLVoiceIndicatorView ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UIImageView *signalImageView;

@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;

@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;


@property (nonatomic) NSInteger countDown;

@end


@implementation LLVoiceIndicatorView {
    BOOL _canCancelByTouch;
}

@synthesize canCancelByTouch = _canCancelByTouch;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.countDown = 0;

}


- (void)setStyle:(LLVoiceIndicatorStyle)style {
    _style = style;
    self.infoImageView.hidden = YES;
    self.recordingView.hidden = YES;
    self.countDownLabel.hidden = YES;
    [self updateMetersValue:0];

    switch (style) {
        case kLLVoiceIndicatorStyleRecord:
            self.label.backgroundColor = [UIColor clearColor];
            self.label.text = kLLVoiceNoteText_ToRecord;
            self.countDownLabel.hidden = (self.countDown == 0);
            self.recordingView.hidden = !self.countDownLabel.hidden;
            self.canCancelByTouch = NO;
            break;
        case kLLVoiceIndicatorStyleCancel:
            self.label.backgroundColor = kLLBackgroundColor_DarkRed;
            self.label.text = kLLVoiceNoteText_ToCancel;
            self.countDownLabel.hidden = (self.countDown == 0);
            self.infoImageView.hidden = !self.countDownLabel.hidden;
            self.infoImageView.image = [UIImage imageNamed:ImageNamed_Cancel];
            self.canCancelByTouch = NO;
            break;
        case kLLVoiceIndicatorStyleTooShort:
            self.label.backgroundColor = [UIColor clearColor];
            self.label.text = kLLVoiceNoteText_TooShort;
            self.infoImageView.hidden = NO;
            self.infoImageView.image = [UIImage imageNamed:ImageNamed_TimeTooShortOrLong];
            self.canCancelByTouch = NO;
            break;
        case kLLVoiceIndicatorStyleTooLong:
            self.label.backgroundColor = [UIColor clearColor];
            self.label.text = kLLVoiceNoteText_TooLong;
            self.infoImageView.hidden = NO;
            self.infoImageView.image = [UIImage imageNamed:ImageNamed_TimeTooShortOrLong];
            self.canCancelByTouch = YES;
            break;
        case kLLVoiceIndicatorStyleVolumeTooLow:
            self.label.backgroundColor = [UIColor clearColor];
            self.label.text = kLLVoiceNoteText_VolumeTooLow;
            self.infoImageView.hidden = NO;
            self.infoImageView.image = [UIImage imageNamed:ImageNamed_VolumeTooLow];
            self.canCancelByTouch = YES;
            break;
        
    }
}

- (void)setCountDown:(NSInteger)countDown {
    _countDown = countDown;
    if (countDown > 0) {
        self.infoImageView.hidden = YES;
        self.recordingView.hidden = YES;
        self.countDownLabel.hidden = NO;
        
        self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)countDown];
    }else { 
        [self setStyle:kLLVoiceIndicatorStyleTooLong];
    }
}

//更新麦克风的音量大小
- (void)updateMetersValue:(CGFloat)value {
    NSInteger index = round(value);
    index = index > 8 ? 8 : index;
    index = index < 1 ? 1 : index;
    
    NSString *imageName = [NSString stringWithFormat:@"RecordingSignal00%ld", (long)index];
    self.signalImageView.image = [UIImage imageNamed:imageName];
    
}

- (void)didRemoveFromTipLayer {
    self.countDown = 0;
}

@end
