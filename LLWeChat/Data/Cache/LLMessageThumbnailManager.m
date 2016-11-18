//
//  LLMessageThumbnailManager.m
//  LLWeChat
//
//  Created by GYJZH on 22/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageThumbnailManager.h"
#import "LLUtils.h"
#import "LLMessageModel.h"
#import "UIImage+LLExt.h"

#define THUMBNAIL_DISK_QUEUE "THUMBNAIL_DISK_QUEUE"

//默认最大缓存为80M
#define MAX_CACHE_SIZE 83886080


@interface LL_MessageThumbnail_Data : NSObject

@property (nonatomic, copy) NSString *conversationId;

//依照thumbnail获取次序排序，最近获取的在最后面
@property (nonatomic) NSMutableArray<NSString *> *allMessageIds;

@end

@implementation LL_MessageThumbnail_Data


@end

/*******************************************************************/

@interface LLMessageThumbnailManager ()

@property (nonatomic, readwrite) NSMutableDictionary<NSString*, UIImage *> *allMessageThumbnails;

@property (nonatomic) NSMutableArray<LL_MessageThumbnail_Data *> *allMessageThumbnailDatas;

@property (nonatomic) NSInteger currentCacheSize;

@property (nonatomic) dispatch_queue_t diskQueue;

@end

@implementation LLMessageThumbnailManager {
    NSInteger scale;
}


CREATE_SHARED_MANAGER(LLMessageThumbnailManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _allMessageThumbnails = [NSMutableDictionary dictionary];
        _allMessageThumbnailDatas = [NSMutableArray arrayWithCapacity:40];
        _diskQueue = dispatch_queue_create(THUMBNAIL_DISK_QUEUE, DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_diskQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
        scale = [LLUtils screenScale];
    }
    
    return self;
}

- (nullable UIImage *)thumbnailForMessageModel:(LLMessageModel *)messageModel {
    UIImage *thumbnail = _allMessageThumbnails[messageModel.messageId];
    if (thumbnail)
        return thumbnail;
    
    switch (messageModel.messageBodyType) {
        case kLLMessageBodyTypeImage:
        case kLLMessageBodyTypeVideo: {
            NSString *path = [self cachePathForMessageModel:messageModel];
            NSData *data = [NSData dataWithContentsOfFile:path];
            thumbnail = [UIImage imageWithData:data scale:scale];
            if (thumbnail) {
                [self asyncSetFileModificationDate:[NSDate date] atPath:path];
                [self addThumbnailForMessageModel:messageModel thumbnail:thumbnail toDisk:NO];
            }
        }
            break;
        default:
            break;
    }

    [self cleanDiskCacheIfNeeded];
    return thumbnail;
}

- (void)removeThumbnailForMessageModel:(LLMessageModel *)messageModel removeFromDisk:(BOOL)removeFromDisk {
    LL_MessageThumbnail_Data *data = [self messageThumbnailDataForConversationId:messageModel.conversationId];
    [data.allMessageIds removeObject:messageModel.messageId];
    
    UIImage *image = _allMessageThumbnails[messageModel.messageId];
    if (image) {
        [_allMessageThumbnails removeObjectForKey:messageModel.messageId];
        _currentCacheSize -= [image imageFileSize];
    }
    
    if (removeFromDisk)
        [self removeThumbnailFromDiskForMessageModel:messageModel];
}

- (void)removeThumbnailForMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels removeFromDisk:(BOOL)removeFromDisk {
    if (messageModels.count == 0)
        return;
    
    LL_MessageThumbnail_Data *data = [self messageThumbnailDataForConversationId:messageModels[0].conversationId];
    for (LLMessageModel *model in messageModels) {
        [data.allMessageIds removeObject:model.messageId];
        
        UIImage *image = _allMessageThumbnails[model.messageId];
        if (image) {
            [_allMessageThumbnails removeObjectForKey:model.messageId];
            _currentCacheSize -= [image imageFileSize];
        }
        
        if (removeFromDisk)
            [self removeThumbnailFromDiskForMessageModel:model];
    }
    
}

- (void)addThumbnailForMessageModel:(LLMessageModel *)messageModel thumbnail:(UIImage *)thumbnail toDisk:(BOOL)toDisk {
    if (toDisk) {
        [self saveThumbnailToDiskForMessageModel:messageModel thumbnail:thumbnail];
    }
    
    UIImage *image = _allMessageThumbnails[messageModel.messageId];
    if (image == thumbnail)
        return;
    
    if (image) {
        [_allMessageThumbnails removeObjectForKey:messageModel.messageId];
        _currentCacheSize -= [image imageFileSize];
    }
    
    _allMessageThumbnails[messageModel.messageId] = thumbnail;
    _currentCacheSize += [thumbnail imageFileSize];
    
    LL_MessageThumbnail_Data *data = [self messageThumbnailDataForConversationId:messageModel.conversationId];
    [data.allMessageIds addObject:messageModel.messageId];
    
    for (NSInteger index = 0, count = self.allMessageThumbnailDatas.count; _currentCacheSize > MAX_CACHE_SIZE && index < count - 1; index++) {
        LL_MessageThumbnail_Data *data = self.allMessageThumbnailDatas[index];
        for (NSString *messageId in data.allMessageIds) {
            UIImage *image = _allMessageThumbnails[messageId];
            if (image) {
                [_allMessageThumbnails removeObjectForKey:messageId];
                _currentCacheSize -= [image imageFileSize];
            }
        }
        [data.allMessageIds removeAllObjects];
    }
    
    while (_currentCacheSize > MAX_CACHE_SIZE && data.allMessageIds.count > 1) {
        NSString *messageId = data.allMessageIds[0];
        UIImage *image = _allMessageThumbnails[messageId];
        if (image) {
            [_allMessageThumbnails removeObjectForKey:messageId];
            _currentCacheSize -= [image imageFileSize];
        }
        [data.allMessageIds removeObjectAtIndex:0];
    }
    
}

