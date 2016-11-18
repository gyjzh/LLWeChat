//
// Created by GYJZH on 9/23/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import "LLCollectionTextCell.h"
#import "LLUtils.h"

#define TEXT_LABLE_FONT_SIZE 13

@implementation LLCollectionTextCell {
    UILabel *textLabel;
}

- (void)commonInit {
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,60,COLLECTION_TEXT_CELL_HEIGHT)];
    textLabel.layer.cornerRadius = CGRectGetHeight(textLabel.frame)/2;
    textLabel.layer.borderWidth = 1;
    textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.contentView addSubview:textLabel];
    
    textLabel.font = [UIFont systemFontOfSize:TEXT_LABLE_FONT_SIZE];
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    textLabel.text = text;

    CGSize size = [self.class cellSizeForText:text];
    textLabel.frame = CGRectMake(0,0, size.width, size.height);
}

+ (CGSize)cellSizeForText:(NSString *)text {
    CGSize size = [LLUtils boundingSizeForText:text
                               maxWidth:FLT_MAX
                                   font:[UIFont systemFontOfSize:TEXT_LABLE_FONT_SIZE]
                            lineSpacing:0];
    size.width += COLLECTION_TEXT_CELL_HEIGHT;
    size.height = COLLECTION_TEXT_CELL_HEIGHT;
    return size;
}

@end
