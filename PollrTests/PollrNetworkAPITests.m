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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
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
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Status Code 200"];
    
    [_api userExists:user200 WithCompletionHandler:^(NSInteger statusCode) {
        XCTAssertTrue(statusCode == 200);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Timeout error : %@", [error description]);
        }
    }];
    
    expectation = [self expectationWithDescription:@"Status Code 404"];
    
    [_api userExists:user404 WithCompletionHandler:^(NSInteger statusCode) {
        NSLog(@"statusCode: %ld", (long)statusCode);
        XCTAssertTrue(statusCode == 404);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Timeout error : %@", [error description]);
        }
    }];
    
    expectation = [self expectationWithDescription:@"Status Code 401"];
    [_api userExists:user401 WithCompletionHandler:^(NSInteger statusCode) {
        NSLog(@"statusCode: %ld", (long)statusCode);
        XCTAssertTrue(statusCode == 401);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Timeout error : %@", [error description]);
        }
    }];
}

@end
