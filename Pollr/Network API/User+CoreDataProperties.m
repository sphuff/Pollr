//
//  User+CoreDataProperties.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

@dynamic email;
@dynamic password;
@dynamic username;
@dynamic friends;
@dynamic messages;

@end
