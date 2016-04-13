//
//  PollrNetworkAPI.h
//  Pollr
//
//  Created by Stephen Huffnagle on 2/4/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "PollrUser.h"
#import "Message.h"

@interface PollrNetworkAPI : NSObject

- (User *)getUserWithContext:(NSManagedObjectContext *)context;

- (void)deleteUsersWithContext:(NSManagedObjectContext *)context;

- (User *)getTestUserWithContext: (NSManagedObjectContext *)context;

- (void)userExists:(PollrUser *)user WithCompletionHandler:(void (^)(BOOL isAUser, BOOL correctPass, NSDictionary *dict))completion;

- (User *)saveUser:(PollrUser *)user WithContext:(NSManagedObjectContext *)context;

- (void)signupWithUser:(User *)user WithContext: (NSManagedObjectContext *)context AndWithCompletionHandler:(void (^)(BOOL signedUp, BOOL usernameTaken, BOOL serverProblem)) completion;

- (BOOL)isValidPassword:(NSString *) password;

- (BOOL)isValidEmail:(NSString *) email;

- (void)isValidUsername:(NSString *) username WithCompletionHandler:(void (^)(BOOL validUsername, BOOL serverProblem)) completion;

- (void)getMessagesForUser:(User *)user WithCompletionHandler:(void (^)(NSOrderedSet<Message *> *messageSet)) completion;
- (void)getMessagesForUser2:(User *)user WithCompletionHandler:(void (^)(NSArray *messages)) completion;

- (void)sendMessage:(NSDictionary *)message ToUser:(User *)user;

- (void)sendPublicMessage:(NSDictionary *)message;

- (void)findUsersWithUsername:(NSString *) username WithCompletionHandler:(void (^)(NSArray *users)) completion;

@end