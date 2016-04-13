//
//  AddFriendViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/12/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "AddFriendViewController.h"
#import <HexColors/HexColors.h>
#import "PollrNetworkAPI.h"

@interface AddFriendViewController ()

@property (nonatomic, strong) PollrNetworkAPI *api;
@property (nonatomic, strong) NSArray *userArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int textX = 0;
    int textY = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    int textHeight = 50;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(textX, textY, self.view.frame.size.width, textHeight)];
    [textView setBackgroundColor:[UIColor blueColor]];
    
    textView.delegate = self;
    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 5);
    
    int tableViewY = textHeight + 10 + textY;
    int tableViewHeight = self.view.frame.size.height - tableViewY - self.tabBarController.tabBar.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.frame.size.width, tableViewHeight)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addFriendCell"];
    [self.view addSubview:textView];
    [self.view addSubview:_tableView];
    
    _api = [[PollrNetworkAPI alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriendButtonPressed:(UIButton *)sender{
    NSLog(@"Selected cell %ld", (long)sender.tag);
}
#pragma mark - UITextViewDelegate Methods
- (void)textViewDidChange:(UITextView *)textView
{
    [_api findUsersWithUsername:[textView text] WithCompletionHandler:^(NSArray *users) {
        _userArray = users;
        [_tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate Methods 
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected cell %ld", (long)[indexPath item]);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"addFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell.textLabel setText:[_userArray objectAtIndex:[indexPath item]]];
    
    UIButton *addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - cell.frame.size.height, (int)cell.frame.size.height/4, 25, 25)];
    [addFriendButton setImage:[UIImage imageNamed:@"addBox25px"] forState:UIControlStateNormal];
    [addFriendButton addTarget:self action:@selector(addFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    addFriendButton.tag = [indexPath item];
    
    [cell addSubview:addFriendButton];
    return cell;
}

@end
