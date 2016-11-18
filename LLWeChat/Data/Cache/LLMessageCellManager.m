//
//  LLMessageCellManager.m
//  LLWeChat
//
//  Created by GYJZH on 9/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageCellManager.h"
#import "LLUtils.h"
#import "LLConfig.h"

typedef NSMutableDictionary<NSString *, LLMessageBaseCell *> *DICT_TYPE;

//最多缓存的Cell数
#define MAX_CACHE_CELLS 1300

//当退出会话时，保留的Cell数
#define CACHE_CELLS_RETAINT_NUM 130

#define INITIAL_CAPACITY MAX_CACHE_CELLS

@interface LL_MessageCell_Data : NSObject

@property (nonatomic, copy) NSString *conversationId;

//依照messageModel.timestamp 升序排序
@property (nonatomic) NSMutableArray<LLMessageBaseCell *> *allMessageCells;

@end

@implementation LL_MessageCell_Data


@end


@interface LLMessageCellManager ()

@property (nonatomic, readwrite) DICT_TYPE allMessageCells;

@property (nonatomic) NSMutableArray<LL_MessageCell_Data *> *allMessageCellData;

@end

@implementation LLMessageCellManager

CREATE_SHARED_MANAGER(LLMessageCellManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _allMessageCellData = [NSMutableArray array];
        _allMessageCells = [NSMutableDictionary dictionaryWithCapacity:INITIAL_CAPACITY];
    }
    
    return self;
}

- (NSDictionary<NSString *, LLMessageBaseCell *> *)allCells {
    return _allMessageCells;
}

- (NSString *)reuseIdentifierForMessegeModel:(LLMessageModel *)model {
    switch (model.messageBodyType) {
        case kLLMessageBodyTypeText:
            return model.fromMe ? @"messageTypeTextMe" : @"messageTypeText";
        case kLLMessageBodyTypeImage:
            return model.fromMe ? @"messageTypeImageMe" : @"messageTypeImage";
        case kLLMessageBodyTypeDateTime:
            return @"messageTypeDateTime";
        case kLLMessageBodyTypeVoice:
            return model.fromMe ? @"messageTypeVoiceMe" : @"messageTypeVoice";
        case kLLMessageBodyTypeGif:
            return model.fromMe ? @"messageTypeGifMe" : @"messageTypeGif";
        case kLLMessageBodyTypeLocation:
            return model.fromMe ? @"messageTypeLocationMe" : @"messageTypeLocation";
        case kLLMessageBodyTypeVideo:
            return model.fromMe ? @"messageTypeVideoMe" : @"messageTypeVideo";
        default:
            break;
    }
    
    return @"messageTypeNone";
}

- (Class)tableViewCellClassForMessegeModel:(LLMessageModel *)model {
    switch (model.messageBodyType) {
        case kLLMessageBodyTypeText:
            return [LLMessageTextCell class];
        case kLLMessageBodyTypeImage:
            return [LLMessageImageCell class];
        case kLLMessageBodyTypeDateTime:
            return [LLMessageDateCell class];
        case kLLMessageBodyTypeVoice:
            return [LLMessageVoiceCell class];
        case kLLMessageBodyTypeGif:
            return [LLMessageGifCell class];
        case kLLMessageBodyTypeLocation:
            return [LLMessageLocationCell class];
        case kLLMessageBodyTypeVideo:
            return [LLMessageVideoCell class];
        default:
            return Nil;
    }
    
    return Nil;
}

- (LLMessageBaseCell *)createMessageCellForMessageModel:(LLMessageModel *)messageModel withReuseIdentifier:(NSString *)reuseId {
    Class cellClass = [self tableViewCellClassForMessegeModel:messageModel];
    LLMessageBaseCell *_cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    
    [_cell prepareForUse:messageModel.isFromMe];
    [messageModel setNeedsUpdateForReuse];
    _cell.messageModel = messageModel;
    
    return _cell;
}

- (LLMessageBaseCell *)messageCellForMessageModel:(LLMessageModel *)messageModel tableView:(UITableView *)tableView {
    LLMessageBaseCell *_cell = _allMessageCells[messageModel.messageId];
    if (_cell) {
        return _cell;
    }
    
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:messageModel.conversationId];
    //有空余名额
    if (_allMessageCells.count < MAX_CACHE_CELLS) {
        _cell = [self createMessageCellForMessageModel:messageModel withReuseIdentifier:nil];
        _allMessageCells[messageModel.messageId] = _cell;
        [self addMessageCellToCellData:_cell cellData:data];
        
        while (_allMessageCells.count == MAX_CACHE_CELLS && self.allMessageCellData.count > 1) {
            [self deleteConversation:self.allMessageCellData[0].conversationId];
        }
    }else {
        //缓存最新消息
        if (messageModel.timestamp > [data.allMessageCells lastObject].messageModel.timestamp) {
            LLMessageBaseCell *firstCell = data.allMessageCells[0];
            [_allMessageCells removeObjectForKey:firstCell.messageModel.messageId];
            [data.allMessageCells removeObjectAtIndex:0];
            
            _cell = [self createMessageCellForMessageModel:messageModel withReuseIdentifier:nil];
            _allMessageCells[messageModel.messageId] = _cell;
            [self addMessageCellToCellData:_cell cellData:data];
        //采用TableView重用
        }else {
            NSString *reuseId = [self reuseIdentifierForMessegeModel:messageModel];
            _cell = (LLMessageBaseCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
            if (!_cell) {
                _cell = [self createMessageCellForMessageModel:messageModel withReuseIdentifier:reuseId];
            }else {
                [messageModel setNeedsUpdateForReuse];
            }
        }
        
    }
    
    return _cell;
}


