//
//  LLChatTextView.h
//  LLWeChat
//
//  Created by GYJZH on 08/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageBaseCell.h"


@interface LLChatTextView : UITextView

@property (nonatomic) LLMessageBaseCell *targetCell;

@property (nonatomic) BOOL allowContentOffsetChange;

@end
