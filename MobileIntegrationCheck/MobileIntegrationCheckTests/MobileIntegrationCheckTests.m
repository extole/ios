//
//  MobileIntegrationCheckTests.m
//  MobileIntegrationCheckTests
//
//  Created by rtibin on 9/9/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

#import <XCTest/XCTest.h>

NSString* domain = @"https://ios-santa.extole.io/";

@interface MobileIntegrationCheckTests : XCTestCase

@end

@implementation MobileIntegrationCheckTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCreateToken {
    XCTestExpectation *createTokenExpectation = [self expectationWithDescription:@"create token"];
    
    NSURL *tokenUrl = [NSURL URLWithString:[domain stringByAppendingString:@"/api/v4/token"]];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:tokenUrl];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:rq queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSError *jsonError = NULL;
        NSMutableDictionary *allCourses = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSString* accessToken = allCourses[@"access_token"];
        XCTAssertNotNil(accessToken);
        NSLog(@"access_token = %@", accessToken);
        [createTokenExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20.0 handler:nil];

    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
