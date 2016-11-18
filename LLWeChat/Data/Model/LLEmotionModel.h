//
//  LLEmotionModel.h
//  LLWeChat
//
//  Created by GYJZH on 8/18/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LLEmotionType) {
    kLLEmotionTypeEmoji = 0, //直接插入文本中的小图标
    kLLEmotionTypeFacial,    //静态表情
    kLLEmotionTypeFacialGif  //动态大话表情
};

@class LLEmotionGroupModel;

@interface LLEmotionModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *imagePNG; //png资源名称
@property (nonatomic, copy) NSString *imageGIF;  //gif资源

@property (nonatomic) LLEmotionGroupModel *group; //所属的表情包

@property (nonatomic) NSString *codeId;  //表情ID

+ (instancetype)modelWithDictionary:(NSDictionary *)data;

@end

@interface LLEmotionGroupModel : NSObject

@property (nonatomic, copy) NSString *groupName;

@property (nonatomic) NSMutableArray<LLEmotionModel *> *allEmotionModels;

@property (nonatomic, copy) NSString *bundleName; //表情包所在的bundle

@property (nonatomic, copy) NSString *groupIconName; //对应表情键盘下面的滑动条按钮

@property (nonatomic) LLEmotionType type;

@end