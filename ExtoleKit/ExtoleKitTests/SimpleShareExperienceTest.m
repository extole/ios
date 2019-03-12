//Copyright © 2019 Extole. All rights reserved.

#import <XCTest/XCTest.h>
@import ExtoleKit;

@interface SimpleShareExperienceTest : XCTestCase

@end

@implementation SimpleShareExperienceTest

- (void)testSignalShare {
    XCTestExpectation* promise = [self expectationWithDescription:@"expected share"];
    NSURL* programUrl = [[NSURL alloc] initWithString:(@"https://ios-santa.extole.io")];
    SimpleShareExperince* shareExperience = [[SimpleShareExperince alloc] initWithProgramUrl:programUrl programLabel: @"refer-a-friend"];
    [shareExperience reset];
    [shareExperience signalShareWithChannel:@"test" success:^(CustomSharePollingResult * result) {
        [promise fulfill];
    } error:^(ExtoleError * _Nonnull error) {
        XCTFail(@"unexpected error");
    }];
    [self waitForExpectationsWithTimeout:5 handler:NULL];
}

@end
