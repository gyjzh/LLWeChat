//
//  LLMessageVideoCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageVideoCell.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLSDK.h"
#import "LLVideoDownloadStatusHUD.h"

#define ACTION_TAG_RESEND 10
#define ACTION_TAG_CANCEL 11

#define MAX_CELL_SIZE 200

static UIImage *thunbmailDownloadImage;

@interface LLMessageVideoCell ()

@property (nonatomic) UILabel *sizeLabel;
@property (nonatomic) UILabel *durationLabel;
@property (nonatomic) LLVideoDownloadStatusHUD *messageVideoPlay;
@property (nonatomic) UIImageView *borderView;
@property (nonatomic) UIImageView *thumbnailImageView;

@end

@implementation LLMessageVideoCell

+ (void)initialize {
    if (self == [LLMessageVideoCell class]) {
        thunbmailDownloadImage = [[[UIImage imageNamed:@"fts_search_moment_video"] resizeImageToSize:CGSizeMake(50, 40)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] initWithImage:thunbmailDownloadImage];
        [self.thumbnailImageView sizeToFit];
        self.thumbnailImageView.backgroundColor = [UIColor clearColor];
        self.thumbnailImageView.contentMode = UIViewContentModeCenter;
        self.thumbnailImageView.tintColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.videoImageView = [[UIImageView alloc] init];
        self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoImageView.tintColor = [UIColor whiteColor];
        self.videoImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self.contentView addSubview:self.videoImageView];
        
        [self.bubbleImage removeFromSuperview];
        self.videoImageView.layer.mask = self.bubbleImage.layer;
        self.videoImageView.layer.masksToBounds = YES;
        
        self.borderView = [[UIImageView alloc] init];
        self.borderView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.borderView];
        
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.font = [UIFont systemFontOfSize:10];
        _sizeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_sizeLabel];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.font = [UIFont systemFontOfSize:10];
        _durationLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_durationLabel];
        
        _messageVideoPlay = [[LLVideoDownloadStatusHUD alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _messageVideoPlay.progress = 0;
        _messageVideoPlay.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_messageVideoPlay];

    }
    
    return self;
}

- (void)prepareForUse:(BOOL)isFromMe {
    [super prepareForUse:isFromMe];

    self.bubbleImage.image = isFromMe ? SenderImageNodeMask : ReceiverImageNodeMask;
    self.bubbleImage.highlightedImage = nil;

    self.borderView.image = isFromMe ? SenderImageNodeBorder : ReceiverImageNodeBorder;
}


- (void)setMessageModel:(LLMessageModel *)messageModel {
    if ([messageModel checkNeedsUpdateForReuse]) {
        _sizeLabel.text = [self.class getFileSizeString:messageModel.fileSize];
        _durationLabel.text = [self.class getDurationString:round(messageModel.mediaDuration)];
    }
    
    [super setMessageModel:messageModel];
   
}

- (void)updateMessageThumbnail {
    _videoImageView.image = self.messageModel.thumbnailImage;
    self.thumbnailImageView.hidden = self.messageModel.thumbnailImage != nil;
    self.messageVideoPlay.hidden = !self.thumbnailImageView.hidden;
    
    [_messageModel clearNeedsUpdateThumbnail];
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusButton.contentMode = UIViewContentModeScaleAspectFit;
        [_statusButton setImage:[UIImage imageNamed:@"MessageVideoDownloadBtn"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"MessageVideoDownloadBtnHL"] forState:UIControlStateHighlighted];
        _statusButton.tag = ACTION_TAG_CANCEL;
        _statusButton.frame = CGRectMake(0, 0, 24, 24);
        _statusButton.hidden = YES;
        [self.contentView addSubview:_statusButton];
        
        [self layoutMessageStatusViews:self.messageModel.isFromMe];
    }
    
    return _statusButton;
}

- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGRect frame = CGRectZero;
    frame.size = self.messageModel.thumbnailImageSize;
    
    if (isFromMe) {
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CONTENT_AVATAR_MARGIN - frame.size.width;
        frame.origin.y = CONTENT_SUPER_TOP;
        self.videoImageView.frame = frame;
        
        frame.size = _sizeLabel.intrinsicContentSize;
        frame.origin.x = 10 + CGRectGetMinX(self.videoImageView.frame);
        frame.origin.y = CGRectGetMaxY(self.videoImageView.frame) - 15;
        _sizeLabel.frame = frame;
        
        frame.size = _durationLabel.intrinsicContentSize;
        frame.origin.x = CGRectGetMaxX(self.videoImageView.frame) - 5 - BUBBLE_MASK_ARROW - CGRectGetWidth(frame);
        frame.origin.y = CGRectGetMinY(_sizeLabel.frame);
        _durationLabel.frame = frame;
        
        _messageVideoPlay.center = self.videoImageView.center;
        frame = _messageVideoPlay.frame;
        frame.origin.x -= BUBBLE_MASK_ARROW/2;
        _messageVideoPlay.frame = frame;
        
    }else {
        frame.origin.x = CGRectGetMaxX(self.avatarImage.frame) + CONTENT_AVATAR_MARGIN;
        frame.origin.y = CONTENT_SUPER_TOP;
        self.videoImageView.frame = frame;
        
        frame.size = _sizeLabel.intrinsicContentSize;
        frame.origin.x = 10 + CGRectGetMinX(self.videoImageView.frame) + BUBBLE_MASK_ARROW;
        frame.origin.y = CGRectGetMaxY(self.videoImageView.frame) - 15;
        _sizeLabel.frame = frame;
        
        frame.size = _durationLabel.intrinsicContentSize;
        frame.origin.x = CGRectGetMaxX(self.videoImageView.frame) - 5 - CGRectGetWidth(frame);
        frame.origin.y = CGRectGetMinY(_sizeLabel.frame);
        _durationLabel.frame = frame;
        
        _messageVideoPlay.center = self.videoImageView.center;
        frame = _messageVideoPlay.frame;
        frame.origin.x += BUBBLE_MASK_ARROW/2;
        _messageVideoPlay.frame = frame;
    }
    
    frame = self.videoImageView.frame;
    frame.origin.x = CGRectGetMinX(frame) -1;
    frame.size.height += 2;
    frame.size.width += 1;
    self.borderView.frame = frame;
    
    self.thumbnailImageView.center = _messageVideoPlay.center;
    
    self.bubbleImage.frame = self.videoImageView.bounds;

}

- (void)layoutMessageStatusViews:(BOOL)isFromMe {
    if (isFromMe) {
        _statusButton.center = CGPointMake(CGRectGetMinX(self.videoImageView.frame) - CGRectGetWidth(_statusButton.frame) / 2 - ACTIVITY_VIEW_X_OFFSET, self.videoImageView.center.y);
    }else {
        _statusButton.center = CGPointMake(CGRectGetMaxX(self.videoImageView.frame) + CGRectGetWidth(_statusButton.frame) / 2 + ACTIVITY_VIEW_X_OFFSET, self.videoImageView.center.y);

    }
}

