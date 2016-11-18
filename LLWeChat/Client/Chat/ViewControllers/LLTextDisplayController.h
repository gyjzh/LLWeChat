//
//  LLTextDisplayController.h
//  LLWeChat
//
//  Created by GYJZH on 06/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageModel.h"
#import "LLTextActionDelegate.h"

@interface LLTextDisplayController : UIViewController

@property (nonatomic) LLMessageModel *messageModel;

@property (nonatomic, weak) id<LLTextActionDelegate> textActionDelegate;

- (void)showInWindow:(UIWindow *)targetWindow;

@end
