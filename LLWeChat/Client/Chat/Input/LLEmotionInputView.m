//
//  LLEmotionInputView.m
//  LLWeChat
//
//  Created by GYJZH on 7/29/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLEmotionInputView.h"
#import "LLEmotionModelManager.h"
#import "LLConfig.h"
#import "LLUtils.h"
#import "LLCollectionEmotionCell.h"
#import "LLColors.h"
#import "UIKit+LLExt.h"

#define GIF_CELL_SIZE 62

#define TOP_AREA_HEIGHT 170
#define BOTTOM_AREA_HEIGHT 37
#define MIDDLE_AREA_HEIGHT 10
#define BOTTOM_BUTTON_WIDTH 45

#define ROWS_EMOJI 3
#define ROWS_GIF 2

static NSInteger number_per_line_emoji;
static NSInteger number_per_line_gif;




@interface LLSectionData : NSObject

@property (nonatomic) LLEmotionGroupModel *groupModel;

@property (nonatomic) NSInteger sectionIndex;

@property (nonatomic) NSInteger totalSections;

@property (nonatomic) NSInteger startSection;

@property (nonatomic) NSInteger pageNum;

@property (nonatomic) NSInteger totalItem;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic) NSInteger minimumLineSpacing;

@property (nonatomic) NSInteger minimumInteritemSpacing;

@end


@implementation LLSectionData

- (instancetype)initWithEmotionGroupModel:(LLEmotionGroupModel *)model {
    self = [super init];
    if (self) {
        _groupModel = model;

        self.totalItem = _groupModel.allEmotionModels.count;

        if (_groupModel.type == kLLEmotionTypeEmoji) { //3:2
            CGFloat hgap = [LLUtils pixelAlignForFloat:(SCREEN_WIDTH - number_per_line_emoji * EMOJI_IMAGE_SIZE) /(number_per_line_emoji + 2)];
            
            CGFloat itemWidth = EMOJI_IMAGE_SIZE + hgap;
            CGFloat itemHeight = EMOJI_IMAGE_SIZE + 18;

            self.itemSize = CGSizeMake(itemWidth, itemHeight);
            self.minimumLineSpacing = 0;
            self.minimumInteritemSpacing = 0;
            CGFloat hgapl = hgap;
            CGFloat hgapr = SCREEN_WIDTH - number_per_line_emoji * itemWidth - hgapl;
            CGFloat vgapt = [LLUtils pixelAlignForFloat:(TOP_AREA_HEIGHT - ROWS_EMOJI * itemHeight) / 2];
            CGFloat vgapb = TOP_AREA_HEIGHT - ROWS_EMOJI * itemHeight - vgapt;
            self.sectionInset = UIEdgeInsetsMake(vgapt, hgapl, vgapb, hgapr);

            self.pageNum = number_per_line_emoji * ROWS_EMOJI;
            self.totalItem = _groupModel.allEmotionModels.count;
            self.totalSections = ceil((CGFloat)self.totalItem / (self.pageNum - 1));
        }else if (_groupModel.type == kLLEmotionTypeFacialGif) { //2:1
            NSInteger recommendWidth = (SCREEN_WIDTH - 8 * (number_per_line_gif + 3)) / number_per_line_gif;
            if (GIF_CELL_SIZE < recommendWidth)
                recommendWidth = GIF_CELL_SIZE;
     
            NSInteger hgap = [LLUtils pixelAlignForFloat:((SCREEN_WIDTH - number_per_line_gif * recommendWidth) /(number_per_line_gif + 3))];
            self.itemSize = CGSizeMake(recommendWidth, recommendWidth + 16);
            self.minimumLineSpacing = hgap;
            self.minimumInteritemSpacing = 0;
            CGFloat hgapr = SCREEN_WIDTH - number_per_line_gif * recommendWidth - (number_per_line_gif + 1) * hgap;
            self.sectionInset = UIEdgeInsetsMake(7, hgap * 2, 4, hgapr);

            self.pageNum = number_per_line_gif * ROWS_GIF;
            self.totalItem = _groupModel.allEmotionModels.count;
            self.totalSections = ceil((CGFloat)self.totalItem / self.pageNum);
        }
    }

    return self;
}


