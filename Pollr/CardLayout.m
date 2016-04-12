//
//  CardLayout.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/7/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "CardLayout.h"

@implementation CardLayout

#pragma mark - UICollectionViewLayout Methods

//- (CGSize)collectionViewContentSize

//- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
//    NSArray<UICollectionViewLayoutAttributes *> *temp;
//    return temp;
//}


#pragma mark - UICollectionViewFlowLayoutDelegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(collectionView.frame.size.width, 20);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 2.0, 10, 2.0);
}

@end
