//
//  LLBaseChatViewCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageBaseCell.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLColors.h"
#import "LLChatTextView.h"

#define MENU_FRAME_HEIGHT 50

#define TOUCH_DELAYED_TIME 0.2

UIImage *ReceiverTextNodeBkg;
UIImage *ReceiverTextNodeBkgHL;
UIImage *SenderTextNodeBkg;
UIImage *SenderTextNodeBkgHL;

UIImage *ReceiverImageNodeBorder;
UIImage *ReceiverImageNodeMask;
UIImage *SenderImageNodeBorder;
UIImage *SenderImageNodeMask;

BOOL LLMessageCell_isEditing = NO;

@interface LLMessageBaseCell () <UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableArray <UIMenuItem *> *menuItems;

@end


@implementation LLMessageBaseCell {
    UIView *tapView;
    UIView *longPressedView;
}

@synthesize statusButton = _statusButton;
@synthesize indicatorView = _indicatorView;
@synthesize messageModel = _messageModel;
@synthesize selectControl = _selectControl;

+ (void)initialize {
    if (!ReceiverTextNodeBkg) {
        ReceiverTextNodeBkg = [[UIImage imageNamed:@"ReceiverTextNodeBkg"] resizableImage];
        ReceiverTextNodeBkgHL = [[UIImage imageNamed:@"ReceiverTextNodeBkgHL"] resizableImage];
        SenderTextNodeBkg = [[UIImage imageNamed:@"SenderTextNodeBkg"] resizableImage];
        SenderTextNodeBkgHL = [[UIImage imageNamed:@"SenderTextNodeBkgHL"] resizableImage];
        
        ReceiverImageNodeBorder = [[UIImage imageNamed:@"ReceiverImageNodeBorder"] resizableImage];
        ReceiverImageNodeMask = [[UIImage imageNamed:@"ReceiverImageNodeMask"] resizableImage];
        SenderImageNodeBorder = [[UIImage imageNamed:@"SenderImageNodeBorder"] resizableImage];
        SenderImageNodeMask = [[UIImage imageNamed:@"SenderImageNodeMask"] resizableImage];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = kLLBackgroundColor_lightGray;
        
        self.avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AVATAR_WIDTH, AVATAR_HEIGHT)];
        self.avatarImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.avatarImage];
        
        self.bubbleImage = [[UIImageView alloc] init];
        self.bubbleImage.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.bubbleImage];

        [self setupGestureRecognizer];

    }
    
    return self;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_indicatorView];
        _indicatorView.hidden = YES;
        
        [self layoutMessageStatusViews:self.messageModel.isFromMe];
    }

    return _indicatorView;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setImage:[UIImage imageNamed:@"MessageSendFail"] forState:UIControlStateNormal];
        _statusButton.contentMode = UIViewContentModeScaleAspectFit;
        _statusButton.frame = CGRectMake(0, 0, 24, 24);
        [self.contentView addSubview:_statusButton];
        _statusButton.hidden = YES;
        
        [self layoutMessageStatusViews:self.messageModel.isFromMe];
    }

    return _statusButton;
}

- (void)prepareForUse:(BOOL)isFromMe {
    NSString *iconName = isFromMe ? @"icon_avatar" : @"user";
    self.avatarImage.image = [UIImage imageNamed:iconName];

    self.bubbleImage.image = isFromMe ? SenderTextNodeBkg : ReceiverTextNodeBkg;
    self.bubbleImage.highlightedImage = isFromMe ? SenderTextNodeBkgHL : ReceiverTextNodeBkgHL;
    
    _isCellEditing = LLMessageCell_isEditing;
    if (_isCellEditing) {
        self.selectControl.frame = CGRectMake(3, (AVATAR_HEIGHT - EDIT_CONTROL_SIZE)/2, EDIT_CONTROL_SIZE, EDIT_CONTROL_SIZE);
    }

    if (isFromMe) {
        self.avatarImage.frame = CGRectMake(SCREEN_WIDTH - CGRectGetWidth(self.avatarImage.frame) - AVATAR_SUPER_LEFT,
                AVATAR_SUPER_TOP,
                AVATAR_WIDTH, AVATAR_HEIGHT);

    }else {
        CGFloat _x = _isCellEditing ? CGRectGetMaxX(self.selectControl.frame) + 3 : AVATAR_SUPER_LEFT;
        self.avatarImage.frame = CGRectMake(_x, AVATAR_SUPER_TOP, AVATAR_WIDTH, AVATAR_HEIGHT);
    }
}

