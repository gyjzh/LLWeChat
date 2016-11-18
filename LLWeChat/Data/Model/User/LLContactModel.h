//
//  LLContactModel.h
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LLContactModel : NSObject

@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, copy) NSString *pinyinOfUserName;

@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *avatarURLPath;
@property (copy, nonatomic) UIImage *avatarImage;

- (instancetype)initWithBuddy:(NSString *)buddy;

@end
