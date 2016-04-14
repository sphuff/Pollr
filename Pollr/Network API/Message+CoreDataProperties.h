//
//  Message+CoreDataProperties.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/16/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"
#import "Answer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *createdBy;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSOrderedSet<Answer *> *answers;

@end

@interface Message (CoreDataGeneratedAccessors)

- (void)insertObject:(Answer *)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray<Answer *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(Answer *)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray<Answer *> *)values;
- (void)addAnswersObject:(Answer *)value;
- (void)removeAnswersObject:(Answer *)value;
- (void)addAnswers:(NSOrderedSet<Answer *> *)values;
- (void)removeAnswers:(NSOrderedSet<Answer *> *)values;

@end

NS_ASSUME_NONNULL_END
