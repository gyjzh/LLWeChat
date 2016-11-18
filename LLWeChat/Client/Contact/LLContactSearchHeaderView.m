//
//  LLContactSearchHeaderView.m
//  LLWeChat
//
//  Created by GYJZH on 15/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLContactSearchHeaderView.h"
#import "LLUserProfile.h"

@interface LLContactSearchHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *myWeChatLabel;

@property (weak, nonatomic) IBOutlet UIView *searchView;

@end


@implementation LLContactSearchHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.myWeChatLabel.text = [NSString stringWithFormat:@"我的微信号: %@", [LLUserProfile myUserProfile].userName];
    [self.myWeChatLabel sizeToFit];
    
}



@end