- (void)setIsCellSelected:(BOOL)isCellSelected {
    _isCellSelected = isCellSelected;
    self.messageModel.isSelected = isCellSelected;
    self.selectControl.image = [UIImage imageNamed:isCellSelected ? @"CellBlueSelected": @"CellNotSelected"];
}

- (UIImageView *)selectControl {
    if (!_selectControl) {
        _selectControl = [[UIImageView alloc] initWithFrame:CGRectMake(-EDIT_CONTROL_SIZE, (AVATAR_HEIGHT - EDIT_CONTROL_SIZE)/2, EDIT_CONTROL_SIZE, EDIT_CONTROL_SIZE)];
        _selectControl.contentMode = UIViewContentModeCenter;
        self.isCellSelected = self.isCellSelected;
        [self.contentView addSubview:_selectControl];
    }
    
    return _selectControl;
}

- (void)setCellEditingAnimated:(BOOL)animated {
    if (_isCellEditing == LLMessageCell_isEditing)
        return;
    _isCellEditing = LLMessageCell_isEditing;
    
    [UIView animateWithDuration:animated ? DEFAULT_DURATION : 0
                     animations:^{
    if (_isCellEditing) {
        self.selectControl.frame = CGRectMake(3, (AVATAR_HEIGHT - EDIT_CONTROL_SIZE)/2, EDIT_CONTROL_SIZE, EDIT_CONTROL_SIZE);
                                 
        if (!self.messageModel.isFromMe) {
            self.avatarImage.frame = CGRectMake(CGRectGetMaxX(self.selectControl.frame) + 3,AVATAR_SUPER_TOP, AVATAR_WIDTH, AVATAR_HEIGHT);
            [self layoutMessageContentViews:NO];
            [self layoutMessageStatusViews:NO];
        }
     }else {
         _selectControl.frame = CGRectMake(-EDIT_CONTROL_SIZE, (AVATAR_HEIGHT - EDIT_CONTROL_SIZE)/2, EDIT_CONTROL_SIZE, EDIT_CONTROL_SIZE);
         
         if (!self.messageModel.isFromMe) {
             self.avatarImage.frame = CGRectMake(AVATAR_SUPER_LEFT,AVATAR_SUPER_TOP, AVATAR_WIDTH, AVATAR_HEIGHT);
             [self layoutMessageContentViews:NO];
             [self layoutMessageStatusViews:NO];
         }
     }
                     }];
}

- (void)willDisplayCell {
    
}

- (void)didEndDisplayingCell {
    
}

- (void)willBeginScrolling {
    [self contentTouchCancelled];
}

- (void)didEndScrolling {

}

- (void)setMessageModel:(LLMessageModel *)messageModel {
    _messageModel = messageModel;
    self.isCellSelected = messageModel.isSelected;
    
    if ([messageModel checkNeedsUpdateForReuse]) {
        [self layoutMessageContentViews:messageModel.isFromMe];
        [self layoutMessageStatusViews:messageModel.isFromMe];
    }

    if ([messageModel checkNeedsUpdateThumbnail]) {
        [self updateMessageThumbnail];
    }
    
    if (self.messageModel.isFromMe) {
        if ([messageModel checkNeedsUpdateUploadStatus]){
            [self updateMessageUploadStatus];
        }
    }else {
        if ([messageModel checkNeedsUpdateDownloadStatus]) {
            [self updateMessageDownloadStatus];
        }
    }
    
    [messageModel clearNeedsUpdateForReuse];
}

#pragma mark - 布局 -

+ (void)setCellEditing:(BOOL)_isCellEditing {
    LLMessageCell_isEditing = _isCellEditing;
}

- (void)updateMessageUploadStatus {
    switch (self.messageModel.messageStatus) {
        case kLLMessageStatusDelivering:
        case kLLMessageStatusWaiting:
            HIDE_STATUS_BUTTON;
            SHOW_INDICATOR_VIEW;
            break;
        case kLLMessageStatusSuccessed:
            HIDE_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;
        case kLLMessageStatusFailed:
        case kLLMessageStatusPending:
            SHOW_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;
        default:
            break;
    }
   
    [_messageModel clearNeedsUpdateUploadStatus];
    
}

- (void)updateMessageDownloadStatus {
    [_messageModel clearNeedsUpdateDownloadStatus];
}

- (void)updateMessageThumbnail {
    [_messageModel clearNeedsUpdateThumbnail];
}

