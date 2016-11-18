//
//  LLShareCollectionViewCell.m
//  LLWeChat
//
//  Created by GYJZH on 10/5/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLShareCollectionViewCell.h"

@interface LLShareCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation LLShareCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 12;
    self.imageView.layer.masksToBounds = YES;
}

- (void)setContent:(NSString *)imageName text:(NSString *)text {
    self.imageView.image = [UIImage imageNamed:imageName];
    self.label.text = text;
}

@end
