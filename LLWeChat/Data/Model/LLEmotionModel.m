//
//  LLEmotionModel.m
//  LLWeChat
//
//  Created by GYJZH on 8/18/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLEmotionModel.h"

@implementation LLEmotionModel

+ (instancetype)modelWithDictionary:(NSDictionary *)data {
    LLEmotionModel *model = [LLEmotionModel new];
    
    model.text = data[@"text"];
    model.imagePNG = data[@"image"];
    model.imageGIF = data[@"imageGIF"];
    model.codeId = data[@"id"];
    
    return model;
}


@end

@implementation LLEmotionGroupModel

@end