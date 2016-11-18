//
//  LLLocationTableViewCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLLocationTableViewCell.h"
#import "UIKit+LLExt.h"
#import "LLUtils.h"
#import "LLColors.h"

@implementation LLLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];

        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.textColor = kLLTextColor_lightGray_system;
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.top_LL -= 3;
    self.textLabel.left_LL -= 3;
    
    self.detailTextLabel.bottom_LL += 1;
    self.detailTextLabel.left_LL -= 3;
}

@end