@end




@interface LLEmotionInputView () <UICollectionViewDelegate, UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) NSArray<LLEmotionGroupModel *> *emotionGroups;

@property (nonatomic) NSMutableArray<LLSectionData *> *sectionDatas;

@property (nonatomic) UICollectionViewFlowLayout *layout;

@property (nonatomic) UIPageControl *pageControl;

@property (nonatomic) id<ILLEmotionTipDelegate> touchView;

@property (nonatomic) UIScrollView *bottomScrollView;

@property (nonatomic) UIButton *settingButton;

@property (nonatomic) UIButton *sendButton;

@property (nonatomic) UIButton *curSelectButton;

@end



@implementation LLEmotionInputView

+ (instancetype)sharedInstance {
    static LLEmotionInputView *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLEmotionInputView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CHAT_KEYBOARD_PANEL_HEIGHT)];
    });
    
    return _instance;
}


- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = BOTTOM_AREA_HEIGHT + TOP_AREA_HEIGHT + MIDDLE_AREA_HEIGHT;
    self = [super initWithFrame:frame];
    if (self) {
        self.emotionGroups = [LLEmotionModelManager sharedManager].allEmotionGroups;

        if (SCREEN_WIDTH >= 414)
            number_per_line_emoji = 9;
        else
            number_per_line_emoji = 8;

        number_per_line_gif = 5;

        [self setupView];
        self.backgroundColor = kLLBackgourndColor_inputGray;
        
        [self registerGestureRecognizer];
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

- (void)setupView {

    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc]
            initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOP_AREA_HEIGHT) collectionViewLayout:self.layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;

    [self addSubview:_collectionView];

    [self.collectionView registerClass:[LLCollectionEmojiCell class] forCellWithReuseIdentifier:EMOTION_COLLECTION_EMOJI_CELL_ID];
    [self.collectionView registerClass:[LLCollectionGifCell class] forCellWithReuseIdentifier:EMOTION_COLLECTION_GIF_CELL_ID];

    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, TOP_AREA_HEIGHT - 2, SCREEN_WIDTH, MIDDLE_AREA_HEIGHT)];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.defersCurrentPageDisplay = YES;
    [self addSubview:self.pageControl];

    self.sectionDatas = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (int i=0; i< _emotionGroups.count; i++) {
        LLEmotionGroupModel *model = _emotionGroups[i];
        LLSectionData *sectionData = [[LLSectionData alloc] initWithEmotionGroupModel:model];
        sectionData.startSection = index;
        index += sectionData.totalSections;
        sectionData.sectionIndex = i;

        [self.sectionDatas addObject:sectionData];
    }
    
    
    [self setupBottomViews];

    [self updatePageController:0];
}

- (void)setupBottomViews {
    CGFloat _top = TOP_AREA_HEIGHT + MIDDLE_AREA_HEIGHT;
    CGFloat _rwidth = 47;

    UIButton *plusButton = [self createButtonWithImage:@"EmotionsBagAdd" widthIndex:0];
    plusButton.frame = CGRectMake(0, _top, BOTTOM_BUTTON_WIDTH, BOTTOM_AREA_HEIGHT);
    [self addSubview:plusButton];

    self.bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(BOTTOM_BUTTON_WIDTH, _top, SCREEN_WIDTH - BOTTOM_BUTTON_WIDTH - _rwidth, BOTTOM_AREA_HEIGHT )];
    self.bottomScrollView.showsHorizontalScrollIndicator = NO;
    self.bottomScrollView.showsVerticalScrollIndicator = NO;
    self.bottomScrollView.pagingEnabled = NO;
    self.bottomScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomScrollView];


    for (NSInteger i = 0; i < _emotionGroups.count; i++) {
        UIButton *button = [self createButtonWithImage:_emotionGroups[i].groupIconName widthIndex:i];
        button.frame = CGRectMake(i * BOTTOM_BUTTON_WIDTH, 0, BOTTOM_BUTTON_WIDTH, BOTTOM_AREA_HEIGHT);
        
        button.tag = i;
        [button addTarget:self action:@selector(gotoSection:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomScrollView addSubview:button];
    }
    self.bottomScrollView.contentSize = CGSizeMake(BOTTOM_BUTTON_WIDTH * _emotionGroups.count, BOTTOM_AREA_HEIGHT);

    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnGrey"] forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"EmotionsSetting"] forState:UIControlStateNormal];
    self.settingButton.frame = CGRectMake(SCREEN_WIDTH - _rwidth,_top, _rwidth, BOTTOM_AREA_HEIGHT);
    self.settingButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [self addSubview:self.settingButton];

    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnBlue"] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnBlueHL"] forState:UIControlStateHighlighted];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"EmotionsSendBtnGrey"] forState:UIControlStateDisabled];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.sendButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.sendButton.enabled = NO;
    [self.sendButton addTarget:self action:@selector(sendHandler:) forControlEvents:UIControlEventTouchUpInside];

    self.sendButton.frame = CGRectMake(SCREEN_WIDTH - 55, _top,  55, BOTTOM_AREA_HEIGHT);
    [self addSubview:self.sendButton];
}