- (void)prepareCacheWhenConversationBegin:(NSString *)conversationId {
    LL_MessageThumbnail_Data *data = [self messageThumbnailDataForConversationId:conversationId];
    [self.allMessageThumbnailDatas removeObject:data];
    [self.allMessageThumbnailDatas addObject:data];
}

- (void)cleanCacheWhenConversationExit:(NSString *)conversationId {

}

- (void)cleanCacheWhenAPPEnterBackground {
    [self clearAllMemCache];
}

- (void)clearAllMemCache {
    [_allMessageThumbnails removeAllObjects];
    _currentCacheSize = 0;
    
    for (LL_MessageThumbnail_Data *data in _allMessageThumbnailDatas) {
        [data.allMessageIds removeAllObjects];
    }
}

- (void)deleteConversation:(NSString *)conversationId {
    LL_MessageThumbnail_Data *data = [self messageThumbnailDataForConversationId:conversationId];
    for (NSString *messageId in data.allMessageIds) {
        UIImage *image = _allMessageThumbnails[messageId];
        if (image) {
            [_allMessageThumbnails removeObjectForKey:messageId];
            _currentCacheSize -= [image imageFileSize];
        }
        
        NSString *filename = [NSString stringWithFormat:@"%@_%@",conversationId, messageId];
        NSString *path = [[LLUtils messageThumbnailDirectory] stringByAppendingPathComponent:filename];
        [self removeThumbnailFromDiskAtPath:path];
    }
    
    [self.allMessageThumbnailDatas removeObject:data];
    
}

#pragma mark - Disk - 

- (void)saveThumbnailToDiskForMessageModel:(nonnull LLMessageModel *)messageModel thumbnail:(nonnull UIImage *)thumbnail {
    WEAK_SELF;
    dispatch_async(_diskQueue, ^{
        NSString *path = [weakSelf cachePathForMessageModel:messageModel];
        [[NSFileManager defaultManager] createFileAtPath:path contents:UIImagePNGRepresentation(thumbnail) attributes:nil];
    });
}

- (void)removeThumbnailFromDiskForMessageModel:(LLMessageModel *)messageModel {
    WEAK_SELF;
    dispatch_async(_diskQueue, ^{
        NSString *path = [weakSelf cachePathForMessageModel:messageModel];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    });
}

- (void)removeThumbnailFromDiskAtPath:(NSString *)path {
    dispatch_async(_diskQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    });
}

- (NSString *)cachePathForMessageModel:(LLMessageModel *)messageModel {
    NSString *filename = [NSString stringWithFormat:@"%@_%@",messageModel.conversationId, messageModel.messageId];
    return [[LLUtils messageThumbnailDirectory] stringByAppendingPathComponent:filename];
}

- (void)clearAllDiskCache {
    dispatch_sync(_diskQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[LLUtils messageThumbnailDirectory]];
        for (NSString *fileName in fileEnumerator) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",[LLUtils messageThumbnailDirectory], fileName];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    });
}

//删除date之后未访问过的缩略图
- (void)clearAllDiskCacheBeforeDate:(NSDate *)trimDate {
    dispatch_sync(_diskQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[LLUtils messageThumbnailDirectory]];
        for (NSString *fileName in fileEnumerator) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",[LLUtils messageThumbnailDirectory], fileName];
            
            NSError *error = nil;
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            NSDictionary *values = [fileURL resourceValuesForKeys:@[ NSURLContentModificationDateKey] error:&error];
            NSDate *date = [values objectForKey:NSURLContentModificationDateKey];
            
            if ([date compare:trimDate] == NSOrderedAscending) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    });
}

#pragma mark - 缩略图移除 -
/** 由于仅仅是缩略图缓存，不是照片、视频资源类缓存，所以硬盘缓存大小不予考虑，
 *  仅仅移除一段时间内未使用过的缩略图
 */

- (BOOL)checkNeedCleanDiskCache {
    static BOOL hasCleanedCache = NO;
    if (hasCleanedCache) {
        return NO;
    }else {
        BOOL lucky = arc4random_uniform(100) > 80;
        if (lucky)
            hasCleanedCache = YES;
        return lucky;
    }
}

- (void)cleanDiskCacheIfNeeded {
    if ([self checkNeedCleanDiskCache]) {
        //清除一周内未访问过的缩略图
        [self clearAllDiskCacheBeforeDate:[NSDate dateWithTimeIntervalSinceNow:-7 * 24 * 60 * 60]];
    }
}

#pragma mark -内部方法 -

- (LL_MessageThumbnail_Data *)messageThumbnailDataForConversationId:(NSString *)conversationId {
    for (LL_MessageThumbnail_Data *data in self.allMessageThumbnailDatas) {
        if ([data.conversationId isEqualToString:conversationId]) {
            return data;
        }
    }
    
    LL_MessageThumbnail_Data *data = [[LL_MessageThumbnail_Data alloc] init];
    data.conversationId = conversationId;
    data.allMessageIds = [NSMutableArray array];
    [self.allMessageThumbnailDatas addObject:data];
    
    return data;
}

- (void)asyncSetFileModificationDate:(NSDate *)date atPath:(NSString *)path {
    dispatch_async(self.diskQueue, ^{
        NSError *error;
        [[NSFileManager defaultManager]
         setAttributes:@{NSFileModificationDate: date}
         ofItemAtPath:path
         error:&error];
    });
    
}

@end
