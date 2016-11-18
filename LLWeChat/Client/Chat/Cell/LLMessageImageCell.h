//
//  LLMessageImageCell.h
//  LLWeChat
//
//  Created by GYJZH on 8/12/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageBaseCell.h"

#define IMAGE_MIN_SIZE 55
#define IMAGE_MAX_SIZE 155

@interface LLMessageImageCell : LLMessageBaseCell

@property (nonatomic) UIImageView *chatImageView;

+ (CGSize)thumbnailSize:(CGSize)size;

- (void)willExitFullScreenShow;

- (void)didExitFullScreenShow;

@end
