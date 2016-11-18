//
//  LLPhotoAlbumController.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/24/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLImagePickerController.h"
#import "LLAuthorizationDeniedController.h"
#import "LLAlbumListController.h"
#import "LLAssetListController.h"
#import "LLAssetManager.h"
#import "UIKit+LLExt.h"
#import "LLUtils.h"
#import "LLImagePickerConfig.h"

static NSString *lastAssertGroupIdentifier;


@interface LLImagePickerController ()

@property (nonatomic) LLAlbumListController *albumVC;

@end

@implementation LLImagePickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navigationBar.translucent = YES;
        self.navigationBar.barAlpha = DEFAULT_NAVIGATION_BAR_ALPHA;
    }
    
    return self;
}

- (void)chechAuthorizationStatus {
    WEAK_SELF;
    LLCheckAuthorizationCompletionBlock block = ^(LLAuthorizationType type) {
        if (!weakSelf)return;
        
        switch (type) {
            case kLLAuthorizationTypeAuthorized:
            {
                //ImagePicker打开时尚未获取照片库权限，请求权限后用户允许访问照片库
                if (weakSelf.albumVC) {
                    if ([LLUtils canUsePhotiKit])
                        [weakSelf fetchAlbumData];
                }else {
                    //ImagePicker打开时就获取了访问照片库的权限
                    weakSelf.albumVC = [[LLAlbumListController alloc] initWithStyle:UITableViewStylePlain];
                    weakSelf.albumVC.navigationItem.title = @"返回";
                
                    LLAssetListController *assetListVC = [[LLAssetListController alloc] init];
                    assetListVC.groupModel = nil;
                    [weakSelf setViewControllers:@[weakSelf.albumVC, assetListVC] animated:NO];
                    
                    [weakSelf fetchAlbumData];
                }
                
            }
                break;
            case kLLAuthorizationTypeDenied:
            case kLLAuthorizationTypeRestricted:
            {
                LLAuthorizationDeniedController *vc = [[LLAuthorizationDeniedController alloc] initWithNibName:nil bundle:nil];
                [weakSelf setViewControllers:@[vc] animated:NO];
            }
                break;
            case kLLAuthorizationTypeNotDetermined:
            {
                weakSelf.albumVC = [[LLAlbumListController alloc] initWithStyle:UITableViewStylePlain];
                [weakSelf setViewControllers:@[weakSelf.albumVC] animated:NO];
                if (![LLUtils canUsePhotiKit])
                    [weakSelf fetchAlbumData];
            }
                break;
            default:
                break;
        }
    };
    
    [[LLAssetManager sharedAssetManager] chechAuthorizationStatus:block];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self chechAuthorizationStatus];
}

//该方法异步获取全部相册
- (void)fetchAlbumData {
    WEAK_SELF;
    LLFetchAssetsGroupsSuccessBlock successBlock = ^() {
        if ([[weakSelf.childViewControllers lastObject] isKindOfClass:[LLAssetListController class]]) {
            LLAssetsGroupModel *model = [[LLAssetManager sharedAssetManager] assetsGroupModelForLocalIdentifier:lastAssertGroupIdentifier];
            
            LLAssetListController *assetListVC = (LLAssetListController *)[weakSelf.childViewControllers lastObject];
            assetListVC.groupModel = model;
            [assetListVC fetchData];
        }else {
            [weakSelf.albumVC refresh];
        }
    };
    
    LLFetchAssetsGroupsFailureBlock failureBlock = ^(NSError * _Nullable error) {
    };
    
    [[LLAssetManager sharedAssetManager] fetchAllAssetsGroups:successBlock failureBlock:failureBlock];
}

- (void)didFinishPickingImages:(NSArray<LLAssetModel *> *)assets WithError:(NSError *)error assetGroupModel:(LLAssetsGroupModel *)assetGroupModel {
    lastAssertGroupIdentifier = assetGroupModel.localIdentifier;
    
    [self.pickerDelegate imagePickerController:self didFinishPickingImages:assets withError:error];
    [self cleanAfterDismiss];
}

- (void)didCancelPickingImages {
    [self.pickerDelegate imagePickerControllerDidCancel:self];
    
    [self cleanAfterDismiss];
}

- (void)didFinishPickingVideo:(NSString *)videoPath assetGroupModel:(LLAssetsGroupModel *)assetGroupModel {
    lastAssertGroupIdentifier = assetGroupModel.localIdentifier;
    [self.pickerDelegate imagePickerController:self didFinishPickingVideo:videoPath];
    
    [self cleanAfterDismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)cleanAfterDismiss {
    [LLAssetManager destroyAssetManager];
    [LLAssetModel finalize_LL];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



@end
