//
//  LLMessageLocationCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/26/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageLocationCell.h"
#import "LLColors.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import <MAMapKit/MAMapKit.h>

#define LOCATION_TOP_HEIGHT_Big 58
#define LOCATION_TOP_HEIGHT_Small 40

#define LOCATION_BOTTOM_HEIGHT 92

#define Style_NeedReGeoCode 1
#define Style_EmptyAddress 2
#define Style_ReGeoCodeSuccess 3

@interface LLMessageLocationCell ()

@property (nonatomic) UILabel *topLabel;
@property (nonatomic) UILabel *bottomLabel;
@property (nonatomic) UIImageView *pinchView;
@property (nonatomic) UIImageView *mapImageView;
@property (nonatomic) UIView *locationView;

@property (nonatomic) UIActivityIndicatorView *reGeoIndicator;
//@property (nonatomic) UIActivityIndicatorView *downloadIndicator;
@property (nonatomic) UIImageView *borderView;

@property (nonatomic) NSInteger style;

@end

@implementation LLMessageLocationCell {
    NSInteger location_top_height;
    NSInteger location_image_width;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        location_image_width = ceil(THE_GOLDEN_RATIO * SCREEN_WIDTH);
        
        _locationView = [[UIView alloc] initWithFrame:CGRectMake(0, CONTENT_SUPER_TOP, location_image_width, LOCATION_TOP_HEIGHT_Big + LOCATION_BOTTOM_HEIGHT)];
        _locationView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_locationView];

        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, location_image_width - 24 - BUBBLE_MASK_ARROW, 20)];
        _topLabel.font = [UIFont systemFontOfSize:16];
        _topLabel.textColor = [UIColor blackColor];
        _topLabel.textAlignment = NSTextAlignmentLeft;
        [_locationView addSubview:_topLabel];

        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 32, location_image_width - 24 - BUBBLE_MASK_ARROW, 20)];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = kLLTextColor_lightGray_system;
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        [_locationView addSubview:_bottomLabel];

        _mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, LOCATION_TOP_HEIGHT_Big, location_image_width,
                LOCATION_BOTTOM_HEIGHT)];
        _mapImageView.backgroundColor = kLLBackgroundColor_gray;
        _mapImageView.contentMode = UIViewContentModeCenter;
        _mapImageView.clipsToBounds = YES;
        [_locationView addSubview:_mapImageView];
        
        [self.bubbleImage removeFromSuperview];
        _locationView.layer.mask = self.bubbleImage.layer;
        _locationView.layer.masksToBounds = YES;
        
        self.borderView = [[UIImageView alloc] init];
        self.borderView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.borderView];
        
        _pinchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_pin"]];
        _pinchView.frame = CGRectMake(0, 0, 18, 38);
        _pinchView.layer.anchorPoint = CGPointMake(0.5, 0.96);
        _pinchView.center = _mapImageView.center;
        [_locationView addSubview:_pinchView];

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
        if ([messageModel.address isEqualToString:LOCATION_EMPTY_ADDRESS]) {
            self.topLabel.text = messageModel.address;
            self.bottomLabel.text = nil;
            [self setStyle:Style_EmptyAddress];
        }else if ([messageModel.address isEqualToString:LOCATION_UNKNOWE_ADDRESS]) {
            self.topLabel.text = nil;
            self.bottomLabel.text = nil;
            [self setStyle:Style_NeedReGeoCode];
        }else {
            self.topLabel.text = messageModel.locationName;
            self.bottomLabel.text = messageModel.address;
            [self setStyle:Style_ReGeoCodeSuccess];
        }
    }

    [super setMessageModel:messageModel];
}

- (void)updateMessageUploadStatus {
    switch (self.messageModel.messageStatus) {
        case kLLMessageStatusDelivering:
        case kLLMessageStatusWaiting:
        case kLLMessageStatusPending:
            HIDE_STATUS_BUTTON;
            SHOW_INDICATOR_VIEW;
            break;
        case kLLMessageStatusSuccessed:
            HIDE_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;
        case kLLMessageStatusFailed:
            SHOW_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;
        default:
            break;
    }
    
    [_messageModel clearNeedsUpdateUploadStatus];
    
}

- (void)updateMessageDownloadStatus {
    switch (self.messageModel.messageDownloadStatus) {
        case kLLMessageDownloadStatusSuccessed:
        case kLLMessageDownloadStatusFailed:
            HIDE_INDICATOR_VIEW;
            [self updateMessageThumbnail];
            break;
        case kLLMessageDownloadStatusWaiting:
        case kLLMessageDownloadStatusDownloading:
            SHOW_INDICATOR_VIEW;
            self.mapImageView.image = nil;
            _pinchView.hidden = YES;
    
            break;
        default:
            break;
    }

    [_messageModel clearNeedsUpdateDownloadStatus];
}

- (void)updateMessageThumbnail {
    if (self.messageModel.defaultSnapshot || _messageModel.messageDownloadStatus == kLLMessageDownloadStatusFailed) {
        self.mapImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mapImageView.image = [UIImage imageNamed:@"map_located"];
        _pinchView.hidden = YES;
    }else {
        self.mapImageView.contentMode = UIViewContentModeCenter;
        self.mapImageView.image = self.messageModel.thumbnailImage;
        _pinchView.hidden = !self.mapImageView.image;
    }
    
    [_messageModel clearNeedsUpdateThumbnail];
    
}

