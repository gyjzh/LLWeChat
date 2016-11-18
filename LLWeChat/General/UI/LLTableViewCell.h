//
//  LLTableViewCell.h
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LLTableViewCellStyle) {
    kLLTableViewCellStyleDefault = UITableViewCellStyleDefault,
    kLLTableViewCellStyleValue1 = UITableViewCellStyleValue1,
    kLLTableViewCellStyleValue2 = UITableViewCellStyleValue2,
    kLLTableViewCellStyleSubtitle = UITableViewCellStyleSubtitle,
    
    kLLTableViewCellStyleValueCenter = 1000,
    kLLTableViewCellStyleValueLeft,
    kLLTableViewCellStyleContactList,
    kLLTableViewCellStyleContactSearchList
};


typedef NS_ENUM(NSInteger, LLTableViewCellAccessoryType) {
    kLLTableViewCellAccessoryNone = UITableViewCellAccessoryNone,
    kLLTableViewCellAccessoryDisclosureIndicator = UITableViewCellAccessoryDisclosureIndicator,
    kLLTableViewCellAccessoryDetailDisclosureButton = UITableViewCellAccessoryDetailDisclosureButton,
    kLLTableViewCellAccessoryCheckmark = UITableViewCellAccessoryCheckmark,
    kLLTableViewCellAccessoryDetailButton = UITableViewCellAccessoryDetailButton,
    
    kLLTableViewCellAccessorySwitch,
    kLLTableViewCellAccessoryText,
};

@interface LLTableViewCell : UITableViewCell

@property (nonatomic) LLTableViewCellAccessoryType accessoryType_LL;

+ (instancetype)cellWithStyle:(LLTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (BOOL)isSwitchOn;

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated;

- (NSString *)rightTextValue;

- (void)setRightTextValue:(NSString *)value;

@end
