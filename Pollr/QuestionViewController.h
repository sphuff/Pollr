//
//  QuestionViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 12/16/15.
//  Copyright (c) 2015 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionViewController : UIViewController <UITextViewDelegate>

@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
