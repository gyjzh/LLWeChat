//
//  NSString+encrypto.h
//  LLWeChat
//
//  Created by GYJZH on 9/18/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (encrypto)

- (NSString *) md5;
- (NSString *) sha1;
- (NSString *) sha1_base64;
- (NSString *) md5_base64;
- (NSString *) base64;

@end
