//
//  LLChatMoreBottomBar.m
//  LLWeChat
//
//  Created by GYJZH on 10/5/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatMoreBottomBar.h"
#import "LLUtils.h"

#define ITEM_SIZE 35

#define MARGIN_FACTOR 1.34

@interface LLChatMoreBottomBar ()

@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;


@end

@implementation LLChatMoreBottomBar

- (void)awakeFromNib {
    [super awakeFromNib];
    _isButtonsEnabled = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat gap = (SCREEN_WIDTH - 4 * ITEM_SIZE) / (3 + 2 * MARGIN_FACTOR);
    CGFloat _y = (CGRectGetHeight(self.bounds) - ITEM_SIZE) / 2;
    
    CGFloat _x = gap * MARGIN_FACTOR;
    _x = [LLUtils pixelAlignForFloat:_x];
    self.forwardButton.frame = CGRectMake(_x, _y, ITEM_SIZE, ITEM_SIZE);
    
    _x = [LLUtils pixelAlignForFloat:CGRectGetMaxX(self.forwardButton.frame) + gap];
    self.favoriteButton.frame = CGRectMake(_x, _y, ITEM_SIZE, ITEM_SIZE);
    
    _x = [LLUtils pixelAlignForFloat:CGRectGetMaxX(self.favoriteButton.frame) + gap];
    self.deleteButton.frame = CGRectMake(_x, _y, ITEM_SIZE, ITEM_SIZE);
    
    _x = [LLUtils pixelAlignForFloat:CGRectGetMaxX(self.deleteButton.frame) + gap];
    self.moreButton.frame = CGRectMake(_x, _y, ITEM_SIZE, ITEM_SIZE);
    
}

- (void)setIsButtonsEnabled:(BOOL)isButtonsEnabled {
    self.forwardButton.enabled = isButtonsEnabled;
    self.favoriteButton.enabled = isButtonsEnabled;
    self.deleteButton.enabled = isButtonsEnabled;
    self.moreButton.enabled = isButtonsEnabled;
}

@end
