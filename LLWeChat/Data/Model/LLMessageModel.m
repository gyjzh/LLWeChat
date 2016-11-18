//
//  LLMessageModel.m
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageModel.h"
#import "EMTextMessageBody.h"
#import "EMMessage.h"
#import "LLUserProfile.h"
#import "LLUtils.h"
#import "LLEmotionModelManager.h"
#import "EMImageMessageBody.h"
#import "EMSDK.h"
#import "LLConfig.h"
#import "UIKit+LLExt.h"
#import "LLChatManager+MessageExt.h"
#import "LLMessageModelManager.h"
#import "LLMessageCellManager.h"
#import "LLMessageThumbnailManager.h"
#import "LLSimpleTextLabel.h"

#import "LLMessageImageCell.h"
#import "LLMessageTextCell.h"
#import "LLMessageGifCell.h"
#import "LLMessageDateCell.h"
#import "LLMessageLocationCell.h"
#import "LLMessageVoiceCell.h"
#import "LLMessageVideoCell.h"
#import "LLMessageRecordingCell.h"

//缩略图正在下载时照片尺寸
#define DOWNLOAD_IMAGE_WIDTH 175
#define DOWNLOAD_IMAGE_HEIGHT 145


typedef NS_OPTIONS(NSInteger, LLMessageCellUpdateType) {
    kLLMessageCellUpdateTypeNone = 0,          //
    kLLMessageCellUpdateTypeThumbnailChanged = 1,      //缩略图改变
    kLLMessageCellUpdateTypeUploadStatusChanged = 1 << 1,   //上传状态改变
    kLLMessageCellUpdateTypeDownloadStatusChanged = 1 << 2, //下载状态改变
    kLLMessageCellUpdateTypeNewForReuse = 1 << 3,       //首次使用，或者重用
    
};

static NSMutableDictionary<NSString *, UIImage *> *tmpImageDict;

@interface LLMessageModel ()

@property (nonatomic, readwrite) LLMessageStatus messageStatus;

@property (nonatomic, readwrite) LLMessageDownloadStatus thumbnailDownloadStatus;

@property (nonatomic, readwrite) LLMessageDownloadStatus messageDownloadStatus;

@property (nonatomic) LLMessageCellUpdateType updateType;

@end

@implementation LLMessageModel


+ (void)initialize {
    if (self == [LLMessageModel class]) {
        tmpImageDict = [NSMutableDictionary dictionary];
    }
}

#pragma mark - 消息初始化 -

- (instancetype)initWithImageModel:(LLMessageModel *)messageModel {
    self = [super init];
    if (self) {
        _messageBodyType = kLLMessageBodyTypeImage;
        _thumbnailImageSize = messageModel.thumbnailImageSize;
        _messageDownloadStatus = kLLMessageDownloadStatusSuccessed;
        _thumbnailDownloadStatus = kLLMessageDownloadStatusSuccessed;
        _messageId = [NSString stringWithFormat:@"%f%d",[NSDate date].timeIntervalSince1970, arc4random()];
        _conversationId = [messageModel.conversationId copy];
        _cellHeight = messageModel.cellHeight;
        _fromMe = YES;
    }
    
    return self;
}


- (instancetype)initWithType:(LLMessageBodyType)type {
    self = [super init];
    if (self) {
        _messageBodyType = type;
        
        switch (type) {
            case kLLMessageBodyTypeDateTime:
                self.cellHeight = [LLMessageDateCell heightForModel:self];
                break;
            case kLLMessageBodyTypeVoice:
                self.cellHeight = [LLMessageVoiceCell heightForModel:self];
                break;
            case kLLMessageBodyTypeRecording:
                self.fromMe = YES;
                self.timestamp = [[NSDate date] timeIntervalSince1970];
                self.cellHeight = [LLMessageRecordingCell heightForModel:self];
            default:
                break;
        }
    }
    
    return self;
}

