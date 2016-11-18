//
//  LLMessageDateCell.h
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageModel.h"


@interface LLMessageDateCell : UITableViewCell

@property (nonatomic) LLMessageModel *messageModel;

+ (CGFloat)heightForModel:(LLMessageModel *)model;

@end
