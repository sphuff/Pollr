//
//  PollrNetworkAPITests.m
//  Pollr
//
//  Created by Stephen Huffnagle on 4/23/16.
//  Copyright © 2016 Stephen Huffnagle. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PollrNetworkAPI.h"
#import "AppDelegate.h"

@interface PollrNetworkAPITests : XCTestCase

@property (nonatomic, strong) PollrNetworkAPI *api;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation PollrNetworkAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    _context = [appDel managedObjectContext];
    
    _api = [[PollrNetworkAPI alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testUserExists {
    PollrUser *user200 = [[PollrUser alloc] init];
    user200.username = @"Test1";
    user200.email = @"email";
    user200.password = @"password";
    
    PollrUser *user404 = [[PollrUser alloc] init];
    user404.username = @"Test14124234";
    user404.email = @"email";
    user404.password = @"password";
    
    PollrUser *user401 = [[PollrUser alloc] init];
    user401.username = @"Test1";
    user401.email = @"email";
    user401.password = @"wrongPass";
    
    typedef void (^ExistsBlock)(PollrUser *, XCTestExpectation *);
    
    ExistsBlock status200 = ^(PollrUser *user, XCTestExpectation *expectationArg){[_api userExists:user WithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 200);
        [expectationArg fulfill];
    }];};
    
    ExistsBlock status404 = ^(PollrUser *user, XCTestExpectation *expectationArg){[_api userExists:user WithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 404);
        [expectationArg fulfill];
    }];};
    
    ExistsBlock status401 = ^(PollrUser *user, XCTestExpectation *expectationArg){[_api userExists:user WithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 401);
        [expectationArg fulfill];
    }];};
    
    
    [self doNetworkOperationWithArgsandMethods:user200, status200, user404, status404, user401, status401, nil];
}

- (void)testIsValidEmail
{
    NSString *emailCorrect = @"test@richmond.edu";
    NSString *emailWrongDomain = @"test@richmond.ru";
    
    XCTAssertTrue([_api isValidEmail:emailCorrect]);
    XCTAssertFalse([_api isValidEmail:emailWrongDomain]);
}

- (void)testIsValidPassword
{
    NSString *passwordCorrect = @"testpass101";
    NSString *passwordWrongLength = @"test";
    
    XCTAssertTrue([_api isValidPassword:passwordCorrect]);
    XCTAssertFalse([_api isValidPassword:passwordWrongLength]);
}

- (void)testSignup
{
    PollrUser *validUser = [[PollrUser alloc] init];
    validUser.username = [NSString stringWithFormat:@"Test%d", arc4random_uniform(30000)];
    NSLog(@"username: %@", validUser.username);
    validUser.email = @"test@testemail.com";
    validUser.password = @"testpass1";
    
    PollrUser *invalidUser = [[PollrUser alloc] init];
    invalidUser.username = @"Testuser1";
    invalidUser.email = @"test@testemail.com";
    invalidUser.password = @"testpass1";
    
    typedef void (^SignupTest)(PollrUser *, XCTestExpectation *);

    
    SignupTest pass = ^(PollrUser *user, XCTestExpectation *expectation){[_api signupWithUser:user WithContext:self.context AndWithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 404);
        [expectation fulfill];
    }];};
    
    SignupTest usernameInUse = ^(PollrUser *user, XCTestExpectation *expectation){[_api signupWithUser:user WithContext:self.context AndWithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 200);
        [expectation fulfill];
    }];};
    
    [self doNetworkOperationWithArgsandMethods:validUser, pass, invalidUser, usernameInUse, nil];
}

- (void)testFindUsers
{
    PollrUser *validUser = [[PollrUser alloc] init];
    validUser.username = @"Test123456";
    validUser.email = @"test@testemail.com";
    validUser.password = @"testpass1";
    
    PollrUser *invalidUser = [[PollrUser alloc] init];
    invalidUser.username = [NSString stringWithFormat:@"Test%d", arc4random_uniform(30000)];
    invalidUser.email = @"test@testemail.com";
    invalidUser.password = @"testpass1";
    
    typedef void (^FindUsers)(PollrUser *, XCTestExpectation *);
    
    FindUsers existingUser = ^(PollrUser *user, XCTestExpectation *expectation){[_api findUsersWithUsername:user.username WithCompletionHandler:^(NSArray *users) {
        XCTAssertTrue([users count] == 1);
        [expectation fulfill];
    }];};
    
    FindUsers nonexistantUser = ^(PollrUser *user, XCTestExpectation *expectation){[_api findUsersWithUsername:user.username WithCompletionHandler:^(NSArray *users) {
        XCTAssertTrue([users count] == 0);
        [expectation fulfill];
    }];};
    
    [self doNetworkOperationWithArgsandMethods:validUser, existingUser, invalidUser, nonexistantUser, nil];
}

/**
 *  Performs a network operation given a list of arguments and methods. There can only be one argument per method (unless
 *  the method block is passed multiple arguments), and they must be passed in as arguments and methods in an alternating
 *  fashion. Also, the list must be nil-terminated. This method makes it unnecessary to initialize multiple 
 *  XCTestExpectations for multiple network calls.
 *
 *  Example:
 *  [self doNetworkOperationWithArgsandMethods:arg1, method1, arg2, method2, nil];
 *
 *  @param firstArg The first argument in the list of arguments and methods
 */
- (void) doNetworkOperationWithArgsandMethods:(id)firstArg, ...NS_REQUIRES_NIL_TERMINATION;
{
    va_list args;
    va_start(args, firstArg);
    
    NSMutableArray *argArray = [[NSMutableArray alloc] init];
    NSMutableArray *functionArray = [[NSMutableArray alloc] init];
    
    int index = 0; // keep track of position in list
    id arg = firstArg;
    while(arg != nil)
    {
        if(index%2 == 0){
            [argArray addObject:arg]; // even indeces are users
        } else {
            [functionArray addObject:arg]; // odd indeces are functions
        }
        arg = va_arg(args, id);
        index++;
    }
    
    for(int i = 0; i < [argArray count]; i++){
        XCTestExpectation *expectation = [self expectationWithDescription:@"Status Code"];
        void (^function)(id, XCTestExpectation *) = [functionArray objectAtIndex:i];
        function([argArray objectAtIndex:i], expectation);
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
            if(error){
                NSLog(@"Timeout error : %@", [error description]);
            }
        }];
    }
}

@end