- (void)cleanCacheWhenConversationExit:(NSString *)conversationId {
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:conversationId];
    if (data.allMessageCells.count > CACHE_CELLS_RETAINT_NUM) {
        NSRange range = NSMakeRange(0, data.allMessageCells.count - CACHE_CELLS_RETAINT_NUM);
        NSArray<LLMessageBaseCell *> *deleteCells = [data.allMessageCells subarrayWithRange:range];
        [data.allMessageCells removeObjectsInRange:range];
        
        for (LLMessageBaseCell *cell in deleteCells) {
            [_allMessageCells removeObjectForKey:cell.messageModel.messageId];
        }
        
    }

}

//创建Data，并把它放到数组最后
- (void)prepareCacheWhenConversationBegin:(NSString *)conversationId {
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:conversationId];
    [self.allMessageCellData removeObject:data];
    [self.allMessageCellData addObject:data];
}

- (void)deleteAllCells {
    [_allMessageCells removeAllObjects];
    [_allMessageCellData removeAllObjects];
}

- (LLMessageBaseCell *)cellForMessageId:(NSString *)messageId {
    return self.allCells[messageId];
}

- (LLMessageBaseCell *)removeCellForMessageModel:(LLMessageModel *)messageModel {
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:messageModel.conversationId];
    
    LLMessageBaseCell *cell = self.allCells[messageModel.messageId];
    if (cell) {
        [_allMessageCells removeObjectForKey:messageModel.messageId];
        [data.allMessageCells removeObject:cell];
    }
    
    return cell;
}

- (void)updateMessageModel:(LLMessageModel *)messageModel toMessageId:(NSString *)newMessageId {
    LLMessageBaseCell *cell = self.allCells[messageModel.messageId];
    if (cell) {
        [_allMessageCells removeObjectForKey:messageModel.messageId];
        _allMessageCells[newMessageId] = cell;
    }

}

- (void)removeCellsForMessageModelsInArray:(NSArray<LLMessageModel *> *)messageModels {
    if (messageModels.count == 0)
        return;
    
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:messageModels[0].conversationId];
    
    for (LLMessageModel *model in messageModels) {
        LLMessageBaseCell *cell = self.allCells[model.messageId];
        if (cell) {
            [_allMessageCells removeObjectForKey:model.messageId];
            [data.allMessageCells removeObject:cell];
        }
    }
    
}


- (void)deleteConversation:(NSString *)conversationId {
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    for (NSString *key in self.allCells) {
        LLMessageBaseCell *cell = self.allCells[key];
        if ([cell.messageModel.conversationId isEqualToString:conversationId]) {
            [keys addObject:key];
        }
    }
    
    if (keys.count > 0)
        [_allMessageCells removeObjectsForKeys:keys];
    
    LL_MessageCell_Data *data = [self messageCellDataForConversationId:conversationId];
    [self.allMessageCellData removeObject:data];
    
}

#pragma mark -内部方法 -

- (LL_MessageCell_Data *)messageCellDataForConversationId:(NSString *)conversationId {
    for (LL_MessageCell_Data *data in self.allMessageCellData) {
        if ([data.conversationId isEqualToString:conversationId]) {
            return data;
        }
    }
    
    LL_MessageCell_Data *data = [[LL_MessageCell_Data alloc] init];
    data.conversationId = conversationId;
    data.allMessageCells = [NSMutableArray array];
    [self.allMessageCellData addObject:data];
    
    return data;
}

- (void)addMessageCellToCellData:(LLMessageBaseCell *)cell cellData:(LL_MessageCell_Data *)data {
    if (![cell.messageModel.conversationId isEqualToString:data.conversationId]) {
        return;
    }
    
    NSInteger i = 0, count = data.allMessageCells.count;
    for (; i < count; i++) {
        if (cell.messageModel.timestamp < data.allMessageCells[i].messageModel.timestamp) {
            break;
        }
    }
    
    [data.allMessageCells insertObject:cell atIndex:i];
}


@end