- (void)commonInit:(EMMessage *)message {
    _sdk_message = message;
    _messageBodyType = (LLMessageBodyType)_sdk_message.body.type;
    _messageId = [message.messageId copy];
    _conversationId = [message.conversationId copy];
    _messageStatus = kLLMessageStatusNone;
    _messageDownloadStatus = kLLMessageDownloadStatusNone;
    _thumbnailDownloadStatus = kLLMessageDownloadStatusNone;
    
    _from = [message.from copy];
    _to = [message.to copy];
    _fromMe = _sdk_message.direction == EMMessageDirectionSend;
    
    _updateType = kLLMessageCellUpdateTypeNewForReuse;
    
//    if (_fromMe) {
        _timestamp = adjustTimestampFromServer(message.timestamp);
//    }else {
//        _timestamp = adjustTimestampFromServer(message.serverTime);
//    }
    
    _ext = message.ext;
    _error = nil;

    [self processModelForCell];
}

- (instancetype)initWithMessage:(EMMessage *)message {
    self = [super init];
    if (self) {
        [self commonInit:message];
    }
    
    return self;
}

+ (LLMessageModel *)messageModelFromPool:(EMMessage *)message {
    LLMessageModel *messageModel = [[LLMessageModel alloc] initWithMessage:message];
    [[LLMessageModelManager sharedManager] addMessageModelToConversaion:messageModel];
    
    return messageModel;
}

- (void)updateMessage:(EMMessage *)aMessage updateReason:(LLMessageModelUpdateReason)updateReason {
    BOOL isMessageIdChanged = ![aMessage.messageId isEqualToString:_messageId];
    
    if (aMessage == _sdk_message) {
        if (isMessageIdChanged) {
            NSLog(@"更新消息时，消息ID发生了改变");
            [[LLMessageCellManager sharedManager] updateMessageModel:self toMessageId:aMessage.messageId];
            _messageId = [aMessage.messageId copy];
        }
    }else {
        NSAssert(!isMessageIdChanged, @"更新消息发生异常:EMMessage和消息Id都改变了");
    }
    
    _sdk_message = aMessage;
    _ext = aMessage.ext;
    
    switch (updateReason) {
        case kLLMessageModelUpdateReasonUploadComplete:
            self.updateType |= kLLMessageCellUpdateTypeUploadStatusChanged;
            break;
            
        case kLLMessageModelUpdateReasonThumbnailDownloadComplete:
            self.updateType |= kLLMessageCellUpdateTypeThumbnailChanged;
            break;
            
        case kLLMessageModelUpdateReasonAttachmentDownloadComplete:
            self.fileDownloadProgress = 100;
            self.updateType |= kLLMessageCellUpdateTypeDownloadStatusChanged;
            switch (self.messageBodyType) {
                case kLLMessageBodyTypeImage:
                case kLLMessageBodyTypeVideo: {
                    EMFileMessageBody *messageBody = (EMFileMessageBody *)self.sdk_message.body;
                    if (messageBody.downloadStatus == EMDownloadStatusSuccessed) {
                        self.thumbnailImage = nil;
                        self.updateType |= kLLMessageCellUpdateTypeThumbnailChanged;
                    }
                    break;
                }
                default:
                    break;
            }

            break;
            
        case kLLMessageModelUpdateReasonReGeocodeComplete:
            if (self.messageBodyType == kLLMessageBodyTypeLocation) {
                self.updateType = kLLMessageCellUpdateTypeNewForReuse;
                [[LLChatManager sharedManager] decodeMessageExtForLocationType:self];
                self.cellHeight = [LLMessageLocationCell heightForModel:self];
            }
            break;
    }

}

//FIXME: 环信有时候会出现DownloadStatus==Success,但文件获取为空的情况
- (UIImage *)fullImage {
    if (self.messageBodyType == kLLMessageBodyTypeImage) {
        EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)self.sdk_message.body;
        if (_fromMe || imgMessageBody.downloadStatus == EMDownloadStatusSuccessed) {
            UIImage *fullImage = [UIImage imageWithContentsOfFile:imgMessageBody.localPath];
            return fullImage;
        }
    }
    
    return nil;
}

