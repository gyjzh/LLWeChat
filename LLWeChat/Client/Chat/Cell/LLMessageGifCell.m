//
//  LLMessageGifCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/18/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageGifCell.h"
#import "UIKit+LLExt.h"
#import "LLEmotionModelManager.h"
#import "LLUtils.h"
#import "LLChatManager+MessageExt.h"
#import "LLGIFImageView.h"

#define GIF_IMAGE_SIZE 100


@interface LLMessageGifCell ()
@property (nonatomic) LLGIFImageView *gifImageView;

@end

@implementation LLMessageGifCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.gifImageView = [[LLGIFImageView alloc] initWithFrame:CGRectMake(0, CONTENT_SUPER_TOP, GIF_IMAGE_SIZE, GIF_IMAGE_SIZE)];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.gifImageView];
    }
    
    return self;
}

- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGRect frame = self.gifImageView.frame;
    if (isFromMe) {
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CONTENT_AVATAR_MARGIN - frame.size.width;
    }else {
        frame.origin.x = CGRectGetMaxX(self.avatarImage.frame) + CONTENT_AVATAR_MARGIN;
    }
    
    self.gifImageView.frame = frame;

}

- (void)layoutMessageStatusViews:(BOOL)isFromMe {
    if (isFromMe) {
        _indicatorView.center = CGPointMake(CGRectGetMinX(self.gifImageView.frame) - CGRectGetWidth(_indicatorView.frame)/2 - 16, CGRectGetMidY(self.gifImageView.frame));
        
        _statusButton.center = CGPointMake(CGRectGetMinX(self.gifImageView.frame) - CGRectGetWidth(_statusButton.frame)/2 - 16, CGRectGetMidY(self.gifImageView.frame));
        
    }
}


+ (CGFloat)heightForModel:(LLMessageModel *)model {
    return GIF_IMAGE_SIZE + CONTENT_SUPER_BOTTOM;
}

- (void)willDisplayCell {
    if (!self.gifImageView.gifData) {
        NSData *gifData = [[LLChatManager sharedManager] gifDataForGIFMessageModel:self.messageModel];
        
        self.gifImageView.gifData = gifData;
        self.gifImageView.startShowIndex = self.messageModel.gifShowIndex;
        [self.gifImageView startGIFAnimating];
    }
  
}

- (void)didEndDisplayingCell {
    self.gifImageView.gifData = nil;
}

- (void)willBeginScrolling {
    [super willBeginScrolling];
    self.messageModel.gifShowIndex = self.gifImageView.currentShowIndex;
}

- (void)didEndScrolling {
    
}


#pragma mark - 手势

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint pointInView = [self.contentView convertPoint:point toView:self.gifImageView];
    
    if ([self.gifImageView pointInside:pointInView withEvent:nil]) {
        return self.gifImageView;
    }
    
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    [self showMenuControllerInRect:self.gifImageView.bounds inView:self.gifImageView];
}


#pragma mark - 菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"添加到表情", @"转发", @"查看专集", @"删除", @"更多..."];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"addToEmojiAction:", @"forwardAction:", @"showAlbumAction:",@"deleteAction:", @"moreAction:"];
}

- (void)addToEmojiAction:(id)sender {
    
}


- (void)showAlbumAction:(id)sender {
    
}


@end
