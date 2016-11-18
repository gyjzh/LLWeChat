//
//  LLAssetImageCell.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetModel.h"

@interface LLAssetImageCell : UICollectionViewCell

@property (nonatomic) LLAssetModel *assetModel;
@property (nonatomic, getter=isCellSelected) BOOL cellSelected;

- (void)addTarget:(id)target selectAction:(SEL)action showAction:(SEL)action2;
@end