- (UIImage *)thumbnailImage {
    if (!_thumbnailImage) {
        _thumbnailImage = [[LLMessageThumbnailManager sharedManager] thumbnailForMessageModel:self];
        if (_thumbnailImage)
            return _thumbnailImage;
    
        UIImage *thumbnailImage;
        BOOL needSaveToCache = NO;
        BOOL needSaveToDisk = NO;
        BOOL needSaveToTemp = NO;
        switch (self.messageBodyType) {
            case kLLMessageBodyTypeImage:{
                EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)self.sdk_message.body;
                
                self.thumbnailImageSize = [LLMessageImageCell thumbnailSize:imgMessageBody.size];
                if (_fromMe || imgMessageBody.downloadStatus == EMDownloadStatusSuccessed) {
                    UIImage *fullImage = [UIImage imageWithContentsOfFile:imgMessageBody.localPath];
                    _thumbnailImageSize = [LLMessageImageCell thumbnailSize:fullImage.size];
                    thumbnailImage = [fullImage resizeImageToSize:self.thumbnailImageSize opaque:YES scale:0];
                    
                    needSaveToCache = YES;
                    needSaveToDisk = YES;
                }else if (imgMessageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                    UIImage *image = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
                    _thumbnailImageSize = [LLMessageImageCell thumbnailSize:image.size];
                    thumbnailImage = [image resizeImageToSize:self.thumbnailImageSize opaque:YES scale:0];
                    
                    needSaveToTemp = YES;
                }
                //FIXME:对于特殊图，比如超长、超宽、超小图，应该做特殊处理
                //调用该方法createWithImageInRect后，VM：raster data内存没有变化
                //以后再解决这个问题
//                if (_thumbnailImageSize.height > 2 * IMAGE_MAX_SIZE) {
//                    _thumbnailImage = [_thumbnailImage createWithImageInRect:CGRectMake(0, (_thumbnailImageSize.height - IMAGE_MAX_SIZE) / 2 * _thumbnailImage.scale, _thumbnailImageSize.width * _thumbnailImage.scale, IMAGE_MAX_SIZE * _thumbnailImage.scale)];
//                }else if (_thumbnailImageSize.width > 2 * IMAGE_MAX_SIZE) {
//                    _thumbnailImage = [_thumbnailImage createWithImageInRect:CGRectMake((_thumbnailImageSize.width - IMAGE_MAX_SIZE)/2 * _thumbnailImage.scale, 0, IMAGE_MAX_SIZE * _thumbnailImage.scale, _thumbnailImageSize.height * _thumbnailImage.scale)];
//                }
                
                break;
            }
            case kLLMessageBodyTypeVideo:{
                EMVideoMessageBody *videoMessageBody = (EMVideoMessageBody *)self.sdk_message.body;

                if (_fromMe || videoMessageBody.downloadStatus == EMDownloadStatusSuccessed ) {
                    UIImage *image = [LLUtils getVideoThumbnailImage:videoMessageBody.localPath];
                    thumbnailImage = [image resizeImageToSize:self.thumbnailImageSize];
                    
                    needSaveToCache = YES;
                    needSaveToDisk = YES;
                }else if (videoMessageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:videoMessageBody.thumbnailLocalPath];
                    thumbnailImage = [image resizeImageToSize:self.thumbnailImageSize];
                    
                    needSaveToTemp = YES;
                }
                
                break;
            }
            case kLLMessageBodyTypeLocation: {
                if (self.defaultSnapshot)
                    return nil;
                
                EMFileMessageBody *body = (EMFileMessageBody *)self.sdk_message.body;
                if (_fromMe || body.downloadStatus == EMDownloadStatusSuccessed) {
                    NSData *data = [NSData dataWithContentsOfFile:body.localPath];
                    thumbnailImage = [UIImage imageWithData:data scale:_snapshotScale];
                    
                    needSaveToCache = YES;
                    needSaveToDisk = NO;
                }
                
                break;
            }
                
            default:
                break;
        }
        
        if (thumbnailImage) {
            if (needSaveToTemp) {
                tmpImageDict[_messageId] = thumbnailImage;
            }else if (needSaveToCache) {
                tmpImageDict[_messageId] = nil;
                [[LLMessageThumbnailManager sharedManager] addThumbnailForMessageModel:self thumbnail:thumbnailImage toDisk:needSaveToDisk];
            }
        }
        
        _thumbnailImage = thumbnailImage;
    }
    
    return _thumbnailImage;
}

