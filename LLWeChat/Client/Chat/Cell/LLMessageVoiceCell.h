//
//  LLMessageVoiceCell.h
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageBaseCell.h"

#define MIN_CELL_WIDTH 70
#define MAX_CELL_WIDTH 194

@interface LLMessageVoiceCell : LLMessageBaseCell

- (BOOL)isVoicePlaying;

- (void)stopVoicePlaying;

- (void)startVoicePlaying;

- (void)updateVoicePlayingStatus;

@end
