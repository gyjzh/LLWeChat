//
//  LLConversationListCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/20/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLConversationListCell.h"
#import "LLChatManager.h"
#import "LLMessageModel.h"
#import "LLUtils.h"


@interface LLConversationListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *messageStatusImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *latestMessageLabelConstraint;

@property (weak, nonatomic) IBOutlet UILabel *badgeNumLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badgeNumWidthConstraint;

@end


@implementation LLConversationListCell {
    UILabel *moreLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.badgeNumLabel.layer.cornerRadius = 9;
    self.badgeNumLabel.clipsToBounds = YES;
    
    moreLabel = [[UILabel alloc] init];
    moreLabel.backgroundColor = [UIColor clearColor];
    moreLabel.font = self.badgeNumLabel.font;
    moreLabel.text = @"...";
    moreLabel.textColor = self.badgeNumLabel.textColor;
    moreLabel.textAlignment = NSTextAlignmentCenter;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *originColor = self.badgeNumLabel.backgroundColor;
    
    [super setSelected:selected animated:animated];

    if (selected)
        self.badgeNumLabel.backgroundColor = originColor;

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *originColor = self.badgeNumLabel.backgroundColor;
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
        self.badgeNumLabel.backgroundColor = originColor;
}


- (void)updateConstraints {
    [super updateConstraints];
}

- (void)setConversationModel:(LLConversationModel *)conversationModel {
    _conversationModel = conversationModel;
    self.titleLabel.text = conversationModel.nickName;
    self.dateLabel.text = conversationModel.latestMessageTimeString;
    [self setUnreadNumber:conversationModel.unreadMessageNumber];
    
    LLMessageStatus status = [conversationModel latestMessageStatus];
    switch (status) {
        case kLLMessageStatusFailed:
            self.messageStatusImageView.hidden = NO;
            self.messageStatusImageView.image = [UIImage imageNamed:@"MessageSendFail"];
            self.latestMessageLabelConstraint.constant = 31;
            break;
        case kLLMessageStatusDelivering:
            self.messageStatusImageView.hidden = NO;
            self.messageStatusImageView.image = [UIImage imageNamed:@"MessageListSending"];
            self.latestMessageLabelConstraint.constant = 31;
            break;
        case kLLMessageStatusSuccessed:
        case kLLMessageStatusPending:
            self.messageStatusImageView.hidden = YES;
            self.latestMessageLabelConstraint.constant = 31 - 19 - 2;
            break;
        default:
            break;
    }
    
    if (conversationModel.draft.length == 0) {
        self.lastMessageLabel.text = conversationModel.latestMessage;
    }else {
        NSString *string = [NSString stringWithFormat:@"[草稿] %@", conversationModel.draft];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedString setAttributes:@{NSForegroundColorAttributeName: kLLTextColor_drarRed} range:NSMakeRange(0, 4)];
        self.lastMessageLabel.attributedText = attributedString;
    }
    
    self.avatarImageView.image = [UIImage imageNamed:@"user"];

}

- (void)setUnreadNumber:(NSInteger)unreadCount {
    [moreLabel removeFromSuperview];
    if (unreadCount == 0) {
        self.badgeNumLabel.text = nil;
        self.badgeNumLabel.hidden = YES;
    }else {
        if (unreadCount < 10) {
            self.badgeNumLabel.text = [NSString stringWithFormat:@"%ld", (long)unreadCount];
            self.badgeNumWidthConstraint.constant = 18;
        }else if(unreadCount < 100) {
            self.badgeNumLabel.text = [NSString stringWithFormat:@"%ld", (long)unreadCount];
            self.badgeNumWidthConstraint.constant = self.badgeNumLabel.intrinsicContentSize.width + 12;
        }else {
            self.badgeNumLabel.text = nil;
            self.badgeNumWidthConstraint.constant = moreLabel.intrinsicContentSize.width + 12;
            [self.contentView addSubview:moreLabel];

        }
 
        [self.badgeNumLabel layoutIfNeeded];
        if (moreLabel.superview) {
            CGRect frame = self.badgeNumLabel.frame;
            frame.origin.y -= 3.5;
            moreLabel.frame = frame;
        }
 
        self.badgeNumLabel.hidden = NO;
    }
}

#pragma mark - 标为已读、未读

- (void)markAllMessageAsRead {
    [self setUnreadNumber:0];

    [[LLChatManager sharedManager] markAllMessagesAsRead:self.conversationModel];
}

- (void)markMessageAsNotRead {
    NOT_SUPPORT_ALERT;

}


@end
