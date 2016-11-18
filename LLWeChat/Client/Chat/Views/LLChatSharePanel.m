//
//  LLChatSharePanel.m
//  LLWeChat
//
//  Created by GYJZH on 10/5/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLChatSharePanel.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLShareCollectionViewCell.h"

#define CELL_REUSE_ID @"ShareCellID"

@interface LLChatSharePanel ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;

@property (nonatomic) NSArray *dataArray;

@end

@implementation LLChatSharePanel

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self addTapGestureRecognizer:@selector(cancelButton:)];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LLShareCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CELL_REUSE_ID];
    self.flowLayout.itemSize = CGSizeMake(60, 155);
    self.flowLayout.minimumLineSpacing = 8;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    self.dataArray = @[@[@"Action_Email",@"邮件"],
                       @[@"WizAppIcon60x60",@"为知笔记"],
                       @[@"YoudaoAppIcon60x60",@"有道云笔记"]
                       ];
}

- (IBAction)cancelButton:(id)sender {
    [self hide];
}

- (void)show {
    UIView *superView = [LLUtils mostFrontViewController].view;
    self.frame = superView.bounds;
    [superView addSubview:self];
    
    self.contentView.top_LL = CGRectGetHeight(self.frame);
    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
       self.contentView.bottom_LL = CGRectGetHeight(self.frame);
    }];
}

- (void)hide {
    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
        self.contentView.top_LL = CGRectGetHeight(self.frame);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - Collection View -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLShareCollectionViewCell *cell = (LLShareCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    
    NSArray *data = self.dataArray[indexPath.item];
    [cell setContent:data[0] text:data[1]];
    
    return cell;
}


@end
