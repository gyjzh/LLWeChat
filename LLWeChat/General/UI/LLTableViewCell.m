//
//  LLTableViewCell.m
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLTableViewCell.h"
#import "LLConfig.h"

#define CONTACT_CELL_IMAGE_SIZE 36

@interface LLTableViewCell ()

@property (nonatomic) LLTableViewCellStyle style;

@end

@implementation LLTableViewCell

+ (instancetype)cellWithStyle:(LLTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    LLTableViewCell *cell;
    switch (style) {
        case kLLTableViewCellStyleValue1:
        case kLLTableViewCellStyleValue2:
        case kLLTableViewCellStyleSubtitle:
        case kLLTableViewCellStyleDefault:
            cell = [[LLTableViewCell alloc] initWithStyle:(UITableViewCellStyle)style reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kLLTableViewCellStyleValueCenter:
        case kLLTableViewCellStyleContactList:
        case kLLTableViewCellStyleValueLeft:
            cell = [[LLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kLLTableViewCellStyleContactSearchList:
            cell = [[LLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.textColor = kLLTextColor_lightGray_system;
            
            break;
    }
    
    cell.style = style;
    return cell;
}

- (void)setAccessoryType_LL:(LLTableViewCellAccessoryType)accessoryType_LL {
    _accessoryType_LL = accessoryType_LL;
    switch (accessoryType_LL) {
        case kLLTableViewCellAccessoryNone:
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        case kLLTableViewCellAccessoryDisclosureIndicator:
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kLLTableViewCellAccessoryDetailButton:
            self.accessoryType = UITableViewCellAccessoryDetailButton;
            break;
        case kLLTableViewCellAccessoryDetailDisclosureButton:
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        case kLLTableViewCellAccessoryCheckmark:
            self.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
            
        case kLLTableViewCellAccessoryText: {
            self.accessoryType = UITableViewCellAccessoryNone;
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            CGFloat fontSize = self.textLabel.font.pointSize;
            label.font = [UIFont systemFontOfSize:fontSize - 1];
            label.textAlignment = NSTextAlignmentCenter;
            self.accessoryView = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kLLTableViewCellAccessorySwitch:
            self.accessoryType = UITableViewCellAccessoryNone;
            self.accessoryView = [[UISwitch alloc] init];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        default:
            break;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame;
    
    switch (self.style) {
        case kLLTableViewCellStyleValueCenter: {
            [self.textLabel sizeToFit];
            frame = self.contentView.bounds;
            self.textLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            break;
        }
        case kLLTableViewCellStyleContactList: {
            frame = CGRectMake(10, 0, CONTACT_CELL_IMAGE_SIZE, CONTACT_CELL_IMAGE_SIZE);
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CONTACT_CELL_IMAGE_SIZE) / 2;
            self.imageView.frame = frame;

            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            
            break;
        }
        case kLLTableViewCellStyleContactSearchList: {
            
            
            break;
        }
        case kLLTableViewCellStyleValueLeft: {
            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = TABLE_VIEW_CELL_LEFT_MARGIN;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            break;
        }
        default:
            break;
    }
}

- (BOOL)isSwitchOn {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        return switcher.on;
    }else {
        return NO;
    }
}

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        [switcher setOn:on animated:animated];
    }
}

- (NSString *)rightTextValue {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        return label.text;
    }
    
    return nil;
}

- (void)setRightTextValue:(NSString *)value {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        label.text = value;
        [label sizeToFit];
    }
}

@end
