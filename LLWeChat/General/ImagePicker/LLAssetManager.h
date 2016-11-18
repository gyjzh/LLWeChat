//
//  LLAssetManager.h
//  LLPickImageDemo
//
//  Created by GYJZH on 7/12/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLAssetsGroupModel.h"
#import "LLAssetModel.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LLAuthorizationType) {
    kLLAuthorizationTypeNotDetermined = 0,
    kLLAuthorizationTypeRestricted,
    kLLAuthorizationTypeDenied,
    kLLAuthorizationTypeAuthorized
};


//获取全部相册成功回调
typedef void (^LLFetchAssetsGroupsSuccessBlock)();

//获取全部相册失败回调
typedef void (^LLFetchAssetsGroupsFailureBlock)(NSError * _Nullable error);


typedef void (^LLFetchAllAssetsSucessBlock)(LLAssetsGroupModel * _Nonnull);
typedef void (^LLFetchAllAssetsFailureBlock)(NSError * _Nullable);


/*
 *获取照片回调，异步回调
 *
 *image: 返回的照片
 *assetModel: 返回时标明是哪个Asset的图片
 *
 */
typedef void (^LLFetchImageAsyncCallbackBlock)(UIImage *_Nullable image, LLAssetModel *_Nullable assetModel);


/*
 *获取照片回调，同步回调
 *
 *image: 返回的照片
 *needBackgroundLoading: 如果为YES，表示无法同步返回照片，照片需要异步加载。
 *此时Image可以为nil, 用户界面可以显示个进度条；也可以非nil，表示先返回了一个低质量图片
 *
 */
typedef void (^LLFetchImageSyncCallbackBlock)(UIImage *_Nullable image, BOOL needBackgroundLoading);

typedef void (^LLCheckAuthorizationCompletionBlock)(LLAuthorizationType type);

@interface LLAssetManager : NSObject

@property (nonnull, nonatomic, readonly) NSArray<LLAssetsGroupModel *> *allAssetsGroups;

+ (nonnull instancetype)sharedAssetManager;

+ (void)destroyAssetManager;

- (LLAssetsGroupModel *)assetsGroupModelForLocalIdentifier:(NSString *)localIdentifier;

//异步获取所有相册
- (void)fetchAllAssetsGroups:(nonnull LLFetchAssetsGroupsSuccessBlock)sucessCallback failureBlock:(nullable LLFetchAssetsGroupsFailureBlock)failureCallback;

//异步获取相册下所有照片
- (void)fetchAllAssetsInGroup:(nonnull LLAssetsGroupModel *)groupModel successBlock:(nullable LLFetchAllAssetsSucessBlock)successCallback failureBlock:(nullable LLFetchAllAssetsFailureBlock)failureCallback;

- (void)fetchImageFromAssetModel:(nonnull LLAssetModel *)assetModel asyncBlock:(nullable LLFetchImageAsyncCallbackBlock)asyncCallback syncBlock:(nullable LLFetchImageSyncCallbackBlock)syncCallback;

- (void)chechAuthorizationStatus:(nonnull LLCheckAuthorizationCompletionBlock)completion;

- (NSData *)fetchImageDataFromAssetModel:(LLAssetModel *)model;

- (LLAssetModel *)fetchAssetModelWithURL:(NSURL *)url;

-(void)fetchFullScreenImageWithURL:(NSURL *)url asyncBlock:(nullable LLFetchImageAsyncCallbackBlock)asyncCallback syncBlock:(nullable LLFetchImageSyncCallbackBlock)syncCallback;

- (void)fetchThumbmailImageWithURL:(NSURL *)url pointSize:(CGSize)size completion:(nonnull void (^)(UIImage * _Nullable, LLAssetModel *))completionCallback;

#pragma mark - 获取视频 -
//获取视频PlayerItem，如果视频文件不存在，返回的AVPlayerItem为nil
- (void)getVideoPlayerItemForAssetModel:(LLAssetModel *)assetModel completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion;

- (void)getVideoAssetForAssetModel:(LLAssetModel *)assetModel completion:(void (^)(AVURLAsset *videoAsset))completion;

NS_ASSUME_NONNULL_END

@end

#pragma clang diagonstic pop