- (void)setStyle:(NSInteger)style {
    _style = style;
    if (style == Style_NeedReGeoCode) {
        location_top_height = LOCATION_TOP_HEIGHT_Small;
        self.reGeoIndicator.hidden = NO;
        [self.reGeoIndicator startAnimating];
    }else if (style == Style_EmptyAddress) {
        location_top_height = LOCATION_TOP_HEIGHT_Small;
        if (_reGeoIndicator) {
            _reGeoIndicator.hidden = YES;
            [_reGeoIndicator stopAnimating];
        }
    }else if (style == Style_ReGeoCodeSuccess) {
        location_top_height = LOCATION_TOP_HEIGHT_Big;
        if (_reGeoIndicator) {
            _reGeoIndicator.hidden = YES;
            [_reGeoIndicator stopAnimating];
        }
    }
}

- (UIActivityIndicatorView *)reGeoIndicator {
    if (!_reGeoIndicator) {
        _reGeoIndicator = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_locationView addSubview:_reGeoIndicator];
        _reGeoIndicator.hidden = YES;
    }

    return _reGeoIndicator;
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

- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGRect frame;
    if (isFromMe) {
        frame = _locationView.frame;
        frame.size.height = location_top_height + LOCATION_BOTTOM_HEIGHT;
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CONTENT_AVATAR_MARGIN - CGRectGetWidth(frame);
        _locationView.frame = frame;
        
        frame = _mapImageView.frame;
        frame.origin.x = 0;
        frame.origin.y = location_top_height;
        _mapImageView.frame = frame;
        
    }else {
        frame = _locationView.frame;
        frame.size.height = location_top_height + LOCATION_BOTTOM_HEIGHT;
        frame.origin.x = CGRectGetMaxX(self.avatarImage.frame) + CONTENT_AVATAR_MARGIN;
        _locationView.frame = frame;
        
        frame = _mapImageView.frame;
        frame.origin.x = 0;
        frame.origin.y = location_top_height;
        _mapImageView.frame = frame;
    }

    frame = self.locationView.frame;
    frame.origin = CGPointZero;
    self.bubbleImage.frame = frame;
    
    frame = self.locationView.frame;
    frame.origin.x = CGRectGetMinX(frame) - 1;
    frame.size.height += 2;
    frame.size.width += 1;
    self.borderView.frame = frame;

    _pinchView.center = _mapImageView.center;
    
    if (_reGeoIndicator && !_reGeoIndicator.hidden) {
        _reGeoIndicator.center = CGPointMake(_mapImageView.center.x, CGRectGetMaxY(_mapImageView.frame) - 15);
    }
    
}

- (void)layoutMessageStatusViews:(BOOL)isFromMe {
    if (isFromMe) {
        _indicatorView.center = CGPointMake(_locationView.center.x, CGRectGetMaxY(_locationView.frame) - 53);

        _statusButton.center = CGPointMake(CGRectGetMinX(self.locationView.frame) - CGRectGetWidth(_statusButton.frame)/2 - ACTIVITY_VIEW_X_OFFSET, CGRectGetMidY(self.locationView.frame));

    }
}


+ (CGFloat)heightForModel:(LLMessageModel *)model {
    if ([model.address isEqualToString:LOCATION_EMPTY_ADDRESS]
        || [model.address isEqualToString:LOCATION_UNKNOWE_ADDRESS]) {
        return LOCATION_TOP_HEIGHT_Small + LOCATION_BOTTOM_HEIGHT + CONTENT_SUPER_BOTTOM;
    }else
        return LOCATION_TOP_HEIGHT_Big + LOCATION_BOTTOM_HEIGHT + CONTENT_SUPER_BOTTOM ;
}

#pragma mark - 手势

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint pointInView = [self.contentView convertPoint:point toView:_locationView];
    if ([self.locationView pointInside:pointInView withEvent:nil]) {
        return self.locationView;
    }
    
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)contentEventTappedInView:(UIView *)view {
    if ([self.messageModel.address isEqualToString:LOCATION_UNKNOWE_ADDRESS])
        return;
    [self.delegate cellDidTapped:self];
}

- (void)contentLongPressedBeganInView:(UIView *)aView {
    [self showMenuControllerInRect:self.locationView.bounds inView:self.locationView];
    UIView *view = [[UIView alloc] initWithFrame:self.locationView.bounds];
    view.tag = 100;
    view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    [self.locationView addSubview:view];
}

- (void)contentTouchCancelled {
    UIView *view = [self.locationView viewWithTag:100];
    [view removeFromSuperview];
}



#pragma mark - 菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"复制", @"收藏", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"copyAction:", @"favoriteAction:", @"deleteAction:", @"moreAction:"];
}

- (void)copyAction:(id)sender {
    
}


- (void)favoriteAction:(id)sender {
    
}

#pragma mark - 内存 -

- (void)willDisplayCell {
    if (!self.mapImageView.image) {
        self.mapImageView.image = self.messageModel.thumbnailImage;
    }
}

- (void)didEndDisplayingCell {
    self.mapImageView.image = nil;
}


@end
