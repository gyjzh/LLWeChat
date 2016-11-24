//
//  LLMessageRecordingCell.h
//  LLWeChat
//
//  Created by GYJZH on 9/19/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageBaseCell.h"

@interface LLMessageRecordingCell : LLMessageBaseCell

+ (instancetype)sharedRecordingCell;

- (void)updateDurationLabel:(int)duration;

@end
