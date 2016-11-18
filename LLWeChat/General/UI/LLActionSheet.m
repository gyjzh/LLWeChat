//
//  LLActionSheet.m
//  LLWeChat
//
//  Created by GYJZH on 8/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLActionSheet.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLColors.h"

static UIView *actionSheetContainer;

typedef NS_ENUM(NSInteger, LLActionItemType) {
    kLLActionItemTypeTitle,
    kLLActionItemTypeAction,
    kLLActionItemTypeCancel
};

#define TITLE_FONT_SIZE 13
#define TITLE_FONT_COLOR [UIColor lightGrayColor]
#define TITLE_BAR_HEIGHT 65

#define ACTION_FONT_SIZE 17
#define ACTION_FONT_DEFAULT_COLOR [UIColor blackColor]
#define ACTION_FONT_DESTRUCTIVE_COLOR [UIColor redColor];
#define ACTION_BAR_HEIGHT 55

#define CANCEL_FONT_SIZE 17
#define CANCEL_FONT_COLOR [UIColor blackColor]
#define CANCEL_BAR_HEIGHT 55

#define CANCEL_BAR_GAP 7

LLActionSheetAction *LL_ActionSheetSeperator = nil;

@implementation LLActionSheetAction

+ (void)load {
    if (!LL_ActionSheetSeperator)
        LL_ActionSheetSeperator = [[LLActionSheetAction alloc] init];
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(LLActionSheetAction *action))handler {
    return [self actionWithTitle:title handler:handler style:kLLActionStyleDefault];
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler style:(LLActionStyle)style {
    
    LLActionSheetAction * action = [[LLActionSheetAction alloc] init];
    action.title = title;
    action.handler = handler;
    action.style = style;
    
    return action;
}


@end


@interface LLActionSheet ()

@property (nonatomic, copy) NSString *title;

@property (nonatomic) UIView *contentView;

@property (nonatomic) NSMutableArray<LLActionSheetAction *> *actions;

@end


@implementation LLActionSheet {
    CGRect _windowBounds;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:[LLUtils screenFrame]];
    if (self) {
        self.title = title;
        self.backgroundColor = [UIColor clearColor];
        self.actions = [NSMutableArray array];

        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = UIColorRGB(210, 210, 210);
        [self addSubview:_contentView];
        
        [self addTapGestureRecognizer:@selector(tapHandler:)];
    }

    return self;
}

- (void)addAction:(LLActionSheetAction *)action {
    [self.actions addObject:action];
}

- (void)addActions:(NSArray<LLActionSheetAction *> *)actions {
    [self.actions addObjectsFromArray:actions];
}

- (void)showInWindow:(UIWindow *)window {
    if (!actionSheetContainer) {
        actionSheetContainer = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        actionSheetContainer.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    }
    
    if (!actionSheetContainer.superview){
        if (!window || window == [LLUtils popOverWindow]) {
           [LLUtils addViewToPopOverWindow:actionSheetContainer];
        }else {
            [window addSubview:actionSheetContainer];
        }
    }

    _windowBounds = [LLUtils screenFrame];
    actionSheetContainer.frame = _windowBounds;
    
    [self setupViews];
    [actionSheetContainer addSubview:self];

    self.contentView.top_LL = CGRectGetHeight(_windowBounds);
    if (actionSheetContainer.subviews.count == 1) {
        actionSheetContainer.alpha = 0;
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.contentView.bottom_LL = CGRectGetHeight(_windowBounds);
                         actionSheetContainer.alpha = 1;
                        }
                     completion:nil];


}


- (void)setupViews {
    CGFloat _y = 0;
    if (self.title && self.title.length > 0) {
        UIView *titleView = [self createItemWithType:kLLActionItemTypeTitle
                                                            data:nil];
        [self.contentView addSubview:titleView];
        _y = CGRectGetMaxY(titleView.frame);
    }

    for (LLActionSheetAction *action in self.actions) {
        if (action == LL_ActionSheetSeperator) {
            _y += CANCEL_BAR_GAP;
        }else {
            UIView *actionButton = [self createItemWithType:kLLActionItemTypeAction
                                                             data:action];
            [self.contentView addSubview:actionButton];
            actionButton.top_LL = _y;
            _y += CGRectGetHeight(actionButton.frame);
        }
    }

    UIView *cancelButton = [self createItemWithType:kLLActionItemTypeCancel
                                                         data:nil];
    [self.contentView addSubview:cancelButton];
    _y += CANCEL_BAR_GAP;
    cancelButton.top_LL = _y;
    _y += CGRectGetHeight(cancelButton.frame);

    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(_windowBounds), _y);
}

- (CGFloat)barHeightForType:(LLActionItemType)type {
    switch(type) {
        case kLLActionItemTypeTitle:
            return TITLE_BAR_HEIGHT;
        case kLLActionItemTypeAction:
            return ACTION_BAR_HEIGHT;
        case kLLActionItemTypeCancel:
            return CANCEL_BAR_HEIGHT;
    }
}


- (UIView *)createItemWithType:(LLActionItemType)type data:(LLActionSheetAction *)data {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(_windowBounds), [self barHeightForType:type]);

    if (type == kLLActionItemTypeTitle) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = TITLE_FONT_COLOR;
        titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.title;
        return titleLabel;
    }else {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setBackgroundImage:[UIImage imageWithColor:kLLBackgroundColor_lightGray] forState:UIControlStateHighlighted];
        
        if (type == kLLActionItemTypeAction) {
            [button setTitle:data.title forState:UIControlStateNormal];
            button.tag = [self.actions indexOfObject:data];
            [button addTarget:self action:@selector(tapAction:)
             forControlEvents:UIControlEventTouchUpInside];
            
            UIColor *buttonTitleColor = data.style == kLLActionStyleDefault ? ACTION_FONT_DEFAULT_COLOR : ACTION_FONT_DESTRUCTIVE_COLOR;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:ACTION_FONT_SIZE];
            
            CALayer *line = [CALayer layer];
            line.backgroundColor = kLLBackgroundColor_lightGray.CGColor;
            line.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1/[LLUtils screenScale]);
            [button.layer addSublayer:line];
        }else if (type == kLLActionItemTypeCancel) {
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tapCancel:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:CANCEL_FONT_COLOR forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:CANCEL_FONT_SIZE];
        }
        
        return button;
    }
    
    return nil;
}

- (void)tapCancel:(id)sender {
    [self close];
}

- (void)tapAction:(UIButton *)sender {
    LLActionSheetAction *action = self.actions[sender.tag];
    if (action.handler) {
        action.handler(action);
        [self close];
    }
}

- (void)tapHandler:(id)sender {
    [self close];
}

- (void)hideInWindow:(UIWindow *)window {
    [self close];
}

- (void)close {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.top_LL = CGRectGetHeight(_windowBounds);
        
        if (actionSheetContainer.subviews.count == 1){
            actionSheetContainer.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (actionSheetContainer.subviews.count == 0){
            if (actionSheetContainer.window == [LLUtils popOverWindow])
                [LLUtils removeViewFromPopOverWindow:actionSheetContainer];
            else {
                [actionSheetContainer removeFromSuperview];
            }
        }
    }];

}

@end
