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
#import "Message.h"
#import "PollrNetworkAPI.h"
#import "Chameleon.h"
#import <HexColors/HexColors.h>
#import "AddFriendViewController.h"
#import "QuestionViewController.h"

@interface FriendFeedViewController ()

@property (nonatomic, strong) NSArray *messageArray;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FriendFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor hx_colorWithHexRGBAString:@"BEE99F"]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    int collectionViewY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y + 100;
    int collectionViewHeight = self.view.frame.size.height - collectionViewY - self.tabBarController.tabBar.frame.size.height;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, self.view.frame.size.width, collectionViewHeight) collectionViewLayout:flowLayout];
    [_collectionView setBackgroundColor:[UIColor greenColor]];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    
    UIButton *addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [addFriendButton setImage:[UIImage imageNamed:@"adduser_blue25px"] forState:UIControlStateNormal];
    [addFriendButton addTarget:self action:@selector(addFriendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *addFriendButtonView = [[UIView alloc] initWithFrame:addFriendButton.frame];
    addFriendButtonView.bounds = CGRectOffset(addFriendButton.frame, -5, -5);
    [addFriendButtonView addSubview:addFriendButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addFriendButtonView];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [postButton setImage:[UIImage imageNamed:@"airplane_blue50px"] forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *postButtonView = [[UIView alloc] initWithFrame:postButton.frame];
    postButtonView.bounds = CGRectOffset(postButton.frame, -5, -5);
    [postButtonView addSubview:postButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButtonView];

    
    [_collectionView registerClass:[FriendMessageCell class] forCellWithReuseIdentifier:@"friendCell"];
    
    _colorArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < 50; i++){
        UIColor *color = [UIColor randomFlatColor];
        while([color isEqual:[UIColor flatWhiteColor]] || [color isEqual:[UIColor flatWhiteColorDark]]){
            color = [UIColor randomFlatColor];
        }
        [_colorArray addObject:color];
    }
    
    PollrNetworkAPI *api = [[PollrNetworkAPI alloc] init];
    User *user = [api getUserWithContext:self.context];
    
    [api getMessagesForUser2:user WithCompletionHandler:^(NSArray *array) {
        _messageArray = [NSArray arrayWithArray:array];
        [_collectionView reloadData];
        
    }];

    
    
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return [_messageArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"friendCell";
    
    FriendMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [cell setBackgroundColor:[_colorArray objectAtIndex:([indexPath item]%50)]];
    [cell setMessage:[_messageArray objectAtIndex:[indexPath item]]];
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

- (void)addFriendButtonPressed{
    NSLog(@"Add friend button");
    AddFriendViewController *addFriendVC = [[AddFriendViewController alloc] init];
    
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)postButtonPressed{
    NSLog(@"Post button pressed");
    
    QuestionViewController *questionVC = [[QuestionViewController alloc] init];
    questionVC.isPublic = NO;
    
    [self.navigationController pushViewController:questionVC animated:YES];
}



@end