//注释掉的代码是通常方法，但由于所有MessageModel都缓存起来了，一个MessageId唯一对应一个MessageModel
//所以MessageModel的比较只需要进行对象指针比较即可
- (BOOL)isEqual:(id)object {
//    if (self == object)
//        return YES;
//    
//    if (!object || ![object isKindOfClass:[LLMessageModel class]]) {
//        return NO;
//    }
//    
//    LLMessageModel *model = (LLMessageModel *)object;
//    return [self.messageId isEqualToString:model.messageId];
    
    return self == object;
}

#pragma mark - 消息状态

- (void)internal_setMessageStatus:(LLMessageStatus)messageStatus {
    _messageStatus = messageStatus;
}

- (void)internal_setMessageDownloadStatus:(LLMessageDownloadStatus)messageDownloadStatus {
    _messageDownloadStatus = messageDownloadStatus;
}

- (void)internal_setThumbnailDownloadStatus:(LLMessageDownloadStatus)thumbnailDownloadStatus {
    _thumbnailDownloadStatus = thumbnailDownloadStatus;
}

- (void)internal_setIsFetchingAttachment:(BOOL)isFetchingAttachment {
    _isFetchingAttachment = isFetchingAttachment;
}

- (void)internal_setIsFetchingThumbnail:(BOOL)isFetchingThumbnail {
    _isFetchingThumbnail = isFetchingThumbnail;
}

- (LLMessageStatus)messageStatus {
    if (_messageStatus != kLLMessageStatusNone)
        return _messageStatus;
    
    return (LLMessageStatus)_sdk_message.status;
}

- (LLMessageDirection)messageDirection {
    return (LLMessageDirection)_sdk_message.direction;
}

- (LLMessageDownloadStatus)messageDownloadStatus {
    if (_messageDownloadStatus != kLLMessageDownloadStatusNone)
        return _messageDownloadStatus;
    if (_fromMe)
        return kLLMessageDownloadStatusSuccessed;
    
    EMFileMessageBody *body = (EMFileMessageBody *)(_sdk_message.body);
    if (body) {
        return (LLMessageDownloadStatus)(body.downloadStatus);
    }else {
        return kLLMessageDownloadStatusNone;
    }
}

- (LLMessageDownloadStatus)thumbnailDownloadStatus {
    if (_thumbnailDownloadStatus != kLLMessageDownloadStatusNone)
        return _thumbnailDownloadStatus;
    if (_fromMe)
        return kLLMessageDownloadStatusSuccessed;
    
    switch (self.messageBodyType) {
        case kLLMessageBodyTypeImage: {
            EMImageMessageBody *body = (EMImageMessageBody *)(_sdk_message.body);
            return (LLMessageDownloadStatus)body.thumbnailDownloadStatus;
        }
        case kLLMessageBodyTypeVideo: {
            EMVideoMessageBody *body = (EMVideoMessageBody *)(_sdk_message.body);
            return (LLMessageDownloadStatus)body.thumbnailDownloadStatus;
        }
        default:
            return kLLMessageDownloadStatusNone;
    }

}

#pragma mark - MessageCell更新 -

- (void)setNeedsUpdateThumbnail {
    _updateType |= kLLMessageCellUpdateTypeThumbnailChanged;
}

