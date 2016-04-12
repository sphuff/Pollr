//
//  PollrUser.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/22/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PollrUser : NSObject

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *username;

@end
