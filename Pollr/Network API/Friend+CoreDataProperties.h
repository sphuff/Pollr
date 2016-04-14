//
//  Friend+CoreDataProperties.h
//  Pollr
//
//  Created by Stephen Huffnagle on 4/14/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Friend.h"

NS_ASSUME_NONNULL_BEGIN

@interface Friend (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;

@end

NS_ASSUME_NONNULL_END
