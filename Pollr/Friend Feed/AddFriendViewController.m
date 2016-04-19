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
#import "Chameleon.h"
#import "SHTextField.h"

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
    SHTextField *textField = [[SHTextField alloc] initWithFrame:CGRectMake(textX, textY, self.view.frame.size.width, textHeight)];
    [textField setBackgroundColor:[UIColor flatMintColor]];
    [textField setPlaceholder:@"Search"];
    
    textField.delegate = self;

    
    int tableViewY = textHeight + 10 + textY;
    int tableViewHeight = self.view.frame.size.height - tableViewY - self.tabBarController.tabBar.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.frame.size.width, tableViewHeight)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addFriendCell"];
    [self.view addSubview:textField];
    [self.view addSubview:_tableView];
    
    _api = [[PollrNetworkAPI alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFriendButtonPressed:(UIButton *)sender{
    NSLog(@"Selected cell %ld", (long)sender.tag);
    User *currentUser = [_api getUserWithContext:self.context];
    
    Friend *newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.context];
    newFriend.username = [_userArray objectAtIndex:sender.tag];
    
    [_api addFriend:newFriend forUser:currentUser WithCompletionHandler:^(BOOL successful) {
        if(successful){
//            [currentUser.friends setByAddingObject:newFriend];
//            NSError *error;
//            [self.context save:&error];
//            
//            NSLog(@"Data: %@", currentUser.friends);
//            for (Friend *friend in currentUser.friends) {
//                NSLog(@"Friend: %@", friend.username);
//            }
            NSLog(@"Added friend: %@", newFriend.username);
        } else {
            NSLog(@"Not able to add friend");
        }
    }];
}
#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"]){
        [textField resignFirstResponder];
    }
    [_api findUsersWithUsername:[textField text] WithCompletionHandler:^(NSArray *users) {
        _userArray = users;
        [_tableView reloadData];
    }];
    
    return YES;
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
