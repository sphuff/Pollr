//
//  Message+CoreDataProperties.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/16/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

@dynamic createdBy;
@dynamic dateCreated;
@dynamic title;
@dynamic answers;

@end
