//
//  RWDummySignInService.m
//  Reactive Cocoa Example
//
//  Created by Kelin Christi on 21/02/2016.
//  Copyright (c) 2016 Kelz. All rights reserved.
//

#import "RWDummySignInService.h"

@implementation RWDummySignInService


- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignInResponse)completeBlock {

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [username isEqualToString:@"user"] && [password isEqualToString:@"password"];
        completeBlock(success);
    });
}


@end
