//
// Created by GYJZH on 9/23/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLLECTION_TEXT_CELL_HEIGHT 30

@interface LLCollectionTextCell : UICollectionViewCell

@property (nonatomic) NSString *text;

+ (CGSize)cellSizeForText:(NSString *)text;

@end