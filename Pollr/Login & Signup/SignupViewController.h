//
//  SignupViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 12/17/15.
//  Copyright (c) 2015 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
