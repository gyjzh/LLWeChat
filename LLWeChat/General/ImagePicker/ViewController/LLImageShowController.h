//
//  LLPhotoPreviewController.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/27/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetModel.h"
#import "LLAssetsGroupModel.h"

@interface LLImageShowController : UIViewController

@property (nonatomic) LLAssetsGroupModel *assetGroupModel;
@property (nonatomic) NSArray<LLAssetModel *> *allAssets;
@property (nonatomic) NSMutableArray<LLAssetModel *> *allSelectdAssets;
@property (nonatomic) LLAssetModel *curShowAsset;

@end
