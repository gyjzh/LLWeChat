//
//  LLChatVoiceTipView.m
//  LLWeChat
//
//  Created by GYJZH on 9/20/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatVoiceTipView.h"
#import "LLUtils.h"

@implementation LLChatVoiceTipView

- (void)removeWithAnimation {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self removeWithAnimation];
}


@end
