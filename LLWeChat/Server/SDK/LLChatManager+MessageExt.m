//
//  LLChatManager+MessageExt.m
//  LLWeChat
//
//  Created by GYJZH on 9/4/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatManager+MessageExt.h"
#import "LLUtils.h"
#import "LLEmotionModelManager.h"

@implementation LLChatManager (MessageExt)

- (NSMutableDictionary *)encodeGifMessageExtForEmotionModel:(LLEmotionModel *)emotionModel {
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    ext[@"groupName"] = emotionModel.group.groupName;
    ext[@"codeId"] = emotionModel.codeId;
    ext[MESSAGE_EXT_TYPE_KEY] = MESSAGE_EXT_GIF_KEY;
    
    return ext;
}

- (NSData *)gifDataForGIFMessageModel:(LLMessageModel *)model {
    return [[LLEmotionModelManager sharedManager] gifDataForEmotionGroup:model.ext[@"groupName"] codeId:model.ext[@"codeId"]];
}

- (NSMutableDictionary *)encodeLocationMessageExt:(double)latitude longitude:(double)longitude address:(NSString *)address name:(NSString *)name zoomLevel:(CGFloat)zoomLevel defaultSnapshot:(BOOL)defaultSnapshot {
    NSDictionary *messageExt = @{@"latitude":@(latitude).stringValue,
                                 @"longitude": @(longitude).stringValue,
                                 @"address": address,
                                 @"name":name,
                                 @"scale": @([LLUtils screenScale]).stringValue,
                                 @"zoomLevel":@(zoomLevel).stringValue,
                                 @"defaultSnapshot":@(defaultSnapshot),
                                 MESSAGE_EXT_TYPE_KEY: MESSAGE_EXT_LOCATION_KEY
                                 };
    
    return [messageExt mutableCopy];
}


- (void)decodeMessageExtForLocationType:(LLMessageModel *)messageModel {
    NSDictionary *messageExt = messageModel.ext;
    
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.latitude = [messageExt[@"latitude"] doubleValue];
    coordinate2D.longitude = [messageExt[@"longitude"] doubleValue];
    messageModel.coordinate2D = coordinate2D;
    
    messageModel.snapshotScale = [messageExt[@"scale"] doubleValue];
    messageModel.zoomLevel = [messageExt[@"zoomLevel"] doubleValue];
    messageModel.address = messageExt[@"address"];
    messageModel.locationName = messageExt[@"name"];
    messageModel.defaultSnapshot = [messageExt[@"defaultSnapshot"] boolValue];
}



@end
