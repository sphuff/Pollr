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

@end

@implementation PollrNetworkAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDel managedObjectContext];
    
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
    
    
    [self doNetworkOperationWithUsersandMethods:user200, status200, user404, status404, user401, status401, nil];
}

- (void) doNetworkOperationWithUsersandMethods:(id)firstArg, ...NS_REQUIRES_NIL_TERMINATION;
{
    va_list args;
    va_start(args, firstArg);
    
    NSMutableArray *userArray = [[NSMutableArray alloc] init];
    NSMutableArray *functionArray = [[NSMutableArray alloc] init];
    
    int index = 0; // keep track of position in list
    id arg = firstArg;
    while(arg != nil)
    {
        if(index%2 == 0){
            [userArray addObject:arg]; // even indeces are users
        } else {
            [functionArray addObject:arg]; // odd indeces are functions
        }
        arg = va_arg(args, id);
        index++;
    }
    
    for(int i = 0; i < [userArray count]; i++){
        XCTestExpectation *expectation = [self expectationWithDescription:@"Status Code"];
        void (^function)(PollrUser *, XCTestExpectation *) = [functionArray objectAtIndex:i];
        function([userArray objectAtIndex:i], expectation);
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
            if(error){
                NSLog(@"Timeout error : %@", [error description]);
            }
        }];
    }
}

@end
