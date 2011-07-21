//
//  NSObject+LKObject.h
//  SignatureProfiler
//
//  Created by Scott Little on 22/06/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (LKObject)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
