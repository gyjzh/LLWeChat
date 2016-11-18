//
//  LLShareInputView.m
//  LLWeChat
//
//  Created by GYJZH on 8/1/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLShareInputView.h"
#import "LLColors.h"
#import "LLConfig.h"
#import "LLUtils.h"

#define NUM_ROWS 2
#define NUM_COLS 4

#define CELL_SIZE 59

#define CELL_ID @"ID"


#define CELL_DATA \
    @[ \
        @"sharemore_pic", @"照片", @(TAG_Photo),  \
        @"sharemore_video", @"拍摄", @(TAG_Camera), \
        @"sharemore_sight", @"小视频", @(TAG_Sight),\
        @"sharemore_videovoip", @"视频聊天", @(TAG_VideoCall),\
        @"sharemore_wallet", @"红包", @(TAG_Redpackage), \
        @"sharemorePay", @"转账", @(TAG_MoneyTransfer), \
        @"sharemore_location", @"位置", @(TAG_Location), \
        @"sharemore_myfav", @"收藏", @(TAG_Favorites), \
        @"sharemore_friendcard", @"个人名片", @(TAG_Card), \
        @"sharemore_wallet", @"卡券", @(TAG_Wallet),\
     ]

@interface LLCellData : NSObject

@property (nonatomic) NSString *imageName;

@property (nonatomic) NSString *text;

@property (nonatomic) NSInteger tag;

+ (instancetype)cellDataWithImageName:(NSString *)imageName text:(NSString *)text tag:(NSInteger)tag;

@end


@implementation LLCellData

+ (instancetype)cellDataWithImageName:(NSString *)imageName text:(NSString *)text tag:(NSInteger)tag {
    LLCellData *cellData = [[LLCellData alloc] init];
    cellData.imageName = imageName;
    cellData.text = text;
    cellData.tag = tag;

    return cellData;
}

@end



@interface LLCollectionShareCell ()

@property (nonatomic) LLCellData *data;

@property (nonatomic) UIImageView *imageView;

@property UILabel *label;

@end


@implementation LLCollectionShareCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharemore_other"]];

        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharemore_other_HL"]];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_SIZE, CELL_SIZE)];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.imageView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0,CELL_SIZE + 6, CELL_SIZE,20)];
        self.label.textColor = kLLTextColor_lightGray_5;
        self.label.font = [UIFont systemFontOfSize:13];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        
        self.hidden = YES;
    }

    return self;
}

-(void)setContent:(LLCellData *)data {
    if (_data == data) return;
    _data = data;

    if (_data) {
        self.imageView.image = [UIImage imageNamed:data.imageName];
        self.label.text = _data.text;
        self.tag = _data.tag;
        self.hidden = NO;
    }else {
        self.hidden = YES;
    }

}

@end




@interface LLShareInputView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) UIPageControl *pageControl;

@property (nonatomic) NSMutableArray *itemModels;

@end


@implementation LLShareInputView {
    NSInteger pageNum;
    NSInteger totalSection;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDatas];
        [self setupViews];
        
        self.backgroundColor = kLLBackgourndColor_inputGray;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return self;
}

- (void)updateConstraints {
    NSDictionary *views = @{@"selfView":self};
    NSDictionary *metrics = @{@"height": @(CHAT_KEYBOARD_PANEL_HEIGHT)};

    [NSLayoutConstraint activateConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selfView]|" options:kNilOptions metrics:nil views:views]];

    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView(==height)]" options:kNilOptions metrics:metrics views:views]];
    
    [super updateConstraints];
}


- (void)setupViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake (CELL_SIZE, CELL_SIZE);
    
    NSInteger gap = (SCREEN_WIDTH - CELL_SIZE * NUM_COLS) / (NUM_COLS + 1);
    layout.minimumLineSpacing = gap;
    layout.minimumInteritemSpacing = 0;
    NSInteger rgap = SCREEN_WIDTH - NUM_COLS * (gap + CELL_SIZE);
    layout.sectionInset = UIEdgeInsetsMake(14, gap, 25, rgap);

    self.collectionView = [[UICollectionView alloc]
            initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 192) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];

    [self.collectionView registerClass:[LLCollectionShareCell class] forCellWithReuseIdentifier:CELL_ID];

    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 192, SCREEN_WIDTH, 20)];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.defersCurrentPageDisplay = YES;
    [self addSubview:self.pageControl];

    self.pageControl.numberOfPages = totalSection;
    self.pageControl.currentPage = 0;
}


- (void)setupDatas {
    self.itemModels = [[NSMutableArray alloc] init];

    NSArray *items = CELL_DATA;
    for(NSInteger i = 0, r = items.count; i < r; i += 3) {
        LLCellData *model = [LLCellData cellDataWithImageName:items[i]
                                                         text:items[i+1]
                                                           tag:[items[i+2] integerValue]];

        [self.itemModels addObject:model];
    }
    pageNum = NUM_COLS * NUM_ROWS;
    totalSection = ceil((CGFloat)self.itemModels.count / pageNum);
}


#pragma mark - PageControll

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger section = scrollView.contentOffset.x / SCREEN_WIDTH;
    self.pageControl.currentPage = section;
    [self.pageControl updateCurrentPageDisplay];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger section = scrollView.contentOffset.x / SCREEN_WIDTH;
    self.pageControl.currentPage = section;
    [self.pageControl updateCurrentPageDisplay];
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return totalSection;
}

- (NSInteger)collectionView :(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return pageNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLCollectionShareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];

    NSInteger row = indexPath.item % NUM_ROWS;
    NSInteger col = indexPath.item / NUM_ROWS;
    NSInteger position = NUM_COLS * row + col;
    NSInteger newItem = position + pageNum * indexPath.section;

    LLCellData *model;
    if (newItem < self.itemModels.count)
        model = self.itemModels[newItem];
    [cell setContent:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    LLCollectionShareCell *cell = (LLCollectionShareCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate cellWithTagDidTapped:cell.tag];

}

@end
