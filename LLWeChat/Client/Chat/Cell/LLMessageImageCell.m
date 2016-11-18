//
//  LLMessageImageCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/12/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageImageCell.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"

static UIImage *photoDownloadImage;

#define LABEL_HEIGHT 13

@interface LLMessageImageCell ()

@property (nonatomic) UILabel *label;
@property (nonatomic) UIImageView *borderView;

@property (nonatomic) UIImageView *thumbnailImageView;

@property (nonatomic) UIView *maskView;
@end

@implementation LLMessageImageCell

+ (void)initialize {
    if (self == [LLMessageImageCell class]) {
        photoDownloadImage = [[UIImage imageNamed:@"PhotoDownload"] resizeImageToSize:CGSizeMake(50, 40)];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] initWithImage:photoDownloadImage];
        self.thumbnailImageView.backgroundColor = [UIColor clearColor];
        self.thumbnailImageView.contentMode = UIViewContentModeCenter;
        self.thumbnailImageView.tintColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.chatImageView = [[UIImageView alloc] init];
        self.chatImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.chatImageView];
        
        [self.bubbleImage removeFromSuperview];
        self.chatImageView.layer.mask = self.bubbleImage.layer;
        self.chatImageView.layer.masksToBounds = YES;
        
        self.borderView = [[UIImageView alloc] init];
        self.borderView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.borderView];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, LABEL_HEIGHT)];
        _label.font = [UIFont fontWithName:FONT_FOR_NUMBER size:17];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        _label.text = @"0%";
        _label.hidden = YES;

    }
    
    return self;
}

- (void)prepareForUse:(BOOL)isFromMe {
    [super prepareForUse:isFromMe];

    self.bubbleImage.image = isFromMe ? SenderImageNodeMask : ReceiverImageNodeMask;
    self.bubbleImage.highlightedImage = nil;
    self.borderView.image = isFromMe ? SenderImageNodeBorder : ReceiverImageNodeBorder;
    
    if (isFromMe) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.chatImageView addSubview:_maskView];
    }

}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.contentView addSubview:_indicatorView];
        _indicatorView.hidden = YES;
        
        [self layoutMessageStatusViews:self.messageModel.isFromMe];
    }
    
    return _indicatorView;
}


#pragma mark - 布局 -

- (void)updateMessageThumbnail {
    self.chatImageView.image = self.messageModel.thumbnailImage;
    self.thumbnailImageView.hidden = self.messageModel.thumbnailImage != nil;
    if (!self.thumbnailImageView.hidden) {
        _label.hidden = YES;
        HIDE_INDICATOR_VIEW;
    }
    
    [_messageModel clearNeedsUpdateThumbnail];
}

- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGRect frame = CGRectZero;
    frame.size = self.messageModel.thumbnailImageSize;
    
    if (frame.size.width > IMAGE_MAX_SIZE)
        frame.size.width = IMAGE_MAX_SIZE;
    if (frame.size.height > IMAGE_MAX_SIZE)
        frame.size.height = IMAGE_MAX_SIZE;
    
    if (isFromMe) {
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CONTENT_AVATAR_MARGIN - frame.size.width;
        frame.origin.y = CONTENT_SUPER_TOP;
        self.chatImageView.frame = frame;
        
        _thumbnailImageView.center = self.chatImageView.center;
        frame = _thumbnailImageView.frame;
        frame.origin.x -= BUBBLE_MASK_ARROW / 2;
        _thumbnailImageView.frame = frame;
        
    }else {
        frame.origin.x = CGRectGetMaxX(self.avatarImage.frame) + CONTENT_AVATAR_MARGIN;
        frame.origin.y = CONTENT_SUPER_TOP;
        self.chatImageView.frame = frame;

        _thumbnailImageView.center = self.chatImageView.center;
        frame = _thumbnailImageView.frame;
        frame.origin.x += BUBBLE_MASK_ARROW / 2;
        _thumbnailImageView.frame = frame;
    }

    frame = self.chatImageView.frame;
    frame.origin.x = CGRectGetMinX(frame) - 1;
    frame.size.height += 2;
    frame.size.width += 1;
    self.borderView.frame = frame;
    
    self.bubbleImage.frame = self.chatImageView.bounds;
    
    if (isFromMe)
        _maskView.frame = self.chatImageView.bounds;
}

- (void)layoutMessageStatusViews:(BOOL)isFromMe  {
    if (isFromMe) {
        if (_indicatorView) {
            CGFloat totalHeight = CGRectGetHeight(_indicatorView.frame) + LABEL_HEIGHT + 4;
            CGFloat _y = (CGRectGetHeight(self.chatImageView.frame) - totalHeight) / 2 + 2;
            
            CGRect frame = _indicatorView.frame;
            frame.origin.y = _y;
            frame.origin.x = CGRectGetMidX(self.chatImageView.frame) - CGRectGetWidth(frame) / 2 - BUBBLE_MASK_ARROW / 2;
            _indicatorView.frame = frame;
            
            frame.origin.x = CGRectGetMinX(self.chatImageView.frame);
            frame.origin.y = CGRectGetMaxY(_indicatorView.frame) + 4;
            frame.size.width = CGRectGetWidth(self.chatImageView.frame) - BUBBLE_MASK_ARROW;
            frame.size.height = LABEL_HEIGHT;
            self.label.frame = frame;

        }
        
        _statusButton.center = CGPointMake(CGRectGetMinX(self.chatImageView.frame) - CGRectGetWidth(_statusButton.frame)/2 - ACTIVITY_VIEW_X_OFFSET, CGRectGetMidY(self.chatImageView.frame));

    }
}

