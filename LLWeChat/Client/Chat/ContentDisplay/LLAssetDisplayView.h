//
//  LLAssetDisplayView.h
//  LLWeChat
//
//  Created by GYJZH on 9/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLMessageModel.h"

@protocol LLAssetDisplayView<NSObject>

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) LLMessageModel *messageModel;

@property (nonatomic) NSInteger assetIndex;

@property (nonatomic) LLMessageBodyType messageBodyType;

@end
