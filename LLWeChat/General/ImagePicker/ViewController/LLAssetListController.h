//
//  LLAssetsListController.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetModel.h"
#import "LLAssetsGroupModel.h"


@interface LLAssetListController : UIViewController

@property (nonatomic) NSMutableArray<LLAssetModel*> *allSelectdAssets;
@property (nonatomic) LLAssetsGroupModel *groupModel;

- (void)fetchData;

@end
