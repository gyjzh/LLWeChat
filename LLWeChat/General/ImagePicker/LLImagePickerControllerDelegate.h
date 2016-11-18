//
//  LLImagePickerControllerDelegate.h
//  LLPickImageDemo
//
//  Created by GYJZH on 6/28/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLAssetModel.h"


@class LLImagePickerController;
@protocol LLImagePickerControllerDelegate <NSObject>

/**
 *  选取结束，返回选择的照片数据
 *  由ImagePickerController的调用者负责dismissImagePickerController
 *
 */
- (void)imagePickerController:(nonnull LLImagePickerController *)picker didFinishPickingImages:(nullable NSArray<LLAssetModel *> *)assets withError:(nullable NSError *)error;

/**
 *  取消选择
 *  由ImagePickerController的调用者负责dismissImagePickerController
 *
 */
- (void)imagePickerControllerDidCancel:(nonnull LLImagePickerController *)picker;


- (void)imagePickerController:(nonnull LLImagePickerController *)picker didFinishPickingVideo:(nonnull NSString *)videoPath;

@end
