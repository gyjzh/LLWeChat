//
//  LLTextDisplayController.m
//  LLWeChat
//
//  Created by GYJZH on 06/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLTextDisplayController.h"
#import "LLSimpleTextLabel.h"
#import "UIKit+LLExt.h"
#import "LLEmotionModelManager.h"
#import "LLUtils.h"

#define FONT_SIZE 27

@interface LLTextDisplayController () <UIGestureRecognizerDelegate>

@property (nonatomic) LLSimpleTextLabel *contentLabel;

@property (nonatomic) UIView *screenSnapshot;
@property (nonatomic) UIWindow *targetWindow;

@end

@implementation LLTextDisplayController {
    UIFont *labelFont;
    UITapGestureRecognizer *tap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];

    labelFont = [UIFont systemFontOfSize:FONT_SIZE];
    tap = [self.view addTapGestureRecognizer:@selector(tapHandler:) target:self];
    tap.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupContentLabel {
    self.contentLabel = [[LLSimpleTextLabel alloc] init];
    
    self.contentLabel.frame = self.view.bounds;
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    self.contentLabel.textContainer.lineFragmentPadding = 0;
    self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentLabel.editable = NO;
    self.contentLabel.scrollEnabled = YES;
    self.contentLabel.selectable = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.showsVerticalScrollIndicator = YES;
    self.contentLabel.font = labelFont;
    NSAttributedString *richText = [LLSimpleTextLabel createAttributedStringWithEmotionString:self.messageModel.text font:labelFont lineSpacing:2];
    self.contentLabel.textContainerInset = [self calLabelTextContainerInset:self.contentLabel attributedString:richText];
    self.contentLabel.attributedText = richText;
    [self.view addSubview:self.contentLabel];
    
    WEAK_SELF;
    self.contentLabel.longPressAction = ^(LLLabelRichTextData *data,UIGestureRecognizerState state) {
        if (!data)return;
        
        if (state == UIGestureRecognizerStateEnded) {
            if (data.type == kLLLabelRichTextTypeURL) {
                [weakSelf.textActionDelegate textLinkDidTapped:data.url userinfo:weakSelf];
            }else if (data.type == kLLLabelRichTextTypePhoneNumber) {
                [weakSelf.textActionDelegate textPhoneNumberDidTapped:data.phoneNumber userinfo:weakSelf];
            }
            
            [weakSelf exit];
        }
    
    };
    
    self.contentLabel.tapAction = ^(LLLabelRichTextData *data) {
        if (!data)return;

        if (data.type == kLLLabelRichTextTypeURL) {
            [weakSelf.textActionDelegate textLinkDidTapped:data.url userinfo:weakSelf];
        }else if (data.type == kLLLabelRichTextTypePhoneNumber) {
            [weakSelf.textActionDelegate textPhoneNumberDidTapped:data.phoneNumber userinfo:weakSelf];
        }
        
        [weakSelf exit];
    };
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == tap) {
        if ([self.contentLabel shouldReceiveTouchAtPoint:[touch locationInView:self.contentLabel]]) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}


- (UIEdgeInsets)calLabelTextContainerInset:(LLSimpleTextLabel *)label attributedString:(NSAttributedString *)attributedString {
    UIEdgeInsets defaultEdgeInset = UIEdgeInsetsMake(32, 20, 45, 20);
    
    CGRect frame = [attributedString boundingRectWithSize:CGSizeMake(CGRectGetWidth(label.frame) - defaultEdgeInset.left - defaultEdgeInset.right, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    CGFloat textWidth = CGRectGetWidth(frame);
    CGFloat textHeight = CGRectGetHeight(frame);

    //水平左右间隔最小各为20，但是布局完毕后如果两侧空白有较多剩余
    //则适当调大左右间隔,避免左右两个间距差别太大，不对称。
    defaultEdgeInset.left = round((CGRectGetWidth(label.frame) - textWidth) / 2);
    defaultEdgeInset.right = floor(CGRectGetWidth(label.frame) - textWidth - defaultEdgeInset.left);
    
    //垂直方向：不满一屏时，上面空白与下面空白比例为0.4：0.6, 稍微向上偏移
    if (textHeight + defaultEdgeInset.top + defaultEdgeInset.bottom < CGRectGetHeight(label.frame)) {
        defaultEdgeInset.top = round(0.4 *(CGRectGetHeight(label.frame) - textHeight));
        defaultEdgeInset.bottom = 0;
    }
    
    return defaultEdgeInset;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 弹入弹出动画 -

- (void)tapHandler:(UIGestureRecognizer *)tap {
    [self exit];
}

- (void)exit {
    if (self.contentLabel.alpha == 0)
        return;
    
    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
        self.contentLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.targetWindow.hidden = YES;
        self.targetWindow = nil;
    } ];
}

- (void)showInWindow:(UIWindow *)targetWindow {
    self.targetWindow = targetWindow;

    [self setupContentLabel];
    self.contentLabel.alpha = 0;

    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
        self.contentLabel.alpha = 1;
    }];
    
}



@end
