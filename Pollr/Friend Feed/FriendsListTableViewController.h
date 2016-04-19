//
//  FriendsListTableViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 4/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsListTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *post;

@end
