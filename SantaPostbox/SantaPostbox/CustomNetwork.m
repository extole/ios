//Copyright © 2019 Extole. All rights reserved.

#import <Foundation/Foundation.h>
@import ExtoleKit;

@interface CustomNetwork: NSObject <NetworkExecutor>

@end

@implementation CustomNetwork

- (void)dataTaskWith:(NSURLRequest * _Nonnull)request completionHandler:(void (^ _Nonnull)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLSession* session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration. ephemeralSessionConfiguration];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

@end
