//
//  AddFriendViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 4/12/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
