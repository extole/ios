//Copyright © 2019 Extole. All rights reserved.

#import <XCTest/XCTest.h>
@import ExtoleKit;

@interface SimpleShareExperienceTestC : XCTestCase

@end

@interface TestErrorHandler : NSObject <ExtoleApiErrorHandler>
    @property (strong, nonatomic) XCTestCase *testCase;
    - (instancetype)initWithTest:(XCTestCase*) testCase;
@end

@implementation TestErrorHandler

- (instancetype)initWithTest:(XCTestCase *)testCase {
    _testCase = testCase;
    return self;
}

- (void)decodingErrorWithData:(NSData * _Nonnull)data {
    _XCTPrimitiveFail(_testCase, @"decodingErrorWithData");
}

- (void)genericErrorWithErrorData:(ExtoleError * _Nonnull)errorData {
    _XCTPrimitiveFail(_testCase, @"genericErrorWithErrorData");
}

- (void)noContent {
    _XCTPrimitiveFail(_testCase, @"noContent");
}

- (void)serverErrorWithError:(NSError * _Nonnull)error {
    _XCTPrimitiveFail(_testCase, @"serverErrorWithError");
}

@end

@implementation SimpleShareExperienceTestC

- (void)testSignalShare {
    XCTestExpectation* promise = [self expectationWithDescription:@"expected share"];
    ExtoleShareExperince* shareExperience = [[ExtoleShareExperince alloc] initWithProgramDomain:@"ios-santa.extole.io" programLabel: @"refer-a-friend"];
    [shareExperience reset];
    CustomShare* share = [[CustomShare alloc] initWithChannel:@"test"];
    [shareExperience notifyWithShare:share success:^(CustomSharePollingResult * result) {
        [promise fulfill];
    } error:^(ExtoleError * _Nonnull error) {
        XCTFail(@"unexpected error");
    }];
    [self waitForExpectationsWithTimeout:5 handler:NULL];
}

- (void) testFetchSettings {
    XCTestExpectation* promise = [self expectationWithDescription:@"expected share"];
    ExtoleShareExperince* shareExperience = [[ExtoleShareExperince alloc] initWithProgramDomain:@"ios-santa.extole.io" programLabel: @"refer-a-friend"];
    [shareExperience reset];
    
    TestErrorHandler* errorHandler = [[TestErrorHandler alloc] init];
    
    [shareExperience fetchDictionaryWithZone:@"settings" parameters: NULL  success:^(NSDictionary * _Nonnull dict) {
            XCTAssertEqualObjects(@"Share message", dict[@"shareMessage"]);
            [promise fulfill];
        } error:errorHandler];
    [self waitForExpectationsWithTimeout:5 handler:NULL];
}

@end
