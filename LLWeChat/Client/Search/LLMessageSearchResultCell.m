//
//  LLMessageSearchResultCell.m
//  LLWeChat
//
//  Created by GYJZH on 06/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageSearchResultCell.h"
#import "UIKit+LLExt.h"

@interface LLMessageSearchResultCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;


@end

@implementation LLMessageSearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSearchResultModels:(NSArray<LLMessageSearchResultModel *> *)searchResultModels showDate:(BOOL)showDate {
    _searchResultModels = searchResultModels;
    if (_searchResultModels.count == 1) {
        [self setSearchResultModel:searchResultModels[0] showDate:showDate];
    }else if (_searchResultModels.count > 1) {
        [self setMultiSearchResultModel:searchResultModels[0] count:_searchResultModels.count];
    }
}


- (void)setSearchResultModel:(LLMessageSearchResultModel *)searchResultModel showDate:(BOOL)showDate {
    self.titleLabel.text = searchResultModel.nickName;
    
    if (showDate) {
       NSDate *date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:searchResultModel.timestamp];
        self.dateLabel.text = [date timeIntervalBeforeNowShortDescription];
    }else {
        self.dateLabel.text = nil;
    }
    
    self.avatarImageView.image = [UIImage imageNamed:@"user"];
    self.searchResultLabel.text = @"待定";
}

- (void)setMultiSearchResultModel:(LLMessageSearchResultModel *)searchResultModel count:(NSInteger)count {
   
    self.titleLabel.text = searchResultModel.nickName;
    self.dateLabel.text = nil;
    self.searchResultLabel.text = [NSString stringWithFormat:@"%ld条相关聊天记录", (long)count];
    self.avatarImageView.image = [UIImage imageNamed:@"user"];
}

@end
