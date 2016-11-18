//
//  LLShareInputView.h
//  LLWeChat
//
//  Created by GYJZH on 8/1/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLChatShareDelegate.h"

@interface LLCollectionShareCell : UICollectionViewCell

@end


@interface LLShareInputView : UIView

@property (nonatomic, weak) id<LLChatShareDelegate> delegate;

@end
