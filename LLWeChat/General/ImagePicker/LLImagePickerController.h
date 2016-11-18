//
//  LLPhotoAlbumController.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLAssetModel.h"
#import "LLAssetsGroupModel.h"
#import "LLImagePickerControllerDelegate.h"

@interface LLImagePickerController : UINavigationController

@property (nullable, nonatomic, weak) id <LLImagePickerControllerDelegate> pickerDelegate;

/**
 *  选取照片完成回调
 *
 *  @param assets 具体返回什么比如UIImage、AssetURL等根据项目需要决定，此处简单返回assetModels
 *  @param error
 */
- (void)didFinishPickingImages:(nonnull NSArray<LLAssetModel *> *)assets WithError:(nullable NSError *)error assetGroupModel:(nonnull LLAssetsGroupModel *)assetGroupModel;

- (void)didCancelPickingImages;

- (void)didFinishPickingVideo:(nonnull NSString *)videoPath assetGroupModel:(nonnull LLAssetsGroupModel *)assetGroupModel;

@end
