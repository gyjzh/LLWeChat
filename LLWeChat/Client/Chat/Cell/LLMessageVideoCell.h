//
//  LLMessageVideoCell.h
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageBaseCell.h"

@interface LLMessageVideoCell : LLMessageBaseCell

@property (nonatomic) UIImageView *videoImageView;

+ (CGSize)thumbnailSize:(CGSize)size;

- (void)willExitFullScreenShow;

- (void)didExitFullScreenShow;

@end
