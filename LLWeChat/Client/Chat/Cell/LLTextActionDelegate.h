//
//  LLTextActionDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 08/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLTextActionDelegate <NSObject>

//点击了URL链接
- (void)textLinkDidTapped:(nonnull NSURL *)url userinfo:(nullable id)userinfo;

- (void)textLinkDidLongPressed:(nonnull NSURL *)url userinfo:(nullable id)userinfo;

//点击了电话号码
- (void)textPhoneNumberDidTapped:(nonnull NSString *)phoneNumber userinfo:(nullable id)userinfo;

@end
