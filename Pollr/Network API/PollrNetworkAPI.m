//
//  PollrNetworkAPI.m
//  Pollr
//
//  Created by Stephen Huffnagle on 2/4/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import "PollrNetworkAPI.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <SimpleKeychain/SimpleKeychain.h>



@interface PollrNetworkAPI()

@property (strong, nonatomic) AFURLSessionManager *manager;
@property (strong, nonatomic) NSURLSessionConfiguration *config;

@end

@implementation PollrNetworkAPI


NSString * const BASE_URL = @"https://pollr.info/api";

#pragma mark - Security methods
- (NSString *)encryptPassword: (NSString *)password
{
    const char *s = [password cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    
    CC_SHA512(keyData.bytes, keyData.length, digest);
    NSData *hashedPass = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    NSString *hashedString = [[hashedPass description] stringByTrimmingCharactersInSet:charsToRemove];;
    hashedString = [hashedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return hashedString;
}
/**
 *  Authenticates the user using Auth0's JWT framework. If the user provides a valid username and password,
 *  he or she is allocated a JWT, which is stored in the SimpleKeychain for later use. Each network call
 *  wil rely upon JWT authentication, so I made a conscious decision to encapsulate it from the client side
 *  for added security. If the user wants to authenticate, he or she will do so through the signup or login
 *  methods rather than directly through this method.
 *
 *  @param user       The current user
 *  @param completion A completion handler that returns a status code
 */
- (void)authenticateUser: (PollrUser *)user WithCompletionHandler: (void (^)(NSInteger statusCode))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/authenticate", BASE_URL];
    NSDictionary *paramDict = @{@"username" : user.username, @"password" : user.password};

    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:paramDict error:nil];
    NSString* newStr = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [urlResponse statusCode];
        if(statusCode == 404 || statusCode == 401){
            NSLog(@"Error: %@", [responseDict objectForKey:@"message"]);
        } else {
            NSLog(@"Successful authentication");
            NSString *jwt = [responseDict objectForKey:@"token"];
            [[A0SimpleKeychain keychain] setString:jwt forKey:@"auth0-user-jwt"];
        }
        completion(statusCode);
    }] resume];
}
/*
*   A simple helper method to set the JWT for each network request
*/
- (void)setTokenForHeader: (NSMutableURLRequest *)request
{
    [request setValue:[[A0SimpleKeychain keychain] stringForKey:@"auth0-user-jwt"] forHTTPHeaderField:@"token"];
}

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

- (User *)saveUser:(PollrUser *)user WithContext:(NSManagedObjectContext *)context{
    
    User *currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    currentUser.username = user.username;
    currentUser.password = user.password;
    currentUser.email = user.email;
    [context save:nil];
    
    return currentUser;
}

- (void)signupWithUser:(PollrUser *)user WithContext: (NSManagedObjectContext *)context AndWithCompletionHandler:(void (^)(NSInteger statusCode)) completion {
    PollrUser *signupUser = [PollrUser alloc];
    signupUser.username = @"signupUser";
    signupUser.password = @"signuppassword";
    
    [self authenticateUser:signupUser WithCompletionHandler:^(NSInteger statusCode) {
        if(statusCode == 200){
            [self findUsersWithUsername:user.username WithCompletionHandler:^(NSArray *users) {
                if([users count] > 0){
                    completion(401);
                } else {
                    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:user.username, @"username", user.password, @"password", user.email, @"email", nil];
                    NSString *url = [NSString stringWithFormat:@"%@/addUser/", BASE_URL];
                    
                    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:params error:nil];
                    [self setTokenForHeader:request];
                    
                    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                        NSInteger statusCode = [urlResponse statusCode];
                        completion(statusCode);
                    }] resume];
                }
            }];
        } else {
            completion(statusCode);
        }
    }];
}

- (void)loginWithUser: (PollrUser *)user WithCompletionHandler:(void (^)(NSInteger statusCode)) completion
{
    [self authenticateUser:user WithCompletionHandler:^(NSInteger statusCode) {
        completion(statusCode);
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
    [self setTokenForHeader:request];
    
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
    
    NSLog(@"Token %@", [[A0SimpleKeychain keychain] stringForKey:@"token"]);
    NSString *url = [NSString stringWithFormat:@"%@/getPublicMessages", BASE_URL];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    [self setTokenForHeader:request];
    NSLog(@"Header: %@", request.allHTTPHeaderFields);
    
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
    [self setTokenForHeader:request];
    
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
    [self setTokenForHeader:request];
    
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
    [self setTokenForHeader:request];
    
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
    [self setTokenForHeader:request];
    
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
    [self setTokenForHeader:request];
    
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
    [self setTokenForHeader:request];
    
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
