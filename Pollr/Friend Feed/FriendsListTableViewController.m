//
//  FriendsListTableViewController.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "FriendsListTableViewController.h"
#import "PollrNetworkAPI.h"

@interface FriendsListTableViewController ()

@property (nonatomic, strong) NSArray *friendArray;
@property (nonatomic, strong) NSMutableArray *selectedFriends;
@property (nonatomic, strong) PollrNetworkAPI *api;

@end

@implementation FriendsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _api = [[PollrNetworkAPI alloc] init];
    User *currentUser = [_api getUserWithContext:self.context];
    
    [_api getFriendsforUser:currentUser WithCompletionHandler:^(NSArray *friendsArray) {
        if(friendsArray){
            _friendArray = friendsArray;
            [self.tableView reloadData];
        }
    }];
    
    _selectedFriends = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed)];
    rightButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = rightButton;

    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"friendCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendButtonPressed
{
    NSLog(@"Pressed send button");
    User *currentUser = [_api getUserWithContext:self.context];
    [_api sendMessage:self.post ToUsers:_selectedFriends fromUser:currentUser];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friendArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"friendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",[_friendArray objectAtIndex:indexPath.item]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.navigationItem.rightBarButtonItem.isEnabled){
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    NSLog(@"Selected cell at %lu", [indexPath item]);
    [_selectedFriends addObject:[_friendArray objectAtIndex:[indexPath item]]];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
