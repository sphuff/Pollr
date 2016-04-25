//
//  MessageFeedViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/8/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "MessageFeedViewController.h"
#import "HexColors.h"
#import "Chameleon.h"
#import "PollrNetworkAPI.h"
#import "PublicMessageCell.h"
#import "MessageViewController.h"
#import "QuestionViewController.h"
#import "ViewController.h"


@interface MessageFeedViewController() {
    int viewWidth;
    int viewHeight;
}

// TODO: Refresh when scroll to top

@property (nonatomic, strong) PollrNetworkAPI *api;
@property (nonatomic, strong) NSArray *messageArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIColor *backgroundColor;
@end

@implementation MessageFeedViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _api = [[PollrNetworkAPI alloc] init];
    _backgroundColor = [UIColor hx_colorWithHexRGBAString:@"E4DCDC"];
    [self.navigationController.navigationBar setBarTintColor:[UIColor hx_colorWithHexRGBAString:@"BEE99F"]];
    

    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.minimumColumnSpacing = 20.0;
    layout.minimumInteritemSpacing = 20.0;
    layout.sectionInset = UIEdgeInsetsMake((int) 10.0,(int) 20.0,(int) 10.0,(int) 20.0);
 
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.collectionView setBackgroundColor:_backgroundColor];

    [self.view addSubview:_collectionView];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [postButton setImage:[UIImage imageNamed:@"airplane_blue50px"] forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIView *postButtonView = [[UIView alloc] initWithFrame:postButton.frame];
    postButtonView.bounds = CGRectOffset(postButton.frame, -5, -5);
    [postButtonView addSubview:postButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButtonView];
    
    [_api getPublicMessagesWithCompletionHandler:^(NSArray *messages) {
        _messageArray = [NSArray arrayWithArray:messages];
        [self.collectionView reloadData];
    }];
    
    [self.collectionView registerClass:[PublicMessageCell class] forCellWithReuseIdentifier:@"messageCell"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor hx_colorWithHexRGBAString:@"6482AD"];
    
    User *currentUser = [_api getUserWithContext:self.context];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor hx_colorWithHexRGBAString:@"6482AD"], NSForegroundColorAttributeName,
                                                          nil]];
    [self.navigationItem setTitle:currentUser.username];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_messageArray count];
}


-  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"messageCell";
    PublicMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.userImageView = nil;
    
    NSDictionary *dict = [_messageArray objectAtIndex:[indexPath item]];
    [cell setMessage:dict];
    
    return (UICollectionViewCell *)cell;
}

- (CGPoint) roundedCenterPoint: (CGPoint)pt {
    return CGPointMake(round(pt.x), round(pt.y));
}

- (void) postButtonPressed{
    NSLog(@"Pressed post button");
    QuestionViewController *questionVC = [[QuestionViewController alloc] init];
    questionVC.isPublic = YES;
    questionVC.context = self.context;
    
    [self.navigationController pushViewController:questionVC animated:NO];
}

- (void)logout{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    [_api deleteUsersWithContext:self.context];
    ViewController *VC = [[ViewController alloc] init];
    //    [self presentViewController:VC animated:NO completion:nil];
    [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
}

# pragma mark - UICollectionViewDelegate

/**
 * @brief When called, animates a UIView and transitions to the MessageViewController.
 */

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    PublicMessageCell *selectedCell = (PublicMessageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect frame = selectedCell.frame;
    UIColor *cellColor = selectedCell.backgroundColor;
    UIView *ghostView = [[UIView alloc] initWithFrame:frame];
    ghostView.backgroundColor = cellColor;
    ghostView.layer.cornerRadius = 5.0;
    
    [self.collectionView addSubview:ghostView];
    
    // Hides the selected cell, creates a UIView over it, and animates the UIView
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [ghostView setFrame:CGRectMake(10, 10, ghostView.frame.size.width, ghostView.frame.size.height)];
        selectedCell.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            [selectedCell setUserInteractionEnabled:NO];
            int navBarHeight = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
            NSDictionary *dict = [_messageArray objectAtIndex:[indexPath item]];
            
            MessageViewController *messageVC = [[MessageViewController alloc] initWithDict:dict];
            messageVC.messageView = [[UIView alloc] initWithFrame:CGRectMake(10, navBarHeight + 10, viewWidth - 20, viewHeight/3)];
            [messageVC.messageView setBackgroundColor:cellColor];
            messageVC.messageView.layer.cornerRadius = 5.0;
            
            [self.navigationController pushViewController:messageVC animated:NO];
            [selectedCell setUserInteractionEnabled:YES];
            selectedCell.alpha = 1.0;

            [ghostView removeFromSuperview];
            
        }
    }];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deselected cell number : %ld", (long)[indexPath item]);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath{
    cell.alpha = 0.0;
    [UIView animateWithDuration:2.0 delay:0.1 * indexPath.row options:0 animations:^{
        cell.alpha = 1.0;
    } completion:nil];
}

# pragma mark - CHTCollectionViewWaterfallLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [[_messageArray objectAtIndex:[indexPath item]] objectForKey:@"text"];
    // find number of lines in the cell
    int lineCount = 1;
    int charCount = 0;
    
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [title componentsSeparatedByCharactersInSet:separators];
    
    for (NSString *word in words) {
        charCount += [word length];
        charCount++;
        if(charCount > 11){
            charCount = [word length];
            lineCount++;
        }
    }
    CGFloat height = lineCount * 22 + 10 + arc4random_uniform(20) + 61;
//    CGFloat height = lineCount * 22 + 10 + 51;
    return CGSizeMake(viewWidth/2 - 30, height);
    
}


@end