- (void)layoutMessageContentViews:(BOOL)isFromMe {

}

- (void)layoutMessageStatusViews:(BOOL)isFromMe {
    if (isFromMe) {
        _indicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleImage.frame) - CGRectGetWidth(_indicatorView.frame)/2 - ACTIVITY_VIEW_X_OFFSET + BUBBLE_LEFT_BLANK, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
            
        _statusButton.center = CGPointMake(CGRectGetMinX(self.bubbleImage.frame) - CGRectGetWidth(_statusButton.frame)/2 - ACTIVITY_VIEW_X_OFFSET + BUBBLE_LEFT_BLANK, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
    }
}


+ (UIImage *)bubbleImageForModel:(LLMessageModel *)model {
    return model.isFromMe ? SenderTextNodeBkg : ReceiverTextNodeBkg;
}

+ (CGFloat)heightForModel:(LLMessageModel *)model {
    return 68;
}

- (CGRect)contentFrameInWindow {
    return CGRectZero;
}

#pragma mark - 手势

- (void)setupGestureRecognizer {
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:tap];
    
    longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentLongPressed:)];
    longPressGR.delegate = self;
    longPressGR.minimumPressDuration = 0.6;
    longPressGR.allowableMovement = 1000;
    [self.contentView addGestureRecognizer:longPressGR];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return NO;
    BOOL isTapGestureRecognizer = [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
    
    //在编辑模式下点击Cell任意地方都相当于点击了Select Controll
    if (LLMessageCell_isEditing) {
        tapView = _selectControl;
        longPressedView = nil;
        return isTapGestureRecognizer ? YES : NO;
    }

    if (_statusButton && !_statusButton.hidden) {
        CGPoint point = [touch locationInView:_statusButton];
        if ([_statusButton pointInside:point withEvent:nil]) {
            tapView = _statusButton;
            return isTapGestureRecognizer ? YES : NO;
        }
    }

    BOOL isMenuVisible = [UIMenuController sharedMenuController].menuVisible;
    if (isMenuVisible && isTapGestureRecognizer) {
        [self performSelectorOnMainThread:@selector(hideMenuController) withObject:nil waitUntilDone:NO];
    //   [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    CGPoint point = [touch locationInView:self.avatarImage];
    if ([self.avatarImage pointInside:point withEvent:nil]) {
        tapView = self.avatarImage;
        return isTapGestureRecognizer ? YES : NO;
    }
    
    UIView *hitTestView;
    point = [touch locationInView:self.contentView];
    if (isTapGestureRecognizer) {
        tapView = [self hitTestForTapGestureRecognizer:point];
        hitTestView = tapView;
    }else {
        longPressedView = [self hitTestForlongPressedGestureRecognizer:point];
        hitTestView = longPressedView;
    }

    if (isTapGestureRecognizer) {
        if (hitTestView) {
            WEAK_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOUCH_DELAYED_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf delayedCallback:touch];
            });
            return YES;
        }else {
            return isMenuVisible;
        }
    }else {
        return hitTestView != nil;
    }
    
}


- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    return self.contentView;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return self.contentView;
}

- (void)delayedCallback:(UITouch *)touch {
    if (!touch || touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled || ![touch.gestureRecognizers containsObject:tap]) {
        return;
    }

    [self contentTouchBeganInView:tapView];
}

- (void)contentTapped:(UITapGestureRecognizer *)tap {
    if (!self.messageModel || !tapView)
        return;

    if (tapView == self.avatarImage) {
        [self avatarImageDidTapped];
    }else if (tapView == _statusButton) {
        [self statusButtonDidTapped];
    }else if (tapView == _selectControl) {
        [self selectControlDidTapped];
    }else {
        [self contentEventTappedInView:tapView];
    }
    
    tapView = nil;
    
}

- (void)statusButtonDidTapped {
    if (self.messageModel.fromMe) {
        SAFE_SEND_MESSAGE(self.delegate, resendMessage:) {
            [LLUtils showConfirmAlertWithTitle:nil
                                   message:@"重发该消息？"
                                  yesTitle:@"重发"
                                 yesAction:^{
                                    [self.delegate resendMessage:self.messageModel];
                                 }
                               cancelTitle:@"取消"
                              cancelAction:nil];
        }
    }else {
        SAFE_SEND_MESSAGE(self.delegate, redownloadMessage:) {
            [self.delegate redownloadMessage:self.messageModel];
        }
    }
}