+ (CGSize)thumbnailSize:(CGSize)size {
    CGSize _size = size;
    CGFloat scale = IMAGE_MAX_SIZE / size.height;
    CGFloat _width = ceil(size.width * scale);
    if (_width < IMAGE_MIN_SIZE) {
        scale = IMAGE_MIN_SIZE / size.width;
        _size.width = IMAGE_MIN_SIZE;
        _size.height = ceil(size.height * scale);
    }else if (_width > IMAGE_MAX_SIZE) {
        scale = IMAGE_MIN_SIZE / size.height;
        if (scale * size.width <= IMAGE_MAX_SIZE) {
            _size.width = IMAGE_MAX_SIZE;
            _size.height = ceil(size.height * (IMAGE_MAX_SIZE / size.width));
        }else {
            _size.height = IMAGE_MIN_SIZE;
            _size.width = ceil(scale * size.width);
        }
    }else {
        _size.width = _width;
        _size.height = IMAGE_MAX_SIZE;
    }

    return _size;
}

+ (CGFloat)heightForModel:(LLMessageModel *)model {
    if (model.thumbnailImageSize.height > IMAGE_MAX_SIZE)
        return IMAGE_MAX_SIZE + CONTENT_SUPER_BOTTOM;
    else
        return model.thumbnailImageSize.height + CONTENT_SUPER_BOTTOM;
}


#pragma mark - 上传 -

- (void)setUploadProgress:(NSInteger)uploadProgress {
    self.label.text = [NSString stringWithFormat:@"%ld%%", (long)uploadProgress];
    if (uploadProgress >= 100) {
        WEAK_SELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf uploadResult:YES];
        });
    }
}

- (void)uploadResult:(BOOL)successed {
    self.label.hidden = YES;
    self.label.text = @"0%";
    if (successed) {
        HIDE_STATUS_BUTTON;
    }else {
        SHOW_STATUS_BUTTON;
    }
    HIDE_INDICATOR_VIEW;
    
    self.maskView.hidden = YES;
    self.chatImageView.alpha = 1;
}

- (void)updateMessageUploadStatus {
    switch (self.messageModel.messageStatus) {
        case kLLMessageStatusDelivering:
        case kLLMessageStatusWaiting:
            HIDE_STATUS_BUTTON;
            SHOW_INDICATOR_VIEW;
            self.label.hidden = NO;
            self.maskView.hidden = NO;
            self.chatImageView.alpha = 0.6;
            [self setUploadProgress:self.messageModel.fileUploadProgress];
            break;
            
        case kLLMessageStatusSuccessed:
            [self uploadResult:YES];
            break;
            
        case kLLMessageStatusFailed:
        case kLLMessageStatusPending:
            [self uploadResult:NO];
            break;
        default:
            break;
    }

    [_messageModel clearNeedsUpdateUploadStatus];
}

#pragma mark - 下载 -

- (void)updateMessageDownloadStatus {
    if (self.messageModel.fileDownloadProgress == 100) {
        [self updateMessageThumbnail];
    }
    
    [_messageModel clearNeedsUpdateDownloadStatus];
}


#pragma mark - 手势

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint pointInView = [self.contentView convertPoint:point toView:self.chatImageView];
    if ([self.chatImageView pointInside:pointInView withEvent:nil]) {
        return self.chatImageView;
    }
    
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)contentLongPressedBeganInView:(UIView *)inView {
    [self showMenuControllerInRect:self.chatImageView.bounds inView:self.chatImageView];
    UIView *view = [[UIView alloc] initWithFrame:self.chatImageView.bounds];
    view.tag = 100;
    view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    [self.chatImageView addSubview:view];
}

- (void)contentTouchCancelled {
    UIView *view = [self.chatImageView viewWithTag:100];
    if (view)
        [view removeFromSuperview];
}


#pragma mark - 菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"复制", @"转发", @"收藏", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"copyAction:", @"transforAction:", @"favoriteAction:", @"deleteAction:", @"moreAction:"];
}

- (void)copyAction:(id)sender {
    
}


#pragma mark - 弹入弹出动画

- (CGRect)contentFrameInWindow {
    return [self.chatImageView convertRect:self.chatImageView.bounds toView:self.chatImageView.window];
}

+ (UIImage *)bubbleImageForModel:(LLMessageModel *)model {
    return model.isFromMe ? SenderImageNodeMask : ReceiverImageNodeMask;
}

- (void)willExitFullScreenShow {
    self.chatImageView.hidden = YES;
    self.borderView.hidden = YES;
}

- (void)didExitFullScreenShow {
    self.chatImageView.hidden = NO;
    self.borderView.hidden = NO;
}

#pragma mark - 内存 -

- (void)willDisplayCell {
    if (!self.chatImageView.image) {
        self.chatImageView.image = self.messageModel.thumbnailImage;
    }
}

- (void)didEndDisplayingCell {
    self.chatImageView.image = nil;
}

@end