- (UIButton *)createButtonWithImage:(NSString *)imageName widthIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    //右侧加一条竖线
    CALayer *line = [CALayer layer];
    line.backgroundColor = kLLBackgroundColor_lightGray.CGColor;
    line.frame = CGRectMake(BOTTOM_BUTTON_WIDTH - 1,(BOTTOM_AREA_HEIGHT - 25) / 2, 1, 25);
    [button.layer addSublayer:line];

    return button;
}

- (void)sendEnabled:(BOOL)enabled {
    self.sendButton.enabled = enabled;
}

- (void)sendHandler:(UIButton *)sender {
    [self.delegate sendCellDidSelected];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    LLSectionData *lastSectionData = [self.sectionDatas lastObject];
    return lastSectionData.totalSections + lastSectionData.startSection;
}

- (LLSectionData *)sectionDataForSection:(NSInteger)section {
    NSInteger index = 0;
    for (LLSectionData * sectionData in _sectionDatas) {
        index += sectionData.totalSections;

        if (section < index)
            return sectionData;
    }

    return nil;
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    LLSectionData *sectionData = [self sectionDataForSection:section];

    return sectionData.pageNum;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLSectionData *sectionData = [self sectionDataForSection:indexPath.section];

    return sectionData.itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    LLSectionData *sectionData = [self sectionDataForSection:section];

    return sectionData.sectionInset;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
            layout:(UICollectionViewLayout *)collectionViewLayout
      minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    LLSectionData *sectionData = [self sectionDataForSection:section];

    return sectionData.minimumInteritemSpacing;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
        layout:(UICollectionViewLayout *)collectionViewLayout
        minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    LLSectionData *sectionData = [self sectionDataForSection:section];

    return sectionData.minimumLineSpacing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLSectionData *sectionData = [self sectionDataForSection:indexPath.section];

    if (sectionData.groupModel.type == kLLEmotionTypeEmoji) {
        LLCollectionEmojiCell *cell = [self.collectionView
                dequeueReusableCellWithReuseIdentifier:EMOTION_COLLECTION_EMOJI_CELL_ID
                                          forIndexPath:indexPath];

        NSInteger row = indexPath.item % ROWS_EMOJI;
        NSInteger col = indexPath.item / ROWS_EMOJI;
        NSInteger position = number_per_line_emoji * row + col;
        NSInteger newItem = position + (sectionData.pageNum - 1) * (indexPath.section - sectionData.startSection);

        if (newItem < sectionData.totalItem) {
            if (position == sectionData.pageNum - 1) {
                cell.isDelete = YES;
            }else {
                LLEmotionModel *model = sectionData.groupModel.allEmotionModels[newItem];
                [cell setContent:model];
            }
        }else if (newItem == sectionData.totalItem) {
            cell.isDelete = YES;
        }else {
            [cell setContent:nil];
        }

        return cell;
    }
    else if (sectionData.groupModel.type == kLLEmotionTypeFacialGif) {
        LLCollectionGifCell *cell = [self.collectionView
                dequeueReusableCellWithReuseIdentifier:EMOTION_COLLECTION_GIF_CELL_ID
                                          forIndexPath:indexPath];

        NSInteger row = indexPath.item % ROWS_GIF;
        NSInteger col = indexPath.item / ROWS_GIF;
        NSInteger position = number_per_line_gif * row + col;
        NSInteger newItem = position + sectionData.pageNum * (indexPath.section - sectionData.startSection);

        LLEmotionModel *model;
        if (newItem < sectionData.totalItem)
            model = sectionData.groupModel.allEmotionModels[newItem];
        [cell setContent:model];

        return cell;
    }

    return nil;
}


