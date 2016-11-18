//
//  LLAssetsListController.m
//  LLPickImageDemo
//
//  Created by GYJZH on 6/25/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLAssetListController.h"
#import "LLAssetImageCell.h"
#import "LLAssetVideoCell.h"
#import "LLImageNumberView.h"
#import "LLImageShowController.h"
#import "LLPhotoToolbar.h"
#import "LLAssetManager.h"
#import "LLImagePickerController.h"
#import "LLUtils.h"
#import "UICollectionView+LLExt.h"
#import "UINavigationBar+LLExt.h"
#import "UIScrollView+LLExt.h"
#import "LLImagePickerConfig.h"
#import "LLVideoDisPlayController.h"

#define NUM_PER_ROW 4
#define CELL_INTEVEL 4.0

#define COLLECTION_IMAGE_CELL_ID @"Asset_Image_Cell_Id"

#define COLLECTION_VIDEO_CELL_ID @"Asset_Video_Cell_Id"

@interface LLAssetListController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) LLPhotoToolbar *toolBar;

@property (nonatomic) MBProgressHUD *HUD;

@end

@implementation LLAssetListController {
    CGFloat cellWidth;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.allSelectdAssets = [[NSMutableArray alloc] init];

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.groupModel.assetsGroupName;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = NAVIGATION_BAR_RIGHT_MARGIN;
    self.navigationItem.rightBarButtonItems = @[spaceItem, cancelItem];
    
    [self setupSubView];
    
    [self fetchData];
    
}


- (void)setupSubView {
    cellWidth = floor((SCREEN_WIDTH - (NUM_PER_ROW + 1) * CELL_INTEVEL) / NUM_PER_ROW);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumLineSpacing = CELL_INTEVEL;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(CELL_INTEVEL, CELL_INTEVEL, 0, CELL_INTEVEL);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[LLAssetImageCell class] forCellWithReuseIdentifier:COLLECTION_IMAGE_CELL_ID];
    [self.collectionView registerClass:[LLAssetVideoCell class] forCellWithReuseIdentifier:COLLECTION_VIDEO_CELL_ID];
    
    self.toolBar = [[LLPhotoToolbar alloc] initWithStyle:kLLPhotoToolbarStyle1];
    [self.toolBar addTarget:self previewAction:@selector(doPreview) finishAction:@selector(doFinish)];
    [self.view addSubview:self.toolBar];

    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, CGRectGetHeight(self.toolBar.frame), 0);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)showLoadingIndicator {
    self.HUD = [LLUtils showActivityIndicatiorHUDWithTitle:@"正在加载..." inView:self.view];
}


- (void)hideLoadingIndicator {
    [LLUtils hideHUD:self.HUD animated:YES];
}


#pragma mark - 获取数据

- (void)fetchData {
    //没有数据时，显示一个ActivityIndicator
    if (!self.groupModel) {
        [self showLoadingIndicator];
        return;
    }
    self.title = self.groupModel.assetsGroupName;
    
    WEAK_SELF;
    [[LLAssetManager sharedAssetManager] fetchAllAssetsInGroup:self.groupModel successBlock:^(LLAssetsGroupModel * _Nonnull groupModel) {
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView layoutIfNeeded];
        
        [weakSelf.collectionView scrollsToBottomAnimated:NO];
        [weakSelf hideLoadingIndicator];
    } failureBlock:^(NSError * _Nullable error) {
        ;
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barAlpha = DEFAULT_NAVIGATION_BAR_ALPHA;

    self.toolBar.number = self.allSelectdAssets.count;
    [self.collectionView reloadData];

}

- (void)doFinish {
     [(LLImagePickerController *)self.navigationController didFinishPickingImages:self.allSelectdAssets WithError:nil assetGroupModel:self.groupModel];
}

- (void)doCancel {
    [(LLImagePickerController *)self.navigationController didCancelPickingImages];
}

- (void)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groupModel.allAssets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LLAssetModel *assetModel = self.groupModel.allAssets[indexPath.item];
    UICollectionViewCell *_cell;
    if (assetModel.assetMediaType == kLLAssetMediaTypeVideo) {
        LLAssetVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIDEO_CELL_ID forIndexPath:indexPath];
        cell.assetModel = assetModel;
        
        _cell = cell;
    }else if (assetModel.assetMediaType == kLLAssetMediaTypeImage) {
        LLAssetImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_IMAGE_CELL_ID forIndexPath:indexPath];
        cell.assetModel = assetModel;
        cell.cellSelected = [self.allSelectdAssets containsObject:cell.assetModel];
        [cell addTarget:self selectAction:@selector(handleAssetCellSelect:) showAction:@selector(handleAssetCellShow:)];
        
        _cell = cell;
    }

    return _cell;
}


- (BOOL)handleAssetCellSelect:(LLAssetImageCell *)cell {
    if (!cell.assetModel.isAssetInLocalAlbum) {
        if (cell.isCellSelected) {
            [self.allSelectdAssets removeObject:cell.assetModel];
            self.toolBar.number = self.allSelectdAssets.count;
            return YES;
        }else {
            //TODO:下一步支持iCloud照片流，当前版本暂不支持
            [LLUtils showMessageAlertWithTitle:nil message:@"正在从iCloud同步照片"];
            return NO;
        }
    }
    
    if (!cell.isCellSelected) {
        if (self.allSelectdAssets.count == MAX_PHOTOS_CAN_SELECT) {
            [LLUtils showMessageAlertWithTitle:nil message:[NSString stringWithFormat:@"最多选择%d张照片", MAX_PHOTOS_CAN_SELECT] actionTitle:@"我知道了"];
            return NO;
        }else if (![self.allSelectdAssets containsObject:cell.assetModel]) {
            [self.allSelectdAssets addObject:cell.assetModel];
        }
    }else if (cell.isCellSelected && [self.allSelectdAssets containsObject:cell.assetModel]) {
        [self.allSelectdAssets removeObject:cell.assetModel];
    }
    
    self.toolBar.number = self.allSelectdAssets.count;
    
    return YES;
}

- (void)doPreview {
    LLImageShowController *previewController = [[LLImageShowController alloc] init];
    
    previewController.assetGroupModel = self.groupModel;
    previewController.allSelectdAssets = self.allSelectdAssets;
    previewController.curShowAsset = self.allSelectdAssets[0];
    previewController.allAssets = [self.allSelectdAssets copy];
    
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)handleAssetCellShow:(LLAssetImageCell *)cell {
    LLImageShowController *previewController = [[LLImageShowController alloc] init];
    
    previewController.assetGroupModel = self.groupModel;
    previewController.curShowAsset = cell.assetModel;
    previewController.allSelectdAssets = self.allSelectdAssets;
    previewController.allAssets = self.groupModel.allAssets;
    
    [self.navigationController pushViewController:previewController animated:YES];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    LLAssetModel *assetModel = self.groupModel.allAssets[indexPath.item];
    
    if (assetModel.assetMediaType == kLLAssetMediaTypeVideo) {
        LLVideoDisPlayController *vc = [[LLVideoDisPlayController alloc] init];
        vc.assetModel = assetModel;
        vc.assetGroupModel = self.groupModel;
    
        [self.navigationController pushViewController:vc animated:YES];
    }

}


@end
