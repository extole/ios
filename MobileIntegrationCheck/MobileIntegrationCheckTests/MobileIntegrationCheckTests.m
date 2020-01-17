//
//  MobileIntegrationCheckTests.m
//  MobileIntegrationCheckTests
//
//  Created by rtibin on 9/9/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

#import <XCTest/XCTest.h>

NSString* domain = @"https://ios-santa.extole.io/";
NSString* accessToken = NULL;
NSURLSession *urlSession = NULL;

@interface MobileIntegrationCheckTests : XCTestCase

@end

@implementation MobileIntegrationCheckTests

- (void)setUp {
    XCTestExpectation *createTokenExpectation = [self expectationWithDescription:@"create token"];
    
    NSURL *tokenUrl = [NSURL URLWithString:[domain stringByAppendingString:@"/api/v4/token"]];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:tokenUrl];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPMethod:@"POST"];
    
    urlSession = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:rq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = NULL;
        NSMutableDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        accessToken = tokenResponse[@"access_token"];
        
        [createTokenExpectation fulfill];
    }];
    [task resume];

    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    XCTAssertNotNil(accessToken);
    NSLog(@"access_token = %@", accessToken);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGetCTA {
    XCTestExpectation *getCtaExpectation = [self expectationWithDescription:@"get CTA"];
    
    NSArray *dataValues = [NSArray arrayWithObjects: @"mobile,refer-a-friend", nil];
    NSArray *dataKeys = [NSArray arrayWithObjects:@"labels", nil];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:dataValues forKeys:dataKeys];
    
    NSArray *getCtaValues = [NSArray arrayWithObjects: @"mobile_menu", dataDict, nil];
    NSArray *getCtaKeys = [NSArray arrayWithObjects:@"event_name", @"data", nil];
    
    NSDictionary *getCtaDict = [NSDictionary dictionaryWithObjects:getCtaValues forKeys:getCtaKeys];
    
    NSError *jsonError = NULL;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:getCtaDict options:(0) error:&jsonError];
    
    NSURL *getCtaUrl = [NSURL URLWithString:[domain stringByAppendingString:@"/api/v6/zones"]];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:getCtaUrl];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPMethod:@"POST"];
    [rq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [rq setHTTPBody:jsonData];
    
    __block NSString* eventId;
    __block NSDictionary* ctaData;
    
    NSURLSessionDataTask *ctaTast = [urlSession dataTaskWithRequest:rq
       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           NSError *jsonError = NULL;
           NSMutableDictionary *ctaResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
           eventId = ctaResponse[@"event_id"];
           ctaData = ctaResponse[@"data"];
           XCTAssertNotNil(eventId);
           NSLog(@"event_id = %@", eventId);
           [getCtaExpectation fulfill];
       }];
    
    [ctaTast resume];
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    //
    NSLog(@"data = %@", ctaData[@"mobile_sharing_url"]);
}

- (void)testSharePage {
    XCTestExpectation *getSharePageExpectation = [self expectationWithDescription:@"share page"];
    
    NSArray *dataValues = [NSArray arrayWithObjects: @"mobile,refer-a-friend", @"lbarnett@extole.com", nil];
    NSArray *dataKeys = [NSArray arrayWithObjects:@"labels", @"email", nil];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:dataValues forKeys:dataKeys];
    
    NSArray *getCtaValues = [NSArray arrayWithObjects: @"mobile_sharing", dataDict, nil];
    NSArray *getCtaKeys = [NSArray arrayWithObjects:@"event_name", @"data", nil];
    
    NSDictionary *getCtaDict = [NSDictionary dictionaryWithObjects:getCtaValues forKeys:getCtaKeys];
    
    NSError *jsonError = NULL;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:getCtaDict options:(0) error:&jsonError];
    
    NSURL *getSharePageUrl = [NSURL URLWithString:[domain stringByAppendingString:@"/api/v6/zones"]];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:getSharePageUrl];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPMethod:@"POST"];
    [rq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [rq setHTTPBody:jsonData];
    
    __block NSString* eventId;
    __block NSDictionary* ctaData;
    
    NSURLSessionDataTask *ctaTast = [urlSession dataTaskWithRequest:rq
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      NSError *jsonError = NULL;
      NSMutableDictionary *ctaResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
      eventId = ctaResponse[@"event_id"];
      ctaData = ctaResponse[@"data"];
      XCTAssertNotNil(eventId);
      NSLog(@"event_id = %@", eventId);
      [getSharePageExpectation fulfill];
    }];
    
    [ctaTast resume];
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    //
    NSLog(@"data = %@", ctaData[@"me"][@"link"]);
}

- (void)testSignalShare {
    XCTestExpectation *eventExpectation = [self expectationWithDescription:@"signal share"];
    
    NSArray *dataValues = [NSArray arrayWithObjects: @"mobile,refer-a-friend", @"april", @"friend@example.com", @"false", nil];
    NSArray *dataKeys = [NSArray arrayWithObjects:@"labels", @"share.advocate_code", @"share.recipient", @"share.perform", nil];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:dataValues forKeys:dataKeys];
    
    NSArray *shareValues = [NSArray arrayWithObjects: @"extole.share", dataDict, nil];
    NSArray *shareKeys = [NSArray arrayWithObjects:@"event_name", @"data", nil];
    
    NSDictionary *shareDict = [NSDictionary dictionaryWithObjects:shareValues forKeys:shareKeys];
    
    NSError *jsonError = NULL;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:shareDict options:(0) error:&jsonError];
    
    NSURL *eventsUrl = [NSURL URLWithString:[domain stringByAppendingString:@"/api/v6/events"]];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:eventsUrl];
    
    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [rq setHTTPMethod:@"POST"];
    [rq setHTTPBody:jsonData];
    
    __block NSString* eventId;
    
    NSURLSessionDataTask *shareTask = [urlSession dataTaskWithRequest:rq
                                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      NSError *jsonError = NULL;
      NSMutableDictionary *ctaResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
      eventId = ctaResponse[@"event_id"];
      XCTAssertNotNil(eventId);
      NSLog(@"event_id = %@", eventId);
      [eventExpectation fulfill];
                                                  }];
    
    [shareTask resume];
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}


@end
