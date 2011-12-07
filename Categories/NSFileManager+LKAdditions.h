//
//  NSFileManager+LKAdditions.h
//  Mail Bundle Manager
//
//  Created by Scott Little on 07/12/2011.
//  Copyright (c) 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

NSInteger	const	kLKAuthenticationFailure;

#undef STR_CONST_LOCAL

@interface NSFileManager (LKAdditions)
- (BOOL)moveWithAuthenticationFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
- (BOOL)copyWithAuthenticationFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
@end