- (void)setNeedsUpdateUploadStatus {
    _updateType |= kLLMessageCellUpdateTypeUploadStatusChanged;
}

- (void)setNeedsUpdateDownloadStatus {
    _updateType |= kLLMessageCellUpdateTypeDownloadStatusChanged;
}

- (void)setNeedsUpdateForReuse {
    _updateType |= kLLMessageCellUpdateTypeNewForReuse;
    _updateType |= (kLLMessageCellUpdateTypeNewForReuse - 1);
}

- (BOOL)checkNeedsUpdateThumbnail {
    return (_updateType & kLLMessageCellUpdateTypeThumbnailChanged) > 0;
}

- (BOOL)checkNeedsUpdateUploadStatus {
    return (_updateType & kLLMessageCellUpdateTypeUploadStatusChanged) > 0;
}

- (BOOL)checkNeedsUpdateDownloadStatus {
    return (_updateType & kLLMessageCellUpdateTypeDownloadStatusChanged) > 0;
}

- (BOOL)checkNeedsUpdateForReuse {
    return (_updateType & kLLMessageCellUpdateTypeNewForReuse) > 0;
}

- (BOOL)checkNeedsUpdate {
    return _updateType != kLLMessageCellUpdateTypeNone;
}

- (void)clearNeedsUpdateThumbnail {
    _updateType &= ~kLLMessageCellUpdateTypeThumbnailChanged;
}

- (void)clearNeedsUpdateUploadStatus {
    _updateType &= ~kLLMessageCellUpdateTypeUploadStatusChanged;
}

- (void)clearNeedsUpdateDownloadStatus {
    _updateType &= ~kLLMessageCellUpdateTypeDownloadStatusChanged;
}

- (void)clearNeedsUpdateForReuse {
    _updateType = kLLMessageCellUpdateTypeNone;
}

#pragma mark - 辅助 -

- (long long)fileAttachmentSize {
    switch (_messageBodyType) {
        case kLLMessageBodyTypeImage:
        case kLLMessageBodyTypeVideo:
        case kLLMessageBodyTypeFile:
            return ((EMFileMessageBody *)(_sdk_message.body)).fileLength;

        default:
            return 0;
    }

}

- (BOOL)isVideoPlayable {
    return (_sdk_message.body.type == EMMessageBodyTypeVideo) && (self.fromMe || self.messageDownloadStatus == kLLMessageDownloadStatusSuccessed);
}

- (BOOL)isFullImageAvailable {
    return (_sdk_message.body.type == EMMessageBodyTypeImage) && (self.fromMe || self.messageDownloadStatus == kLLMessageDownloadStatusSuccessed);
}

- (BOOL)isVoicePlayable {
    return (_sdk_message.body.type == EMMessageBodyTypeVoice) && (self.fromMe || self.messageDownloadStatus == kLLMessageDownloadStatusSuccessed);
}

#pragma mark - 数据预处理

+ (NSString *)messageTypeTitle:(EMMessage *)message {
    NSString *typeTitle;
    
    switch (message.body.type) {
        case EMMessageBodyTypeText:{
            if ([message.ext[MESSAGE_EXT_TYPE_KEY] isEqualToString:MESSAGE_EXT_GIF_KEY]) {
                typeTitle = @"动画表情";
            }else {
                EMTextMessageBody *body = (EMTextMessageBody *)message.body;
                typeTitle = body.text;
            }
            break;
        }
        case EMMessageBodyTypeImage:
            typeTitle = @"[图片]";
            break;
        case EMMessageBodyTypeVideo:
            typeTitle = @"[视频]";
            break;
        case EMMessageBodyTypeLocation:
            typeTitle = @"[位置]";
            break;
         case EMMessageBodyTypeVoice:
            typeTitle = @"[语音]";
            break;
        case EMMessageBodyTypeFile:
            if ([message.ext[MESSAGE_EXT_TYPE_KEY] isEqualToString:MESSAGE_EXT_LOCATION_KEY]) {
                typeTitle = @"位置";
            }else {
                typeTitle = @"文件";
            }
            break;
        case EMMessageBodyTypeCmd:
            typeTitle = @"[CMD]";
            break;
            
    }
    
    return typeTitle;
}