- (void)updateMessageUploadStatus {
    _thumbnailImageView.hidden = YES;
    
    switch (self.messageModel.messageStatus) {
        case kLLMessageStatusDelivering:
            if (self.messageModel.fileUploadProgress >= 100) {
                WEAK_SELF;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONG_SELF;
                    
                    strongSelf->_statusButton.hidden = YES;
                    weakSelf.messageVideoPlay.progress = 100;
                    weakSelf.messageVideoPlay.status = kLLVideoDownloadHUDStatusSuccess;
                });
            }else if (self.messageModel.fileUploadProgress <= 0){
                SHOW_STATUS_BUTTON;
                [self configStatusButton:YES];
                _messageVideoPlay.progress = 0;
                _messageVideoPlay.status = kLLVideoDownloadHUDStatusWaiting;
            }else {
                SHOW_STATUS_BUTTON;
                [self configStatusButton:YES];
                _messageVideoPlay.status = kLLVideoDownloadHUDStatusDownloading;
                _messageVideoPlay.progress = self.messageModel.fileUploadProgress;
            }
            
            break;
        case kLLMessageStatusSuccessed:
            HIDE_STATUS_BUTTON;
            _messageVideoPlay.progress = 100;
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusSuccess;
            break;
        case kLLMessageStatusFailed:
        case kLLMessageStatusPending:
            SHOW_STATUS_BUTTON;
            [self configStatusButton:NO];
            _messageVideoPlay.progress = 0;
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusPending;
            break;
        case kLLMessageStatusWaiting:
            SHOW_STATUS_BUTTON;
            [self configStatusButton:YES];
            _messageVideoPlay.progress = 0;
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusWaiting;
            break;
        default:
            break;
    }
    
    [_messageModel clearNeedsUpdateUploadStatus];
}

- (void)updateMessageDownloadStatus {
    switch (self.messageModel.messageDownloadStatus) {
        case kLLMessageDownloadStatusDownloading:
            if (self.messageModel.fileDownloadProgress >= 100) {
                WEAK_SELF;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONG_SELF;
                    
                    strongSelf->_statusButton.hidden = YES;
                    weakSelf.messageVideoPlay.status = kLLVideoDownloadHUDStatusSuccess;
                });
                
            }else if (self.messageModel.fileDownloadProgress <=0) {
                SHOW_STATUS_BUTTON;
                [self configStatusButton:YES];
                _messageVideoPlay.status = kLLVideoDownloadHUDStatusWaiting;
            }else {
                SHOW_STATUS_BUTTON;
                [self configStatusButton:YES];
                _messageVideoPlay.progress = self.messageModel.fileDownloadProgress;
                _messageVideoPlay.status = kLLVideoDownloadHUDStatusDownloading;
            }
            
            break;
        case kLLMessageDownloadStatusWaiting:
            SHOW_STATUS_BUTTON;
            [self configStatusButton:YES];
            _messageVideoPlay.progress = kLLVideoDownloadHUDStatusWaiting;
            break;
        case kLLMessageDownloadStatusPending:
            HIDE_STATUS_BUTTON;
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusPending;
            break;
        case kLLMessageDownloadStatusFailed: //视频下载出错不显示重新下载按钮
            HIDE_STATUS_BUTTON;
            [self configStatusButton:NO];
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusPending;
            break;
        case kLLMessageDownloadStatusSuccessed:
            HIDE_STATUS_BUTTON;
            _messageVideoPlay.progress = 100;
            _messageVideoPlay.status = kLLVideoDownloadHUDStatusSuccess;
            //视频下载完毕，需要更新缩略图
            if ([self.messageModel checkNeedsUpdateThumbnail]) {
                [self updateMessageThumbnail];
            }
            
            break;
        case kLLMessageDownloadStatusNone:
            break;
            
    }

    [_messageModel clearNeedsUpdateDownloadStatus];
}

- (void)configStatusButton:(BOOL)isDelivering {
    if (isDelivering) {
        if (_statusButton.tag != ACTION_TAG_CANCEL) {
            [_statusButton setImage:[UIImage imageNamed:@"MessageVideoDownloadBtn"] forState:UIControlStateNormal];
            [_statusButton setImage:[UIImage imageNamed:@"MessageVideoDownloadBtnHL"] forState:UIControlStateHighlighted];
            _statusButton.tag = ACTION_TAG_CANCEL;
        }
        
    }else {
        if (_statusButton.tag != ACTION_TAG_RESEND) {
            [_statusButton setImage:[UIImage imageNamed:@"MessageSendFail"] forState:UIControlStateNormal];
            [_statusButton setImage:[UIImage imageNamed:@"MessageSendFail"] forState:UIControlStateHighlighted];
            _statusButton.tag = ACTION_TAG_RESEND;
        }
        
    }
}

