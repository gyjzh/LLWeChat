//
//  LLMessageModel.h
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessage.h"
#import "LLSDKError.h"
#import "LLSDKType.h"
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, LLMessageModelUpdateReason) {
    kLLMessageModelUpdateReasonUploadComplete, //消息上传成功
    kLLMessageModelUpdateReasonAttachmentDownloadComplete, //消息附件下载成功
    kLLMessageModelUpdateReasonThumbnailDownloadComplete,  //消息缩略图下载成功
    kLLMessageModelUpdateReasonReGeocodeComplete,          //地理名称解析完毕
};

//typedef NS_OPTIONS(NSInteger, LLMessageCellUpdateType) {
//    kLLMessageCellUpdateTypeNone = 0,          //
//    kLLMessageCellUpdateTypeThumbnailChanged = 1,      //缩略图改变
//    kLLMessageCellUpdateTypeUploadStatusChanged = 1 << 1,   //上传状态改变
//    kLLMessageCellUpdateTypeDownloadStatusChanged = 1 << 2, //下载状态改变
//    kLLMessageCellUpdateTypeNewForReuse = 1 << 3,       //首次使用，或者重用
//    
//};

@interface LLMessageModel : NSObject

//展示消息的CellHeight，计算一次，然后缓存
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic, copy, readonly) NSString *messageId;
@property (nonatomic, copy, readonly) NSString *conversationId;

//消息发送方
@property (nonatomic, copy) NSString *from;
//消息接收方
@property (nonatomic, copy) NSString *to;

@property (nonatomic, getter=isFromMe) BOOL fromMe;

@property (nonatomic, readonly) LLMessageBodyType messageBodyType;

@property (nonatomic) NSTimeInterval timestamp;

@property (nonatomic) NSString *text;

@property (nonatomic) NSMutableAttributedString *attributedText;

@property (nonatomic) NSDictionary *ext;

//@property (nonatomic) LLMessageCellUpdateType updateType;

//消息即将被删除
@property (nonatomic) BOOL isDeleting;

//GIF动画停止时，显示的照片索引。在恢复动画时，从此帧开始播放
@property (nonatomic) NSInteger gifShowIndex;

#pragma mark - 图片消息

@property (nonatomic, weak) UIImage *thumbnailImage;

@property (nonatomic) CGSize thumbnailImageSize;

- (UIImage *)fullImage;

#pragma mark - 地址消息

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *locationName;

@property (nonatomic) CLLocationCoordinate2D coordinate2D;
@property (nonatomic) BOOL defaultSnapshot;
@property (nonatomic) CGFloat snapshotScale;
@property (nonatomic) CGFloat zoomLevel;

@property (nonatomic) BOOL isFetchingAddress;

#pragma mark - 音频、视频

@property (nonatomic) BOOL isMediaPlaying;

@property (nonatomic) BOOL isMediaPlayed;

@property (nonatomic) BOOL needAnimateVoiceCell;

- (BOOL)isVideoPlayable;

- (BOOL)isFullImageAvailable;

- (BOOL)isVoicePlayable;

//单位为妙
@property (nonatomic) CGFloat mediaDuration;

@property (nonatomic) BOOL isSelected;

#pragma mark - 附件、文件
//附件下载地址
@property (nonatomic, copy) NSString *fileRemotePath;
//附件本地地址
@property (nonatomic, copy) NSString *fileLocalPath;
//单位为字节
@property (nonatomic) long long fileSize;
//附件上传进度，范围为0--100
@property (nonatomic) NSInteger fileUploadProgress;
//附件下载进度，范围为0--100
@property (nonatomic) NSInteger fileDownloadProgress;

@property (nonatomic, readonly) BOOL isFetchingThumbnail;

@property (nonatomic, readonly) BOOL isFetchingAttachment;

@property (nonatomic) LLSDKError *error;

//该方法供外部代码调用
+ (LLMessageModel *)messageModelFromPool:(EMMessage *)message;

- (instancetype)initWithType:(LLMessageBodyType)type;

- (void)updateMessage:(EMMessage *)aMessage updateReason:(LLMessageModelUpdateReason)updateReason;

+ (NSString *)messageTypeTitle:(EMMessage *)message;

- (long long)fileAttachmentSize;

- (void)cleanWhenConversationSessionEnded;

#pragma mark - 消息状态 -
@property (nonatomic, readonly) LLMessageStatus messageStatus;

@property (nonatomic, readonly) LLMessageDownloadStatus messageDownloadStatus;

@property (nonatomic, readonly) LLMessageDownloadStatus thumbnailDownloadStatus;

#pragma mark - MessageCell 更新
#pragma mark 因为APP有消息缓存(默认1300条)，所以减少重复计算是有必要的 -

- (void)setNeedsUpdateThumbnail;

- (void)setNeedsUpdateUploadStatus;

- (void)setNeedsUpdateDownloadStatus;

- (void)setNeedsUpdateForReuse;

- (BOOL)checkNeedsUpdateThumbnail;

- (BOOL)checkNeedsUpdateUploadStatus;

- (BOOL)checkNeedsUpdateDownloadStatus;

- (BOOL)checkNeedsUpdateForReuse;

- (BOOL)checkNeedsUpdate;

- (void)clearNeedsUpdateThumbnail;

- (void)clearNeedsUpdateUploadStatus;

- (void)clearNeedsUpdateDownloadStatus;

- (void)clearNeedsUpdateForReuse;

#pragma mark - 以下方法 Client代码不直接访问 -
@property (nonatomic) EMMessage * sdk_message;

@property (nonatomic) BOOL isDownloadingAttachment;

- (instancetype)initWithMessage:(EMMessage *)message;

- (void)internal_setMessageStatus:(LLMessageStatus)messageStatus;

- (void)internal_setMessageDownloadStatus:(LLMessageDownloadStatus)messageDownloadStatus;

- (void)internal_setThumbnailDownloadStatus:(LLMessageDownloadStatus)thumbnailDownloadStatus;

- (void)internal_setIsFetchingAttachment:(BOOL)isFetchingAttachment;

- (void)internal_setIsFetchingThumbnail:(BOOL)isFetchingThumbnail;

#pragma mark - 以下方法仅供测试使用 -
- (instancetype)initWithImageModel:(LLMessageModel *)messageModel;

@end

