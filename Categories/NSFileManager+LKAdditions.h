//
//  NSFileManager+LKAdditions.h
//  Mail Bundle Manager
//
//  Created by Scott Little on 07/12/2011.
//  Copyright (c) 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger	const	kLKAuthenticationFailure;
extern NSInteger	const	kLKAuthenticationNotGiven;
extern NSInteger	const	kLKXPCCopyingFailure;
extern NSInteger	const	kLKPrivilegedHelperNotFound;

#undef STR_CONST_LOCAL


@interface NSFileManager (LKAdditions)

- (BOOL)moveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
- (BOOL)moveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error;
- (BOOL)copyWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
- (BOOL)copyWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error;

- (void)releaseFromQuarantine:(NSString*)root;
@end

