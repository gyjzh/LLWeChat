//
//  LLSubSearchBaseController.h
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLViewController.h"

@interface LLSubSearchBaseController : LLViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) NSMutableArray<NSString *> *dataSources;

- (void)fetchData;

@end