#pragma mark - PageControll

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSInteger section = scrollView.contentOffset.x / SCREEN_WIDTH;
        [self updatePageController:section];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.collectionView) {
        NSInteger section = scrollView.contentOffset.x / SCREEN_WIDTH;
        [self updatePageController:section];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSInteger section = scrollView.contentOffset.x / SCREEN_WIDTH;
        [self updatePageController:section];
    }
}

- (void)updatePageController:(NSInteger)section {
    LLSectionData *sectionData = [self sectionDataForSection:section];

    self.pageControl.numberOfPages = sectionData.totalSections;
    self.pageControl.currentPage = section - sectionData.startSection;

    [self.pageControl updateCurrentPageDisplay];

    if (sectionData.sectionIndex == 0 && self.sendButton.hidden == YES) {
        self.sendButton.hidden = NO;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.sendButton.right_LL = SCREEN_WIDTH;
                         }
                         completion:nil];
    } else if (sectionData.sectionIndex > 0 && self.sendButton.hidden == NO) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.sendButton.left_LL = SCREEN_WIDTH;
                         }
                         completion:^(BOOL finished) {
                             self.sendButton.hidden = YES;
                         }];
    }
    
    self.curSelectButton = self.bottomScrollView.subviews[sectionData.sectionIndex];

}

- (void)gotoSection:(UIButton *)button {
    if (button.isSelected) return;
    LLSectionData *sectionData = self.sectionDatas[button.tag];
    
    [self.collectionView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * sectionData.startSection, 0, SCREEN_WIDTH, TOP_AREA_HEIGHT) animated:NO];
    [self updatePageController:sectionData.startSection];
}

- (void)setCurSelectButton:(UIButton *)curSelectButton {
    if (curSelectButton == _curSelectButton)
        return;
    
    _curSelectButton.selected = NO;
    _curSelectButton.backgroundColor = [UIColor whiteColor];
    _curSelectButton = curSelectButton;
    _curSelectButton.selected = YES;
    _curSelectButton.backgroundColor = kLLBackgroundColor_lightGray;
    
    [self.bottomScrollView scrollRectToVisible:_curSelectButton.frame animated:YES];
}

#pragma mark - TIPs

- (void)registerGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;

    [self.collectionView addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(longPressHandler:)];
    longPress.allowableMovement = 10000;
    longPress.minimumPressDuration = 0.5;

    [self.collectionView addGestureRecognizer:longPress];


}

- (UIView *)subViewAtPoint:(CGPoint)point {
    if (point.y <= 0)return nil;
    for (UIView *view in self.collectionView.subviews) {
        CGPoint localPoint = [view convertPoint:point fromView:self.collectionView];
        if ([view pointInside:localPoint withEvent:nil]) {
            return view;
        }
    }
    return nil;
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    UIView *touchView = [self subViewAtPoint:point];
    if (!touchView) return;

    if ([touchView isKindOfClass:[LLCollectionEmojiCell class]]) {
        LLCollectionEmojiCell *cell = (LLCollectionEmojiCell *)touchView;
        if (cell.isDelete) {
            [self.delegate deleteCellDidSelected];
        }else {
            [self.delegate emojiCellDidSelected:cell.emotionModel];
        }
    }else {
        [self.delegate gifCellDidSelected:((LLCollectionGifCell *)touchView).emotionModel];
    }
    

}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:longPress.view];
    id<ILLEmotionTipDelegate> touchView = (id<ILLEmotionTipDelegate>)[self subViewAtPoint:point];

    if (longPress.state == UIGestureRecognizerStateEnded) {
        [_touchView didMoveOut];
    }else {
        if (touchView == _touchView) return;
        [_touchView didMoveOut];
        _touchView = touchView;
        [_touchView didMoveIn];
    }
    
}

@end



