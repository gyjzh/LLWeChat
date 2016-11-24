//
//  LLPhotoToolbar.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLPhotoToolbar.h"
#import "LLImageNumberView.h"
#import "LLImagePickerConfig.h"
#import "LLUtils.h"

@interface LLPhotoToolbar ()

@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UIButton *previewBtn;
@property (nonatomic) UIButton *doneBtn;
@property (nonatomic) LLImageNumberView *numberView;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL previewAction;
@property (nonatomic) SEL finishAction;

@end

@implementation LLPhotoToolbar


- (instancetype)initWithStyle:(LLPhotoToolbarStyle)style {
    CGRect frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)-44, CGRectGetWidth([UIScreen mainScreen].bounds), 44);
    self = [super initWithFrame:frame];
    
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 44)];
    [self addSubview:self.toolBar];
    
    if (style == kLLPhotoToolbarStyle1) {
        self.toolBar.barStyle = UIBarStyleDefault;
    }else {
//        self.toolBar.barStyle = UIBarStyleBlack;
        self.toolBar.barTintColor = [UIColor colorWithRed:19/255.0 green:19/255.0 blue:20/255.0 alpha:1];
        if ([LLUtils systemVersion] < 10.0) {
            self.toolBar.subviews[0].alpha = 0.6;
        }else {
            //IOS10 UIToolBar显示列表结构发生改变
            self.toolBar.alpha = 0.6;
        }
    }
    
    
    if (style ==kLLPhotoToolbarStyle1) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _previewBtn.frame = CGRectMake(6, 0, 50, 44);
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _previewBtn.enabled = NO;
        [_previewBtn addTarget:self action:@selector(doPreview) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_previewBtn];
    }
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _doneBtn.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 6 - 50, 0, 50, 44);
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_doneBtn setTitleColor:DEFAULT_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_doneBtn setTitleColor:[UIColor colorWithRed:164.0/255 green:219.0/255 blue:174.0/255 alpha:1] forState:UIControlStateDisabled];
    _doneBtn.enabled = NO;
    [_doneBtn addTarget:self action:@selector(doFinish) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneBtn];
    
    
    _numberView = [[LLImageNumberView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_doneBtn.frame)- 27 + 7, (44 - 28)/2, 27, 28)];
    _numberView.hidden = YES;
    [self addSubview:_numberView];

    
    return self;
}


- (void)addTarget:(id)target previewAction:(SEL)action1 finishAction:(SEL)action2 {
    self.target = target;
    self.previewAction = action1;
    self.finishAction = action2;
}

- (void)doPreview {
    IMP _imp = [self.target methodForSelector:self.previewAction];
    void (*func)(id, SEL) = (void *)_imp;
    func(self.target, self.previewAction);
}

- (void)doFinish {
    IMP _imp = [self.target methodForSelector:self.finishAction];
    void (*func)(id, SEL) = (void *)_imp;
    func(self.target, self.finishAction);
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    if (_number > 0) {
        self.previewBtn.enabled = YES;
        self.doneBtn.enabled = YES;
        self.numberView.hidden = NO;
        self.numberView.number = _number;
    }else {
        self.previewBtn.enabled = NO;
        self.doneBtn.enabled = NO;
        self.numberView.hidden = YES;
    }
}

@end