- (void)processModelForCell {
    switch (self.messageBodyType) {
        case kLLMessageBodyTypeText: {
            if ([self.ext[MESSAGE_EXT_TYPE_KEY] isEqualToString:MESSAGE_EXT_GIF_KEY]) {
                EMTextMessageBody *textBody = (EMTextMessageBody *)(self.sdk_message.body);
                self.text = [NSString stringWithFormat:@"[%@]", textBody.text];
                _messageBodyType = kLLMessageBodyTypeGif;
                self.cellHeight = [LLMessageGifCell heightForModel:self];
                
            }else {
                EMTextMessageBody *textBody = (EMTextMessageBody *)(self.sdk_message.body);
                self.text = textBody.text;
                self.attributedText = [LLSimpleTextLabel createAttributedStringWithEmotionString:self.text font:[LLMessageTextCell font] lineSpacing:0];
                
                self.cellHeight = [LLMessageTextCell heightForModel:self];
            }
            
        }
            break;
        case kLLMessageBodyTypeDateTime:
            self.cellHeight = [LLMessageDateCell heightForModel:self];
            break;
        case kLLMessageBodyTypeImage:{
            EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)self.sdk_message.body;

            self.thumbnailImageSize = [LLMessageImageCell thumbnailSize:imgMessageBody.size];
            self.fileLocalPath = imgMessageBody.localPath;
            self.cellHeight = [LLMessageImageCell heightForModel:self];
            break;
        }
        case kLLMessageBodyTypeFile:
        case kLLMessageBodyTypeLocation: {
            NSDictionary *messageExt = self.sdk_message.ext;
            
            if ([messageExt[MESSAGE_EXT_TYPE_KEY] isEqualToString:MESSAGE_EXT_LOCATION_KEY]) {
                _messageBodyType = kLLMessageBodyTypeLocation;
                [[LLChatManager sharedManager] decodeMessageExtForLocationType:self];
                EMFileMessageBody *body = (EMFileMessageBody *)self.sdk_message.body;
                
                self.fileLocalPath = body.localPath;
                self.cellHeight = [LLMessageLocationCell heightForModel:self];
            }
            
            break;
        }
        case kLLMessageBodyTypeVoice: {
            EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)self.sdk_message.body;
            self.mediaDuration = voiceBody.duration;
            self.isMediaPlayed = NO;
            self.isMediaPlaying = NO;
            if (_sdk_message.ext) {
                self.isMediaPlayed = [_sdk_message.ext[@"isPlayed"] boolValue];
            }
            // 音频路径
            self.fileLocalPath = voiceBody.localPath;
            self.cellHeight = [LLMessageVoiceCell heightForModel:self];
            
            break;
        }
        case kLLMessageBodyTypeVideo: {
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)self.sdk_message.body;
            // 视频路径
            self.fileLocalPath = videoBody.localPath;
            self.thumbnailImageSize = [LLMessageVideoCell thumbnailSize:videoBody.thumbnailSize];
            self.mediaDuration = videoBody.duration;
            self.fileSize = videoBody.fileLength;
            self.cellHeight = [LLMessageVideoCell heightForModel:self];
            
            break;
        }
            
        case kLLMessageBodyTypeGif:
            self.cellHeight = [LLMessageGifCell heightForModel:self];
            break;
        default:
            break;
            
    }
    
}

- (void)cleanWhenConversationSessionEnded {
    _gifShowIndex = 0;
    if (_isMediaPlaying) {
        _isMediaPlaying = NO;
        _isMediaPlayed = YES;
    }
    _isFetchingAddress = NO;
}



@end


