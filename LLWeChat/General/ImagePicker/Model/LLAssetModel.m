//
//  LLAssetModel.m
//  LLPickImageDemo
//
//  Created by GYJZH on 7/11/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLAssetModel.h"
#import "LLAssetManager.h"
#import "LLUtils.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static NSInteger assetIndex = 0;

static PHImageRequestOptions *requestOptions;

@implementation LLAssetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isAssetInLocalAlbum = YES;
        _assetIndex = assetIndex++;
    }
    
    return self;
}

+ (void)finalize_LL {
    requestOptions = nil;
}

- (void)setAsset_PH:(PHAsset *)asset_PH {
    _asset_PH = asset_PH;
    
    if (!_asset_PH) {
        _assetMediaType = kLLAssetMediaTypeUnknown;
    }else {
        switch (_asset_PH.mediaType) {
            case PHAssetMediaTypeImage:
                _assetMediaType = kLLAssetMediaTypeImage;
                break;
            case PHAssetMediaTypeVideo:
                _assetMediaType = kLLAssetMediaTypeVideo;
                break;
            case PHAssetMediaTypeUnknown:
                _assetMediaType = kLLAssetMediaTypeUnknown;
                break;
            default:
                _assetMediaType = kLLAssetMediaTypeOther;
                break;
        }
    }

}


- (void)setAsset_AL:(ALAsset *)asset_AL {
    _asset_AL = asset_AL;
    
    if (!_asset_AL) {
        _assetMediaType = kLLAssetMediaTypeUnknown;
    }else {
        NSString *assetType = [_asset_AL valueForProperty:ALAssetPropertyType];
        
        if ([assetType isEqualToString:ALAssetTypePhoto]) {
            _assetMediaType = kLLAssetMediaTypeImage;
        }else if ([assetType isEqualToString:ALAssetTypeVideo]) {
            _assetMediaType = kLLAssetMediaTypeVideo;
        }else if ([assetType isEqualToString:ALAssetTypeUnknown]) {
            _assetMediaType = kLLAssetMediaTypeUnknown;
        }else {
            _assetMediaType = kLLAssetMediaTypeOther;
        }
    }
    
}

+ (PHImageRequestOptions *)requestOptions {
    if (!requestOptions) {
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        requestOptions.synchronous = NO;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    
    return requestOptions;
}

- (void)fetchThumbnailWithPointSize:(CGSize)size completion:(nonnull void (^)(UIImage * _Nullable image, LLAssetModel * _Nonnull assetModel))completionCallback {
    if (!self.isAssetInLocalAlbum) {
        completionCallback(nil, self);
        return;
    }
    
    if (self.asset_PH) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize pixelSize = CGSizeMake(scale * size.width, scale * size.height);
        
        WEAK_SELF;
        [[PHImageManager defaultManager] requestImageForAsset:self.asset_PH targetSize:pixelSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            STRONG_SELF;
            
            weakSelf.isAssetInLocalAlbum = (result != nil);
            completionCallback(result, strongSelf);
        }];

    }else {
        CGImageRef thumbnail = [self.asset_AL thumbnail];
        self.isAssetInLocalAlbum = (thumbnail != NULL);
        completionCallback(thumbnail ? [UIImage imageWithCGImage:thumbnail] : nil, self);
    }
}

- (NSString *)duration {
    if (self.assetMediaType != kLLAssetMediaTypeVideo) {
        return @"";
    }
    
    if (!_duration) {
        CGFloat duration = 0;
        if (self.asset_PH) {
            duration = _asset_PH.duration;
        }else if (self.asset_AL) {
            duration = [[_asset_AL valueForProperty:ALAssetPropertyDuration] doubleValue];
        }
        _duration = [self.class getDurationString:round(duration)];
    
    }
    
    return _duration;
}

+ (NSString *)getDurationString:(NSInteger)duration {
    NSInteger minutes = duration / 60;
    NSInteger seconds = duration % 60;
    NSString *ret = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return ret;
}

- (CGSize)imageSize {
    if (self.asset_PH) {
        return CGSizeMake(self.asset_PH.pixelWidth, self.asset_PH.pixelHeight);
    }else {
        return self.asset_AL.defaultRepresentation.dimensions;
    }
}


@end

#pragma clang diagonstic pop