+ (CGFloat)heightForModel:(LLMessageModel *)model {
    CGSize ret = model.thumbnailImageSize;
    
    return ret.height + CONTENT_SUPER_BOTTOM;
}

+ (CGSize)thumbnailSize:(CGSize)size {
    CGSize ret;
    if (size.width <= size.height) {
        if (size.height > MAX_CELL_SIZE) {
            CGFloat scale = MAX_CELL_SIZE / size.height;
            ret.height = MAX_CELL_SIZE;
            ret.width = size.width * scale;
        }else {
            ret = size;
        }
    }else {
        if (size.width > MAX_CELL_SIZE) {
            CGFloat scale = MAX_CELL_SIZE / size.width;
            ret.width = MAX_CELL_SIZE;
            ret.height = size.height * scale;
        }else {
            ret = size;
        }
    }

    return ret;
}

+ (NSString *)getFileSizeString:(CGFloat)fileSize {
    NSString *ret = [NSString stringWithFormat:@"%.1fM", fileSize/1024/1024];
    return ret;
}

+ (NSString *)getDurationString:(NSInteger)duration {
    NSInteger minutes = duration / 60;
    NSInteger seconds = duration % 60;
    NSString *ret = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return ret;
}


#pragma mark - 弹出、弹入动画 -

- (CGRect)contentFrameInWindow {
    return [self.videoImageView convertRect:self.videoImageView.bounds toView:self.videoImageView.window];
}

+ (UIImage *)bubbleImageForModel:(LLMessageModel *)model {
    return model.isFromMe ? SenderImageNodeMask : ReceiverImageNodeMask;
}

- (void)willExitFullScreenShow {
    self.videoImageView.hidden = YES;
    self.borderView.hidden = YES;
    _sizeLabel.hidden = YES;
    _durationLabel.hidden = YES;
    _messageVideoPlay.hidden = YES;
}

- (void)didExitFullScreenShow {
    self.videoImageView.hidden = NO;
    self.borderView.hidden = NO;
    _sizeLabel.hidden = NO;
    _durationLabel.hidden = NO;
    _messageVideoPlay.hidden = NO;
}


#pragma mark - 手势

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint pointInView = [self.contentView convertPoint:point toView:self.videoImageView];
    if ([self.videoImageView pointInside:pointInView withEvent:nil]) {
        return self.videoImageView;
    }
    
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)statusButtonDidTapped {
    if (self.messageModel.isFromMe) {
        if (_statusButton.tag == ACTION_TAG_CANCEL){
            NSLog(@"暂不支持取消上传");
        }else {
            SAFE_SEND_MESSAGE(self.delegate, resendMessage:) {
                [self.delegate resendMessage:self.messageModel];
            }
        }
    }else {
        if (_statusButton.tag == ACTION_TAG_CANCEL) {
            NSLog(@"暂不支持取消下载");
        }else {
            SAFE_SEND_MESSAGE(self.delegate, redownloadMessage:) {
                [self.delegate redownloadMessage:self.messageModel];
            }
        }
    }
}


- (void)contentLongPressedBeganInView:(UIView *)view {
    [self showMenuControllerInRect:self.videoImageView.bounds inView:self.videoImageView];
}


#pragma mark - 菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"转发", @"收藏", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"transforAction:", @"favoriteAction:", @"deleteAction:", @"moreAction:"];
}

- (void)copyAction:(id)sender {
    
}


#pragma mark - 内存 -

- (void)willDisplayCell {
    if (!self.videoImageView.image) {
        self.videoImageView.image = self.messageModel.thumbnailImage;
    }
}

- (void)didEndDisplayingCell {
    self.videoImageView.image = nil;
}


@end



