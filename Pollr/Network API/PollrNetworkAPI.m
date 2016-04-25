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

#pragma mark - User API Methods

- (instancetype)init{
    
    self = [super init];
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    return self;
}

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

- (User *)getTestUserWithContext: (NSManagedObjectContext *)context;{
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    user.username = @"Test1";
    user.password = @"pass123";
    user.email = @"testemail@test.com";
    
    NSError *error;
    [context save:&error];
    return user;
}

- (void)userExists:(PollrUser *)user WithCompletionHandler:(void (^)(NSInteger statusCode))completion{

    NSString *url = [NSString stringWithFormat:@"%@/userExists", BASE_URL];
    NSDictionary *userDict = @{@"username" : user.username, @"email" : user.email, @"password" : user.password};
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:userDict error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSInteger statusCode = 500;
        if(error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            statusCode = [httpResponse statusCode];
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            statusCode = [httpResponse statusCode];
        }
        completion(statusCode);
    }] resume];
}

- (User *)saveUser:(PollrUser *)user WithContext:(NSManagedObjectContext *)context{
    
    User *currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    currentUser.username = user.username;
    currentUser.password = user.password;
    currentUser.email = user.email;
    [context save:nil];
    
    return currentUser;
}

- (void)signupWithUser:(PollrUser *)user WithContext: (NSManagedObjectContext *)context AndWithCompletionHandler:(void (^)(BOOL signedUp, BOOL usernameTaken, BOOL serverProblem)) completion {
    
    [self userExists:user WithCompletionHandler:^(NSInteger statusCode) {
        __block BOOL signedUp = NO;
        if(statusCode == 404){
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:user.username, @"username", user.password, @"password", user.email, @"email", nil];
            NSString *url = [NSString stringWithFormat:@"%@/addUser/", BASE_URL];
            
            NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:params error:nil];
            
            [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if(error){
                    NSLog(@"SIGNUP ERROR: %@", [error localizedDescription]);
                } else {
                    signedUp = YES;
                    User *currentUser = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"User"
                                         inManagedObjectContext:context];
                    currentUser.username = user.username;
                    currentUser.email = user.email;
                    currentUser.password = user.password;
                    
                    NSError *error2;
                    [context save:&error2];
                }
                completion(signedUp, NO, NO);
            }] resume];
        } else if(statusCode == 500){
            signedUp = NO;
            completion(signedUp, NO, YES);
        } else {
            signedUp = NO;
            completion(signedUp, YES, NO);
        }
    }];
}

- (BOOL)isValidPassword:(NSString *) password{
    
    if([password length] < 8)
        return NO;
    return YES;
}

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



- (void)findUsersWithUsername:(NSString *) username WithCompletionHandler:(void (^)(NSArray *users)) completion{
    
    NSString *url = [NSString stringWithFormat:@"%@/allUsers/%@", BASE_URL, username];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSArray *userArray;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            // need to scan for length
            NSArray *responseArray = (NSArray *)responseObject;
            userArray = responseArray;
        }
        completion(userArray);
    }] resume];
}

#pragma mark - Message API Methods

- (void)getPublicMessagesWithCompletionHandler:(void (^)(NSArray *messages)) completion{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getPublicMessages", BASE_URL]]];
    
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSArray *messageArray;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            messageArray = (NSArray *)responseObject;
        }
        completion(messageArray);
    }] resume];
}

- (void)getPrivateMessagesForUser:(User *)user WithCompletionHandler:(void (^)(NSArray *messages)) completion{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/getPrivateMessagesFor%@", BASE_URL, user.username]]];
    
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSArray *messageArray;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            messageArray = (NSArray *)responseObject;
        }
        completion(messageArray);
    }] resume];
}

- (void)sendMessage:(NSString *)message ToUsers:(NSArray *)users fromUser:(User *)fromUser {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm.ss MM-dd-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *paramDict = @{@"createdBy": fromUser.username, @"dateCreated" : stringDate, @"text" : message, @"sentTo" : users};
    NSString *url = [NSString stringWithFormat:@"%@/sendPrivateMessage", BASE_URL];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:paramDict error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSArray *responseArray = (NSArray *)responseObject;
            NSString *messageID = responseArray[0];
            NSLog(@"Message ID: %@", messageID);
        }
    }] resume];
}

- (void)sendPublicMessage:(NSString *)message fromUser:(User *)user{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm.ss MM-dd-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *paramDict = @{@"createdBy": user.username, @"dateCreated" : stringDate, @"text" : message};
    NSString *url = [NSString stringWithFormat:@"%@/sendPublicMessage", BASE_URL];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:paramDict error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
        }
    }] resume];
}

#pragma mark - Friend API Methods

- (void)addFriend:(Friend *)friend forUser:(User *) user WithCompletionHandler:(void (^)(BOOL successful)) completion
{
    
    NSString *url = [NSString stringWithFormat:@"%@/addFriendFor%@", BASE_URL, user.username];
    NSArray *friendArray = [[NSArray alloc] initWithObjects:friend.username, nil];// must be an NSArray or NSDictionary
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:friendArray error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BOOL success = NO;
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            success = YES;
        }
        completion(success);
    }] resume];
}

- (void)removeFriend:(Friend *)friend forUser:(User *) user WithCompletionHandler:(void (^)(BOOL successful)) completion
{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/removeFriendFor%@", BASE_URL, user.username];
    NSArray *friendArray = [[NSArray alloc] initWithObjects:friend.username, nil];// must be an NSArray or NSDictionary
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"DELETE" URLString:url parameters:friendArray error:nil];
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BOOL success = NO;
        if(error){
            NSLog(@"SEND ERROR: %@", [error localizedDescription]);
        } else {
            NSDictionary *dict = (NSDictionary *)responseObject;
            success = YES;
        }
        completion(success);
    }] resume];
}

- (void)getFriendsforUser:(User *) user WithCompletionHandler:(void (^)(NSArray *friendsArray)) completion
{
    if(!_config){
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:_config];
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/friendsFor%@", BASE_URL, user.username]]];
    
    
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSArray *friendsArray;
        if(error){
            NSLog(@"LOOKUP ERROR: %@", [error localizedDescription]);
        } else {
            friendsArray = (NSArray *)responseObject;
        }
        completion(friendsArray);
    }] resume];
}





@end
