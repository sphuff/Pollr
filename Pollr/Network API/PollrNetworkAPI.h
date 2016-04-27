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
#import "Friend.h"

@interface PollrNetworkAPI : NSObject

#pragma mark - Security methods
/**
 *  Encrypts password using SHA512 encoding
 *
 *  @param password The plaintext user password
 *
 *  @return The hexadecimal representation of the user's password after it is encrypted with SHA512
 */
- (NSString *)encryptPassword: (NSString *)password;

#pragma mark - User API Methods
/**
 *  Returns the user that is currently signed in through Core Data
 *
 *  @param context The current NSManagedObjectContext
 *
 *  @return The User object for the current user
 */
- (User *)getUserWithContext:(NSManagedObjectContext *)context;

/**
 *  Removes all of the users signed into Core Data. This action is performed every
 *  time the user logs out of his or her account.
 *
 *  @param context The current NSManagedObjectContext
 */
- (void)deleteUsersWithContext:(NSManagedObjectContext *)context;

/**
 *  Allows for quick login into a test account.
 *
 *  @param context The current NSManagedContext
 *
 *  @return A test User object
 */
- (User *)getTestUserWithContext: (NSManagedObjectContext *)context;

/**
 *  Saves the user to Core Data for quick loading. Currently does not account for errors in Core Data,
 *  because Core Data errors are unforgivable.
 *
 *  @param user    A PollrUser object to be saved to Core Data
 *  @param context The current NSManagedObjectContext
 *
 *  @return A User object that is saved into Core Data
 */
- (User *)saveUser:(PollrUser *)user WithContext:(NSManagedObjectContext *)context;

/**
 *  Checks to see if the username has been taken, and if not, inputs the user data in the
 *  Pollr database and saves to the client with Core Data. Inputting the user into the
 *  Pollr database involves a POST request to the server, which in turn creates a user
 *  document in the MongoDB database. A single status code is given back, which describes
 *  whether the user could be signed up, and if not, why that might be the case. As of now,
 *  unsuccessful registrations are attributed to either the username being taken, or not
 *  being able to connect with the server. Future implementations could provide further reasons
 *  for unsuccessful registrations, such as vulgar usernames and banned emails.
 *
 *  @param user       The current user to be signed up
 *  @param context    The current NSManagedObjectContext
 *  @param completion A completion handler that returns the HTTP status code for user signup
 */
- (void)signupWithUser:(PollrUser *)user WithContext: (NSManagedObjectContext *)context AndWithCompletionHandler:(void (^)(NSInteger statusCode)) completion;

/**
 *  A more client-friendly version of the userExists method. Just authenticates the user, and passes the status
 *  code back to the client. 
 *
 *  @param user       The current user
 *  @param completion A completion handler that returns the HTTP status code for JWT authentication
 */
- (void)loginWithUser: (PollrUser *)user WithCompletionHandler:(void (^)(NSInteger statusCode)) completion;

/**
 *  Currently just checks to make sure that the provided password is at least 8 characters. Later implementations
 *  could make sure that the password is secure enough, by requiring it to have at least one uppercase letter,
 *  at least one number, etc.
 *
 *  @param password A string password
 *
 *  @return A boolean value describing whether the password is at least 8 characters
 */
- (BOOL)isValidPassword:(NSString *) password;

/**
 *  Checks to make sure that the provided email has a valid .edu or .com domain. Later implementations could check whether
 *  the email has already been taken.
 *
 *  @param email A string representation of the inputed email
 *
 *  @return A boolean value describing whether the email has a value .edu or .com domain
 */
- (BOOL)isValidEmail:(NSString *) email;

/**
 *  Provides an array of users with the specified username. This method is used during registration to make sure that
 *  no two users have the same username. As of now, the method works by querying the database for the username,
 *  and by calculating the length of the resulting array. If the array has multiple entries (or just one), the username
 *  is taken and the client notifies the user. A better implementation would not return a user array for security
 *  reasons, but rather would just notify the client that the username is taken.
 *
 *  @param username   The username to be checked against
 *  @param completion A completion handler that responds back to the client with an array of current users with the
 *                    given username
 */
- (void)findUsersWithUsername:(NSString *) username WithCompletionHandler:(void (^)(NSArray *users)) completion;



# pragma mark - Message API Methods
/**
 *  Gives the public messages. Public messages are common for all users, so no User object need be provided.
 *  GETs the Public Messages from the Pollr server, which contains a Public Message MongoDB Collection.
 *
 *  @param completion A completion handler that contains an array of public messages
 */
- (void)getPublicMessagesWithCompletionHandler:(void (^)(NSArray *messages)) completion;

/**
 *  Provides an array of private messages for the current user. This method makes a GET request to the Pollr server, which in turn queries the
 *  MongoDB database. In order for a proper response, a valid User object must be provided.
 *
 *  @param user       A valid user
 *  @param completion A completion handler with an array of private messages
 */
- (void)getPrivateMessagesForUser:(User *)user WithCompletionHandler:(void (^)(NSArray *messages)) completion;

/**
 *  Sends a private message to a list of users.
 *
 *  @param message  A string message
 *  @param users    An array of recipients
 *  @param fromUser The user who is sending the message
 */
- (void)sendMessage:(NSString *)message ToUsers:(NSArray *)users fromUser:(User *)fromUser;

/**
 *  Sends a public message to all users. This is accomplished through a POST request to the Pollr server, where a new Public Message entity
 *  is created.
 *
 *  @param message A string that will be posted as a public message
 *  @param user    The user posting the public message
 */
- (void)sendPublicMessage:(NSString *)message fromUser:(User *)user;



# pragma mark - Friend API Methods
/**
 *  Adds a specified friend to the current user. Calling this method results in a POST request to the Pollr server,
 *  where the document for the user is updated. A completion handler is included so that the client can ensure that the friend
 *  was successfully added.
 *
 *  @param friend     A Friend object to be added to the user's friend list
 *  @param user       The current user
 *  @param completion A completion handler that notifies the client about a failed or successful network request
 */
- (void)addFriend:(Friend *)friend forUser:(User *) user WithCompletionHandler:(void (^)(BOOL successful)) completion;

/**
 *  Removes a specified friend from the user's friend list. A network call is performed in order to update the user's MongoDB document.
 *  A completion handler is included so that the client can be notified about a sucessful or failed update.
 *
 *  @param friend     The friend to be removed
 *  @param user       The current user
 *  @param completion A boolean completion handler to notify the client about a failed/successful update
 */
- (void)removeFriend:(Friend *)friend forUser:(User *) user WithCompletionHandler:(void (^)(BOOL successful)) completion;

/**
 *  Provides an array of friends for the specified user. Calling this methods results in a GET request to the Pollr server, which returns
 *  the "friend" data field for the current user.
 *
 *  @param user       The current user
 *  @param completion A completion handler to pass the friend array to the client
 */
- (void)getFriendsforUser:(User *) user WithCompletionHandler:(void (^)(NSArray *friendsArray)) completion;

@end