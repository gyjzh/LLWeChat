//
//  LLLeftAlignedCollectionViewFlowLayout.m
//  LLWeChat
//
//  Created by GYJZH on 9/23/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//


#import "LLLeftAlignedCollectionViewFlowLayout.h"
#import "LLUtils.h"

@interface LLLeftAlignedCollectionViewFlowLayout ()

@property (nonatomic) NSMutableDictionary<NSNumber*, NSValue*> *itemFrames;

@end

@implementation LLLeftAlignedCollectionViewFlowLayout {
    UIEdgeInsets sectionInset;
}


- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemFrames = [NSMutableDictionary dictionary];
    sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (UICollectionElementCategoryCell == attributes.representedElementCategory) {
            NSIndexPath* indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return attributesToReturn;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect currentFrame = currentItemAttributes.frame;
     if (self.itemFrames[@(indexPath.row)]) {
         currentFrame.origin = [self.itemFrames[@(indexPath.row)] CGPointValue];
         currentItemAttributes.frame = currentFrame;
         return currentItemAttributes;
    }
    
    if (indexPath.item == 0) { 
        self.itemFrames[@(indexPath.item)] = [NSValue valueWithCGPoint:currentFrame.origin];
        return currentItemAttributes;
    }
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + self.minimumInteritemSpacing;

    if (previousFrameRightPoint + currentFrame.size.width >= self.collectionView.bounds.size.width + FLT_EPSILON - sectionInset.right) {
        currentFrame.origin.x = sectionInset.left;
        currentItemAttributes.frame = currentFrame;
        self.itemFrames[@(indexPath.item)] = [NSValue valueWithCGPoint:currentFrame.origin];
        return currentItemAttributes;
    }
    
    currentFrame.origin.x = previousFrameRightPoint;
    currentItemAttributes.frame = currentFrame;
    self.itemFrames[@(indexPath.item)] = [NSValue valueWithCGPoint:currentFrame.origin];
    return currentItemAttributes;
}

@end