- (void)avatarImageDidTapped {
    SAFE_SEND_MESSAGE(self.delegate, avatarImageDidTapped:) {
        [self.delegate avatarImageDidTapped:self];
    }
}


- (void)selectControlDidTapped {
    if (LLMessageCell_isEditing) {
        self.isCellSelected = !self.isCellSelected;
        SAFE_SEND_MESSAGE(self.delegate, selectControllDidTapped:selected:) {
            [self.delegate selectControllDidTapped:self.messageModel selected:_isCellSelected];
        }
    }
}

- (void)contentEventTappedInView:(UIView *)view {
    [self.delegate cellDidTapped:self];
}

- (void)contentLongPressed:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            [self contentLongPressedBeganInView:longPressedView];
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self contentLongPressedEndedInView:longPressedView];
            longPressedView = nil;
            break;
        default:
            break;
    }
    
}

- (void)cancelContentTouch {
    [self contentTouchCancelled];
}

- (void)contentTouchBeganInView:(UIView *)view {
    
}

- (void)contentTouchCancelled {
    
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    
}

- (void)contentLongPressedEndedInView:(UIView *)view {
    
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
        return self.contentView;
    }
    
    return nil;
}

#pragma mark - 弹出菜单

- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    for (NSInteger i = 0; i < self.menuItemActionNames.count; i++) {
        if (action == NSSelectorFromString(self.menuItemActionNames[i])) {
            return YES;
        }
    }
    
    return NO;//隐藏系统默认的菜单项
}

- (void)hideMenuController {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)showMenuControllerInRect:(CGRect)rect inView:(UIView *)view {
    UIResponder *firstResponder;
    SAFE_SEND_MESSAGE(self.delegate, currentFirstResponderIfNeedRetain) {
        firstResponder = [self.delegate currentFirstResponderIfNeedRetain];
    }
    
    LLChatTextView *textView;
    if ([firstResponder isKindOfClass:[LLChatTextView class]]) {
        textView = (LLChatTextView *)firstResponder;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (!self.menuItems) {
        self.menuItems = [NSMutableArray arrayWithCapacity:self.menuItemNames.count];
        
        for (NSInteger i =0; i < self.menuItemNames.count; i++) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:self.menuItemNames[i] action:NSSelectorFromString(self.menuItemActionNames[i])];
            [self.menuItems addObject:item];
        }
        
    }
    [menu setMenuItems:self.menuItems];
    [menu setTargetRect:rect inView:view];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    
    //设置当前Cell为FirstResponder
    if (!textView) {
        [self becomeFirstResponder];
    
    //保留TextView为FirstResponder，同时其负责Menu显示
    }else {
        textView.targetCell = self;
    }
    
    [menu setMenuVisible:YES animated:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHideCallback:) name:UIMenuControllerDidHideMenuNotification object:menu];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHideCallback:) name:UIMenuControllerWillHideMenuNotification object:menu];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidShowCallback:) name:UIMenuControllerDidShowMenuNotification object:menu];
    
}

- (void)menuWillHideCallback:(NSNotification *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
    SAFE_SEND_MESSAGE(self.delegate, willHideMenuForCell:) {
        [self.delegate willHideMenuForCell:self];
    }
}

- (void)menuDidHideCallback:(NSNotification *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [self cancelContentTouch];
    ((UIMenuController *)notify.object).menuItems = nil;
    SAFE_SEND_MESSAGE(self.delegate, didHideMenuForCell:) {
        [self.delegate didHideMenuForCell:self];
    }
}

- (void)menuDidShowCallback:(NSNotification *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidShowMenuNotification object:nil];
    
    SAFE_SEND_MESSAGE(self.delegate, didShowMenuForCell:) {
        [self.delegate didShowMenuForCell:self];
    }
}

- (void)deleteAction:(id)sender {
    [self.delegate deleteMenuItemDidTapped:self];
}

- (void)moreAction:(id)sender {
    [self.delegate moreMenuItemDidTapped:self];
}

- (void)copyAction:(id)sender {
    
}

- (void)transforAction:(id)sender {
    
}

- (void)favoriteAction:(id)sender {
    
}

- (void)translateAction:(id)sender {
    
}

- (void)addToEmojiAction:(id)sender {
    
}

- (void)forwardAction:(id)sender {
    
}

- (void)showAlbumAction:(id)sender {
    
}

- (void)playAction:(id)sender {
    
}

- (void)translateToWordsAction:(id)sender {
    
}


@end
