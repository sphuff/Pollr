//
//  LoginPopover.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/22/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIERealTimeBlurView.h"

@interface LoginPopover : UIView

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSMutableArray *subviewArray;

@end
