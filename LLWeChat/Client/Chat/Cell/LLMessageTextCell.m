//
//  LLMessageTextCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageTextCell.h"
#import "LLUtils.h"
#import "LLConfig.h"
#import "UIKit+LLExt.h"
#import "LLSimpleTextLabel.h"
#import "LLUserProfile.h"


//Label的约束
#define LABEL_BUBBLE_LEFT 12
#define LABEL_BUBBLE_RIGHT 12
#define LABEL_BUBBLE_TOP 14
#define LABEL_BUBBLE_BOTTOM 12

#define CONTENT_MIN_WIDTH  53
#define CONTENT_MIN_HEIGHT 41

static CGFloat preferredMaxTextWidth;

@interface LLMessageTextCell ()

@property (nonatomic) LLSimpleTextLabel *contentLabel;

@end



@implementation LLMessageTextCell {
    UITapGestureRecognizer *doubleTap;
}

+ (void)initialize {
    if (self == [LLMessageTextCell class]) {
        preferredMaxTextWidth = SCREEN_WIDTH * CHAT_BUBBLE_MAX_WIDTH_FACTOR;
    }
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLabel = [[LLSimpleTextLabel alloc] init];
        self.contentLabel.scrollEnabled = NO;
        self.contentLabel.scrollsToTop = NO;
        self.contentLabel.editable = NO;
        self.contentLabel.selectable = NO;
        self.contentLabel.textContainerInset = UIEdgeInsetsZero;
        self.contentLabel.textContainer.lineFragmentPadding = 0;
        self.contentLabel.font = [self.class font];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        WEAK_SELF;
        self.contentLabel.longPressAction = ^(LLLabelRichTextData *data,UIGestureRecognizerState state) {
            weakSelf.bubbleImage.highlighted = NO;
            if (!data)return;
            if (data.type == kLLLabelRichTextTypeURL) {
                if (state == UIGestureRecognizerStateBegan) {
                    [weakSelf.delegate textLinkDidLongPressed:data.url userinfo:weakSelf];
                }
            }else {
                if (state == UIGestureRecognizerStateBegan) {
                    [weakSelf contentLongPressedBeganInView:nil];
                    [weakSelf.contentLabel swallowTouch];
                }else if (state == UIGestureRecognizerStateEnded) {
                    
                }
            }
  
        };
        self.contentLabel.tapAction = ^(LLLabelRichTextData *data) {
            weakSelf.bubbleImage.highlighted = NO;
            if (!data)return;
            if (data.type == kLLLabelRichTextTypeURL) {
                [weakSelf.delegate textLinkDidTapped:data.url userinfo:weakSelf];
            }else if (data.type == kLLLabelRichTextTypePhoneNumber) {
                [weakSelf.delegate textPhoneNumberDidTapped:data.phoneNumber userinfo:weakSelf];
            }
        };
        
        [self.contentView addSubview:self.contentLabel];
        
        doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentDoubleTapped:)];
        doubleTap.delegate = self;
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [self.contentView addGestureRecognizer:doubleTap];
//        [tap requireGestureRecognizerToFail:doubleTap];
        
    }
    
    return self;
}

- (void)setMessageModel:(LLMessageModel *)messageModel {
    BOOL needUpdateText = [messageModel checkNeedsUpdateForReuse];
    [super setMessageModel:messageModel];
    
    if (needUpdateText) {
        self.contentLabel.attributedText = messageModel.attributedText;
    }
}


- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGSize textSize = [self.class sizeForLabel:self.messageModel.attributedText];
    CGSize size = textSize;
    size.width += LABEL_BUBBLE_LEFT + LABEL_BUBBLE_RIGHT;
    size.height += LABEL_BUBBLE_TOP + LABEL_BUBBLE_BOTTOM;
    if (size.width < CONTENT_MIN_WIDTH) {
        size.width = CONTENT_MIN_WIDTH;
    }else {
        size.width = ceil(size.width);
    }
    
    if (size.height < CONTENT_MIN_HEIGHT) {
        size.height = CONTENT_MIN_HEIGHT;
    }else {
        size.height = ceil(size.height);
    }

    if (isFromMe) {
        CGRect frame = CGRectMake(0,
                  CONTENT_SUPER_TOP - BUBBLE_TOP_BLANK,
                  size.width + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK,
                  size.height + BUBBLE_TOP_BLANK + BUBBLE_BOTTOM_BLANK);
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CGRectGetWidth(frame) - CONTENT_AVATAR_MARGIN;
        self.bubbleImage.frame = frame;

        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.bubbleImage.frame) + LABEL_BUBBLE_RIGHT + BUBBLE_LEFT_BLANK,
                    CGRectGetMinY(self.bubbleImage.frame) + LABEL_BUBBLE_TOP + BUBBLE_TOP_BLANK,
                                             textSize.width, textSize.height);

    }else {
        self.bubbleImage.frame = CGRectMake(CONTENT_AVATAR_MARGIN + CGRectGetMaxX(self.avatarImage.frame),
                    CONTENT_SUPER_TOP - BUBBLE_TOP_BLANK, size.width + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK, size.height +
                    BUBBLE_TOP_BLANK + BUBBLE_BOTTOM_BLANK);
        
        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.bubbleImage.frame) + LABEL_BUBBLE_LEFT + BUBBLE_LEFT_BLANK,
                    CGRectGetMinY(self.bubbleImage.frame) + LABEL_BUBBLE_TOP + BUBBLE_TOP_BLANK,
                                             textSize.width, textSize.height);
    }
    
}

+ (CGSize)sizeForLabel:(NSAttributedString *)text {
    CGRect frame = [text boundingRectWithSize:CGSizeMake(preferredMaxTextWidth, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    return frame.size;
}

+ (UIFont *)font {
    static UIFont *_font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _font = [UIFont systemFontOfSize:LL_MESSAGE_FONT_SIZE];
    });
    return _font;
}


+ (CGFloat)heightForModel:(LLMessageModel *)model {
    CGSize size = [self sizeForLabel:model.attributedText];
    
    CGFloat bubbleHeight = size.height + LABEL_BUBBLE_TOP + LABEL_BUBBLE_BOTTOM;
    if (bubbleHeight < CONTENT_MIN_HEIGHT)
        bubbleHeight = CONTENT_MIN_HEIGHT;
    else
        bubbleHeight = ceil(bubbleHeight);
    
    return bubbleHeight + CONTENT_SUPER_BOTTOM;
}

#pragma mark - 手势

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == doubleTap) {
        if ([LLUserProfile myUserProfile].userOptions.doubleTapToShowTextMessage) {
            CGPoint bubblePoint = [touch locationInView:self.bubbleImage];
            if (CGRectContainsPoint(self.bubbleImage.bounds, bubblePoint) && ![self.contentLabel shouldReceiveTouchAtPoint:[touch locationInView:self.contentLabel]]) {
                return YES;
            }
        }
        return NO;
    }

    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}


- (void)contentDoubleTapped:(UITapGestureRecognizer *)tap {
    [self.delegate textCellDidDoubleTapped:self];
}

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.bubbleImage];
    
    if (CGRectContainsPoint(self.bubbleImage.bounds, bubblePoint) && ![self.contentLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.contentLabel]]) {
        return self.bubbleImage;
    }
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    self.bubbleImage.highlighted = YES;
    [self showMenuControllerInRect:self.bubbleImage.bounds inView:self.bubbleImage];
    
}

- (void)contentTouchCancelled {
    self.bubbleImage.highlighted = NO;
}

- (void)willBeginScrolling {
    self.bubbleImage.highlighted = NO;
    [self.contentLabel clearLinkBackground];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if (LLMessageCell_isEditing) {
        if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
            return self.contentView;
        }
    }else {
        if ([self.contentLabel pointInside:[self convertPoint:point toView:self.contentLabel] withEvent:event]) {
            return self.contentLabel;
        }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
            return self.contentView;
        }
    }

    return nil;
}

#pragma mark - 弹出菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"复制", @"转发", @"收藏", @"翻译", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"copyAction:", @"transforAction:", @"favoriteAction:", @"translateAction:",@"deleteAction:", @"moreAction:"];
}

- (void)copyAction:(id)sender {
    [LLUtils copyToPasteboard:self.messageModel.text];
}

- (void)transforAction:(id)sender {
    
}

- (void)favoriteAction:(id)sender {
    
}

- (void)translateAction:(id)sender {
    
}




@end
