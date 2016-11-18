//
//  LLMessageDateCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageDateCell.h"
#import "NSDate+LLExt.h"
#import "LLColors.h"
#import "LLConfig.h"
#import "LLUtils.h"

#define HorizontalMargin 3
#define VerticalMargin 3

@interface LLMessageDateCell ()

@property (nonatomic) UILabel *dateLabel;

@end


@implementation LLMessageDateCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = LL_MESSAGE_CELL_BACKGROUND_COLOR;
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = kLLBackgroundColor_darkGray;
        self.dateLabel.layer.cornerRadius = 6;
        self.dateLabel.clipsToBounds = YES;
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:self.dateLabel];
    }
    
    return self;
}


- (void)setMessageModel:(LLMessageModel *)messageModel {
    if (_messageModel != messageModel) {
        _messageModel = messageModel;

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_messageModel.timestamp];
        self.dateLabel.text = [date timeIntervalBeforeNowLongDescription];

        [self layoutContentView];
    }
    
    [messageModel clearNeedsUpdateForReuse];
}

- (void)layoutContentView {
    CGRect frame = CGRectZero;
    frame.size.width = self.dateLabel.intrinsicContentSize.width + 2 * HorizontalMargin;
    frame.size.height = self.dateLabel.intrinsicContentSize.height + 2 * VerticalMargin;

    frame.origin.x = (SCREEN_WIDTH - frame.size.width) /2;
    frame.origin.y = (40 - frame.size.height)/2 - 5;
    self.dateLabel.frame = frame;

}

+ (CGFloat)heightForModel:(LLMessageModel *)model {
    return 40;
}

@end
