//
//  LLActionSheet.h
//  LLWeChat
//
//  Created by GYJZH on 8/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, LLActionStyle) {
    kLLActionStyleDefault = 0,
//    kLLActionStyleCancel,
    kLLActionStyleDestructive
};


@class LLActionSheetAction;

typedef void (^ACTION_BLOCK)(LLActionSheetAction *action);

@interface LLActionSheetAction  : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic) LLActionStyle style;

@property (nonatomic, copy) ACTION_BLOCK handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler style:(LLActionStyle)style;

@end

extern LLActionSheetAction *LL_ActionSheetSeperator;


@interface LLActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title;

- (void)addAction:(LLActionSheetAction *)action;

- (void)addActions:(NSArray<LLActionSheetAction *> *)actions;

- (void)showInWindow:(UIWindow *)window;

- (void)hideInWindow:(UIWindow *)window;

@end
