//
//  RWDummySignInService.h
//  Reactive Cocoa Example
//
//  Created by Kelin Christi on 21/02/2016.
//  Copyright (c) 2016 Kelz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RWSignInResponse)(BOOL);

@interface RWDummySignInService : NSObject

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
                    //Completion Block.
                  complete:(RWSignInResponse)completeBlock;

@end
