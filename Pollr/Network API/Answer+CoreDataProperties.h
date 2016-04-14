//
//  Answer+CoreDataProperties.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/16/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Answer.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Answer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *createdBy;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) Message *message;

@end

NS_ASSUME_NONNULL_END
