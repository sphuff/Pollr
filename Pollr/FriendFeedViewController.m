//
//  FriendFeedControllerViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/6/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "FriendFeedViewController.h"
#import "CardLayout.h"
#import "FriendMessageCell.h"

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    int collectionViewY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y + 100;
    int collectionViewHeight = self.view.frame.size.height - collectionViewY;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, self.view.frame.size.width, collectionViewHeight) collectionViewLayout:flowLayout];
    [collectionView setBackgroundColor:[UIColor greenColor]];
    collectionView.dataSource = self;
    collectionView.delegate = self;

    
    [collectionView registerClass:[FriendMessageCell class] forCellWithReuseIdentifier:@"friendCell"];
    
    
    [self.view addSubview:collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return 20;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"friendCell";
    FriendMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods 

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell");
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Deselected cell");
}

#pragma mark - UICollectionViewFlowLayoutDelegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return -10.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(collectionView.frame.size.width, (int)collectionView.frame.size.height/5);
    return size;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(5.0, 2.0, 10, 2.0);
//}



@end
