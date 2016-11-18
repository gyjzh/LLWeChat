//
//  LLBaseChatViewCell.h
//  LLWeChat
//
//  Created by GYJZH on 8/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageModel.h"
#import "LLMessageCellActionDelegate.h"

//Avatar和SuperView之间的约束
#define AVATAR_SUPER_LEFT 10
#define AVATAR_SUPER_TOP 0
#define AVATAR_WIDTH 45
#define AVATAR_HEIGHT 45

//Bubble上下左右的空白量
#define BUBBLE_LEFT_BLANK 7
#define BUBBLE_RIGHT_BLANK 7
#define BUBBLE_TOP_BLANK 2
#define BUBBLE_BOTTOM_BLANK 11

#define BUBBLE_MASK_ARROW 6.5

//Bubble的约束
#define CONTENT_AVATAR_MARGIN 3
#define CONTENT_SUPER_BOTTOM 20
#define CONTENT_SUPER_TOP AVATAR_SUPER_TOP

#define ACTIVITY_VIEW_Y_OFFSET ((BUBBLE_TOP_BLANK - BUBBLE_BOTTOM_BLANK)/2)
//这个距离Cell和bubble之间的间隔
#define ACTIVITY_VIEW_X_OFFSET 5

#define EDIT_CONTROL_SIZE 30

extern BOOL LLMessageCell_isEditing;

extern UIImage *ReceiverTextNodeBkg;
extern UIImage *ReceiverTextNodeBkgHL;
extern UIImage *SenderTextNodeBkg;
extern UIImage *SenderTextNodeBkgHL;

extern UIImage *ReceiverImageNodeBorder;
extern UIImage *ReceiverImageNodeMask;
extern UIImage *SenderImageNodeBorder;
extern UIImage *SenderImageNodeMask;

#define HIDE_STATUS_BUTTON _statusButton.hidden = YES

#define SHOW_STATUS_BUTTON self.statusButton.hidden = NO

#define HIDE_INDICATOR_VIEW _indicatorView.hidden = YES; [_indicatorView stopAnimating]

#define SHOW_INDICATOR_VIEW self.indicatorView.hidden = NO; [_indicatorView startAnimating]

@interface LLMessageBaseCell : UITableViewCell {
    @protected
    UIActivityIndicatorView *_indicatorView;
    UIButton *_statusButton;
    LLMessageModel *_messageModel;
    UIImageView *_selectControl;
    
    UITapGestureRecognizer *tap;
    UILongPressGestureRecognizer *longPressGR;
}

@property (nonatomic) LLMessageModel *messageModel;

@property (nonatomic) UIImageView *avatarImage;

@property (nonatomic) UIImageView *bubbleImage;

@property (nonatomic) UIActivityIndicatorView *indicatorView;

@property (nonatomic) UIButton *statusButton;

@property (nonatomic) UIImageView *selectControl;

@property (nonatomic) BOOL isCellSelected;

@property (nonatomic) BOOL isCellEditing;

@property (nonatomic, weak) id<LLMessageCellActionDelegate> delegate;

@property (nonatomic) NSArray<NSString *> *menuItemActionNames;
@property (nonatomic) NSArray<NSString *> *menuItemNames;

- (void)prepareForUse:(BOOL)isFromMe;

- (void)setCellEditingAnimated:(BOOL)animated;

- (void)willDisplayCell;

- (void)didEndDisplayingCell;

- (void)willBeginScrolling;

- (void)didEndScrolling;

#pragma mark - 布局

- (void)updateMessageUploadStatus;

- (void)updateMessageDownloadStatus;

- (void)updateMessageThumbnail;

- (void)layoutMessageContentViews:(BOOL)isFromMe;

- (void)layoutMessageStatusViews:(BOOL)isFromMe;

+ (CGFloat)heightForModel:(LLMessageModel *)model;

- (CGRect)contentFrameInWindow;

#pragma mark - 传递给子类的手势事件

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)aPoint;

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint;

- (void)cancelContentTouch;

- (void)contentTouchBeganInView:(UIView *)aView;

- (void)contentTouchCancelled;

- (void)contentLongPressedBeganInView:(UIView *)aView;

- (void)contentLongPressedEndedInView:(UIView *)aView;

- (void)statusButtonDidTapped;

- (void)avatarImageDidTapped;

- (void)selectControlDidTapped;

- (void)contentEventTappedInView:(UIView *)aView;

#pragma mark - 弹出菜单

- (void)showMenuControllerInRect:(CGRect)rect inView:(UIView *)view;

- (void)copyAction:(id)sender;

- (void)transforAction:(id)sender;

- (void)favoriteAction:(id)sender;

- (void)translateAction:(id)sender;

- (void)deleteAction:(id)sender;

- (void)moreAction:(id)sender;

- (void)addToEmojiAction:(id)sender;

- (void)forwardAction:(id)sender;

- (void)showAlbumAction:(id)sender;

- (void)playAction:(id)sender;

- (void)translateToWordsAction:(id)sender;


#pragma mark - 其他

+ (UIImage *)bubbleImageForModel:(LLMessageModel *)model;

+ (void)setCellEditing:(BOOL)isCellEditing;

@end
