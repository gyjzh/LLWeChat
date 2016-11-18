//
//  LLSubSearchBaseController.m
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSubSearchBaseController.h"
#import "LLUtils.h"
#import "LLCollectionTextCell.h"
#import "LLLeftAlignedCollectionViewFlowLayout.h"

#define CELL_REUSE_ID @"REUSE_ID"

@interface LLSubSearchBaseController ()

@end

@implementation LLSubSearchBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorRGB(242, 242, 242);
    
    LLLeftAlignedCollectionViewFlowLayout *flowLayout = [[LLLeftAlignedCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 8;
    flowLayout.minimumLineSpacing = 8;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 14, 14, 14);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LLCollectionTextCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
    
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _collectionView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    WEAK_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.collectionView.hidden = NO;
    });
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 建议搜索 -
- (void)fetchData {
}


#pragma mark - CollectionView -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLCollectionTextCell *cell = (LLCollectionTextCell *)[collectionView
                                                          dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID
                                                          forIndexPath:indexPath];
    cell.text = self.dataSources[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [LLCollectionTextCell cellSizeForText:self.dataSources[indexPath.item]];
}

@end
