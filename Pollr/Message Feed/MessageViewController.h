//
//  MessageViewController.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/11/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UIColor *messageViewColor;
@property (nonatomic, strong) NSDictionary *messageDict;


-(instancetype) initWithDict:(NSDictionary *)dict;
@end
