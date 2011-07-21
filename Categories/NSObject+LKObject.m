//
//  NSObject+LKObject.m
//  SignatureProfiler
//
//  Created by Scott Little on 22/06/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "NSObject+LKObject.h"




/* NSObject+LKObject.m */

#import "NSObject+LKObject.h"


@implementation NSObject (LKObject)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	int64_t delta = (int64_t)(1.0e9 * delay);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

@end
