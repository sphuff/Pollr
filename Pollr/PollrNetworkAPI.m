//
//  PollrNetworkAPI.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/4/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "PollrNetworkAPI.h"
#import <AFNetworking/AFNetworking.h>


@interface PollrNetworkAPI()

@property (strong, nonatomic) AFURLSessionManager *manager;
@property (strong, nonatomic) NSURLSessionConfiguration *config;

@end

@implementation PollrNetworkAPI


NSString * const BASE_URL = @"http://162.243.55.142:3000";

/**
 * @brief Returns the user that is currently signed in
 */

// TODO: Handle login when no user is in Core Data
- (User *)getUserWithContext:(NSManagedObjectContext *)context{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count] == 0){
        return nil;
    }
    return results[0];
}

- (void)deleteUsersWithContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *deleteError = nil;
    
    [[context persistentStoreCoordinator] executeRequest:delete withContext:context error:&deleteError];
}

- (void)userExists:(PollrUser *)user WithCompletionHandler:(void (^)(BOOL isAUser, BOOL correctPass, NSDictionary *dict))completion{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    NSString *url = [NSString stringWithFormat:@"%@/users/%@", BASE_URL, user.username];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BOOL userFound = NO;
        BOOL correctPass = YES;
        NSDictionary *userDict;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
            userFound = NO;
        } else {
            // need to scan for length
            NSArray *responseArray = (NSArray *)responseObject;
            NSDictionary *dict = [responseArray firstObject];
            if([dict count] > 0){
                userFound = YES;
                userDict = dict;
                NSString *pass = [dict objectForKey:@"password"];
                NSLog(@"Pass: %@", pass);
                if (![pass isEqual:user.password]) {
                    correctPass = NO;
                }
            }
        }
        completion(userFound, correctPass, userDict);
    }] resume];
}

- (User *)getTestUserWithContext: (NSManagedObjectContext *)context;{
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    user.username = @"Test1";
    user.password = @"pass123";
    user.email = @"testemail@test.com";
    
    NSError *error;
    [context save:&error];
    return user;
}

- (User *)saveUser:(PollrUser *)user WithContext:(NSManagedObjectContext *)context{
    User *currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    currentUser.username = user.username;
    currentUser.password = user.password;
    currentUser.email = user.email;
    [context save:nil];
    
    return currentUser;
}


/**
 * @brief Checks to see if the username has been taken, and if not, inputs the user data in the 
 * remote server and saves using Core Data
 */
- (void)signupWithUser:(User *)user WithContext: (NSManagedObjectContext *)context AndWithCompletionHandler:(void (^)(BOOL signedUp, BOOL usernameTaken, BOOL serverProblem)) completion {
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    [self isValidUsername:user.username WithCompletionHandler:^(BOOL validUsername, BOOL serverProblem) {
        if(validUsername){
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:user.username, @"username", user.password, @"password", user.email, @"email", nil];
            NSString *url = [NSString stringWithFormat:@"%@/addUser/", BASE_URL];
            
            NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:params error:nil];
            
            [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                BOOL signedUp = NO;
                if(error){
                    NSLog(@"SIGNUP ERROR: %@", [error localizedDescription]);
                } else {
                    signedUp = YES;
                    NSError *error2;
                    [context save:&error2];
                }
                completion(signedUp, !validUsername, serverProblem); // not 2nd argument based on phrasing of declaration
            }] resume];
        } else {
            BOOL signedUp = NO;
            completion(signedUp, !validUsername, serverProblem); // not 2nd argument based on phrasing of declaration
        }
    }];
}

/**
 * @brief For now, just checks to make sure that the password has at least 8 characters
 */
- (BOOL)isValidPassword:(NSString *) password{
    if([password length] < 8)
        return NO;
    return YES;
}

/**
 * @brief Checks to make sure that the email has a valid .edu or .com domain
 */
- (BOOL)isValidEmail:(NSString *) email{
    NSString *domainName = [email substringFromIndex:([email length] - 4)];
    NSRange searchRange = NSMakeRange(0, [domainName length]);
    NSError *error;
    NSString *pattern = @"\\.(edu|com)";
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* matches = [expression matchesInString:domainName options:0 range: searchRange];
   
    if([matches count] > 0){
        return YES;
    }
    return NO;
}

/**
 * @brief Checks to see if the username has been taken
 */
- (void)isValidUsername:(NSString *) username WithCompletionHandler:(void (^)(BOOL validUsername, BOOL serverProblem)) completion{
    
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/users/%@", BASE_URL, username];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BOOL isValidUsername = NO;
        BOOL serverProblem = NO;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
            serverProblem = YES;
            isValidUsername = YES;
        } else {
            // need to scan for length
            NSDictionary *dict = (NSDictionary *)responseObject;
            if([dict count] == 0){
                isValidUsername = YES;
            }
        }
        completion(isValidUsername, serverProblem);
    }] resume];
}

- (void)getMessagesForUser:(User *)user WithCompletionHandler:(void (^)(NSOrderedSet<Message *> *messageSet)) completion{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@", BASE_URL, user.username]]];
    
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *messagesRaw = (NSArray *)[[(NSArray *)dict firstObject] objectForKey:@"messages"];
            NSMutableArray *messagesCore = [[NSMutableArray alloc] init];
//            for (Message *message in messagesRaw) {
//                message.title =
//            }
            NSLog(@"messages: %@", messagesRaw);
            NSOrderedSet<Message *> *set = [[NSOrderedSet alloc] initWithArray:messagesCore];
            completion(set);
        }
    }] resume];
}

- (void)getMessagesForUser2:(User *)user WithCompletionHandler:(void (^)(NSArray *messages)) completion{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@", BASE_URL, user.username]]];
    
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *messagesRaw = (NSArray *)[[(NSArray *)dict firstObject] objectForKey:@"messages"];
//            NSMutableArray *messagesCore = [[NSMutableArray alloc] init];
//            //            for (Message *message in messagesRaw) {
//            //                message.title =
//            //            }
//            NSLog(@"messages: %@", messagesRaw);
//            NSOrderedSet<Message *> *set = [[NSOrderedSet alloc] initWithArray:messagesCore];
            completion(messagesRaw);
        }
    }] resume];
}





- (void)sendMessage:(NSDictionary *)message ToUser:(User *)user{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/sendMessageTo%@", BASE_URL, user.username];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:message error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"response: %@", dict);
        }
    }] resume];
}
- (void)sendPublicMessage:(NSDictionary *)message {
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/sendPublicMessage", BASE_URL];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:message error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"response: %@", dict);
        }
    }] resume];
}





@end
