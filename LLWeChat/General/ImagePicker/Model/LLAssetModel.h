//
//  LLAssetModel.h
//  LLPickImageDemo
//
//  Created by GYJZH on 7/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@import AssetsLibrary;

typedef NS_ENUM(NSInteger, LLAssetMediaType) {
    kLLAssetMediaTypeUnknown, //未知
    kLLAssetMediaTypeImage,  //照片
    kLLAssetMediaTypeVideo,  //视频
    kLLAssetMediaTypeOther,  //其他暂不支持的格式
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface LLAssetModel : NSObject

@property (nonatomic, readonly) NSInteger assetIndex;

@property (nullable, nonatomic) PHAsset *asset_PH;

@property (nullable, nonatomic) ALAsset *asset_AL;

@property (nonatomic, readonly) LLAssetMediaType assetMediaType;

//资源是否在本地机器上，如果在iCloud上尚未下载完毕，或者本地已经删除了，该变量为NO
@property (nonatomic) BOOL isAssetInLocalAlbum;

@property (nullable, nonatomic, copy) NSString *duration;

- (void)fetchThumbnailWithPointSize:(CGSize)size completion:(nonnull void (^)(UIImage * _Nullable image, LLAssetModel * _Nonnull assetModel))completionCallback;

- (CGSize)imageSize;

+ (void)finalize_LL;

@end

#pragma clang diagonstic pop
