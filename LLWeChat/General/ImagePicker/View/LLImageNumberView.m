//
//  LLImageNumberView.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/26/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImageNumberView.h"

@interface LLImageNumberView ()

@property (nonatomic) UIImageView *backgroundImage;
@property (nonatomic) UILabel *numberLabel;

@end


@implementation LLImageNumberView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    self.backgroundImage.image = [UIImage imageNamed:@"FriendsSendsPicturesNumberIcon"];
    [self addSubview:self.backgroundImage];
    
    self.numberLabel = [[UILabel alloc] initWithFrame:self.backgroundImage.frame];
    self.numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel.font = [UIFont boldSystemFontOfSize:15];
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.numberLabel];
    
    return self;
}

- (void)setNumber:(NSInteger)number {
    if (_number != number) {
        _number = number;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)_number];
        [self animateView];
    }
}

- (void)animateView {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundImage.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.backgroundImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundImage.transform = CGAffineTransformMakeScale(1, 1);
            } completion:nil];
            
        }];
    }];
    
}

@end
