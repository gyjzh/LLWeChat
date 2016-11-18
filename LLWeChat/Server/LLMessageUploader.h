//
//  LLMessageUploader.h
//  LLWeChat
//
//  Created by GYJZH on 9/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessageModel.h"

@interface LLMessageUploader : NSObject

+ (instancetype)imageUploader;

+ (instancetype)videoUploader;

+ (instancetype)defaultUploader;

- (void)asynUploadMessage:(LLMessageModel *)model;

@end
