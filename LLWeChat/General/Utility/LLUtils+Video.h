//
//  LLUtils+Video.h
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"
@import AVFoundation;

@interface LLUtils (Video)

/**
 *  将Apple视频录制的格式MOV转换为MP4格式
 *
 */
+ (void)convertVideoFromMOVToMP4:(NSURL *)movUrl complete:(void (^)(NSString *mp4Path, BOOL finished))completeCallback;

/**
 *  获取视频时长
 *
 *  @return 单位秒
 */
+ (CGFloat)getVideoLength:(NSString *)videoPath;

/**
 *  获取视频显示尺寸
 *
 *  @param URL <#URL description#>
 *
 *  @return <#return value description#>
 */
+ (CGSize)getVideoSize:(NSString *)videoPath;


/**
 * 获取视频缩略图
 */
+ (UIImage *)getVideoThumbnailImage:(NSString *)videoPath;


//用户录制的视频压缩
+ (void)compressVideoForSend:(NSURL *)videoURL
               removeMOVFile:(BOOL)removeMOVFile
                  okCallback:(void (^)(NSString *mp4Path))okCallback
              cancelCallback:(void (^)())cancelCallback
                failCallback:(void (^)())failCallback;

//系统相册中视频压缩
+ (void)compressVideoAssetForSend:(AVURLAsset *)videoAsset
                       okCallback:(void (^)(NSString *mp4Path))okCallback
                   cancelCallback:(void (^)())cancelCallback
                     failCallback:(void (^)())failCallback
                  successCallback:(void (^)(NSString *mp4Path))successCallback;

@end
