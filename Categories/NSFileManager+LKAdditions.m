//
//  NSFileManager+LKAdditions.m
//  Mail Bundle Manager
//
//  Created by Scott Little on 07/12/2011.
//  Copyright (c) 2011 Little Known Software. All rights reserved.
//

#import "NSFileManager+LKAdditions.h"
#import "NSString+LKHelper.h"

#import <ServiceManagement/ServiceManagement.h>
#import <sys/stat.h>
#import <sys/xattr.h>
#import <objc/runtime.h>


#define AUTH_EXPIRATION_TIME	(60 * 60 * 5)	//	5 minutes

NSInteger	const	kLKAuthenticationFailure = 30001;
NSInteger	const	kLKAuthenticationNotGiven = 30002;
NSInteger	const	kLKXPCCopyingFailure = 30003;
NSInteger	const	kLKPrivilegedHelperNotFound = 30004;


@interface NSFileManager (LKPrivate) 
- (void)deauthorize:(NSTimer *)theTimer;
- (BOOL)fileMoveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath shouldCopy:(BOOL)shouldCopy overwrite:(BOOL)shouldOverwrite error:(NSError **)error;
- (BOOL)executeWithForcedAuthenticationFromPath:(NSString *)src toPath:(NSString *)dst shouldCopy:(BOOL)shouldCopy error:(NSError **)error;
- (int)removeXAttr:(const char*)name fromFile:(NSString*)file options:(int)options;
@end


@implementation NSFileManager (LKAdditions)

#pragma mark - Authentication External Methods

- (BOOL)moveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
	return [self fileMoveWithAuthenticationIfNeededFromPath:fromPath toPath:toPath shouldCopy:NO overwrite:YES error:error];
}

- (BOOL)moveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error {
	return [self fileMoveWithAuthenticationIfNeededFromPath:fromPath toPath:toPath shouldCopy:NO overwrite:shouldOverwrite error:error];
}

- (BOOL)copyWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
	return [self fileMoveWithAuthenticationIfNeededFromPath:fromPath toPath:toPath shouldCopy:YES overwrite:YES error:error];
}

- (BOOL)copyWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error {
	return [self fileMoveWithAuthenticationIfNeededFromPath:fromPath toPath:toPath shouldCopy:YES overwrite:shouldOverwrite error:error];
}

- (void)releaseFromQuarantine:(NSString*)root {
	
	const char* quarantineAttribute = "com.apple.quarantine";
	const int removeXAttrOptions = XATTR_NOFOLLOW;
	
	[self removeXAttr:quarantineAttribute
			 fromFile:root
			  options:removeXAttrOptions];
	
	// Only recurse if it's actually a directory.  Don't recurse into a
	// root-level symbolic link.
	NSDictionary* rootAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:root error:nil];
	NSString* rootType = [rootAttributes objectForKey:NSFileType];
	
	if (rootType == NSFileTypeDirectory) {
		// The NSDirectoryEnumerator will avoid recursing into any contained
		// symbolic links, so no further type checks are needed.
		NSDirectoryEnumerator* directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:root];
		NSString* file = nil;
		while ((file = [directoryEnumerator nextObject])) {
			[self removeXAttr:quarantineAttribute
					 fromFile:[root stringByAppendingPathComponent:file]
					  options:removeXAttrOptions];
		}
	}
}



@end



#pragma mark - Extended Attributes

@implementation NSFileManager (LKInternal)

#pragma mark - Work Methods

- (BOOL)fileMoveWithAuthenticationIfNeededFromPath:(NSString *)fromPath toPath:(NSString *)toPath shouldCopy:(BOOL)shouldCopy overwrite:(BOOL)shouldOverwrite error:(NSError **)error {
	
	NSError		*localError = nil;
	BOOL		needsSecureMove = NO;
	
	//	Remove any existing file at destPath
	if ([self fileExistsAtPath:toPath]) {
		if (shouldOverwrite) {
			if (![self removeItemAtPath:toPath error:&localError]) {
				
				switch ([localError code]) {
					case NSFileWriteVolumeReadOnlyError:
					case NSFileWriteOutOfSpaceError:
						//	Cannot continue if this is the case, just return the error
						if (error != NULL) {
							*error = localError;
						}
						return NO;
						break;
						
					case NSFileLockingError:
					case NSFileReadUnknownError:
					case NSFileReadNoPermissionError:
					case NSFileWriteUnknownError:
					case NSFileWriteNoPermissionError:
						needsSecureMove = YES;
						break;
						
						//Can be safely ignored
					case NSFileNoSuchFileError:
					case NSFileReadNoSuchFileError:
					case NSFileWriteInvalidFileNameError:
					case NSFileReadInvalidFileNameError:
					default:
						break;
				}
			}
		}
		else {
			//	Create a new error message to return
			return NO;
		}
	}
	
	//	Try to just do the move simply
	if (!needsSecureMove) {
		BOOL	didSucceed = NO;
		if (shouldCopy) {
			didSucceed = [self copyItemAtPath:fromPath toPath:toPath error:&localError];
		}
		else {
			didSucceed = [self moveItemAtPath:fromPath toPath:toPath error:&localError];
		}
		if (!didSucceed) {
			
			switch ([localError code]) {
					
				case NSFileLockingError:
				case NSFileReadUnknownError:
				case NSFileReadNoPermissionError:
				case NSFileWriteUnknownError:
				case NSFileWriteNoPermissionError:
				case 13:	//	POSIX "permission denied"
					needsSecureMove = YES;
					break;
					
					//	Cannot continue if these are the case
				case NSFileWriteVolumeReadOnlyError:
				case NSFileWriteOutOfSpaceError:
					//	These are also non-solvable errors
				case NSFileNoSuchFileError:
				case 2:	//	POSIX "no such file or directory"
				case NSFileReadNoSuchFileError:
				case NSFileWriteInvalidFileNameError:
				case NSFileReadInvalidFileNameError:
					//	Unknown errors
				default:
					//	Just return the error and write message
					LKErr(@"Error %@ bundle (enable/disable):%@", (shouldCopy?@"copying":@"moving"), localError);
					if(error != NULL) {
						*error = localError;
					}
					return NO;
					break;
			}
		}
	}
	
	if (needsSecureMove) {
		LKLog(@"No Access for %@", toPath);
		
		// use a static because we only really need to get the version once.
		static NSInteger minVersion = 0;  // 0 == notSet
		if (minVersion == 0) {
			SInt32 version = 0;
			OSErr err = Gestalt(gestaltSystemVersionMinor, &version);
			if (!err) {
				minVersion = (NSInteger)version;
			}
		}
		
		if (![self executeWithXPCAuthenticationFromPath:fromPath toPath:toPath shouldCopy:shouldCopy shouldOverwrite:shouldOverwrite error:error]) {
			LKErr(@"Error %@ bundle (enable/disable)", (shouldCopy?@"copying":@"moving"));
			return NO;
		}
	}
	
	return YES;
}


#pragma mark - XPC Stuff

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>


- (void)sendSyncXPCMessage:(xpc_object_t)message forLabel:(NSString *)label timeout:(NSTimeInterval)aTimeout replyHandler:(xpc_handler_t)handler {
	
	xpc_connection_t connection = xpc_connection_create_mach_service([label UTF8String], NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
	
	if (!connection) {
		NSLog(@"Failed to create XPC connection.");
		return;
	}
	
	xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
		xpc_type_t type = xpc_get_type(event);
		
		if (type == XPC_TYPE_ERROR) {
			
			if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
				NSLog(@"XPC connection interupted.");
				
			} else if (event == XPC_ERROR_CONNECTION_INVALID) {
				NSLog(@"XPC connection invalid, releasing.");
				xpc_release(connection);
				
			} else {
				NSLog(@"Unexpected XPC connection error.");
			}
			
		} else {
			NSLog(@"Unexpected XPC connection event.");
		}
	});
	
	xpc_connection_resume(connection);
	
	NSLog(@"XPC connection PID:%@", [NSNumber numberWithInt:xpc_connection_get_pid(connection)]);
	
	BOOL		__block	xpcCallFinished = NO;
	xpc_connection_send_message_with_reply(connection, message, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(xpc_object_t object) {
		handler(object);
		xpcCallFinished = YES;
	});
	
	if (aTimeout < 0.05) {
		aTimeout = 10.0;
	}
	NSTimeInterval	pollingLimit = [NSDate timeIntervalSinceReferenceDate] + aTimeout;
	while (!xpcCallFinished) {
		[NSThread sleepForTimeInterval:0.05];
		if ([NSDate timeIntervalSinceReferenceDate] > pollingLimit) {
			xpcCallFinished = YES;
		}
	}
	
	xpc_connection_cancel(connection);
}

- (BOOL)executeWithXPCAuthenticationFromPath:(NSString *)src toPath:(NSString *)dst shouldCopy:(BOOL)shouldCopy shouldOverwrite:(BOOL)shouldOverwrite error:(NSError **)error {

	//	Get the name from the Info plist
	static	NSString	*label = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (label == nil) {
			NSDictionary	*helpers = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SMPrivilegedExecutables"];
			for (NSString *key in [helpers allKeys]) {
				if ([key hasPrefix:@"com.littleknownsoftware.MPC.CopyMoveHelper"]) {
					label = [key copy];
					break;
				}
			}
		}
	});
	
	NSError	*newError = nil;
	if (label == nil) {
		NSLog(@"Could not get the proper label to use");
		newError = [NSError errorWithDomain:kLKErrorDomain code:kLKPrivilegedHelperNotFound userInfo:@{NSLocalizedDescriptionKey: @"Could not find the Privileged Executable for installation over file you don't have access to."}];
		*error = newError;
		return NO;
	}
	
	NSError	*testError = nil;
	if (![self blessHelperWithLabel:label error:&testError]) {
		NSLog(@"Failed to bless helper. Error: %@", testError);
		newError = [NSError errorWithDomain:kLKErrorDomain code:kLKAuthenticationNotGiven userInfo:@{NSLocalizedDescriptionKey: @"User did not give proper access."}];
		*error = newError;
		return NO;
	}
	
	xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
	xpc_dictionary_set_string(message, "sourcePath", [src UTF8String]);
	xpc_dictionary_set_string(message, "destPath", [dst UTF8String]);
	xpc_dictionary_set_bool(message, "shouldCopy", (bool)shouldCopy);
	xpc_dictionary_set_bool(message, "shouldOverwrite", (bool)shouldOverwrite);
	xpc_dictionary_set_bool(message, "getVersion", (bool)NO);
	
	BOOL __block	wasSuccessful = NO;

	[self sendSyncXPCMessage:message forLabel:label timeout:20.0 replyHandler:^(xpc_object_t object) {
		wasSuccessful = (BOOL)xpc_dictionary_get_bool(object, "reply");
		if (!wasSuccessful) {
			NSString	*errorMessage = [NSString stringWithUTF8String:xpc_dictionary_get_string(object, "error")];
			NSError	*newError = [NSError errorWithDomain:kLKErrorDomain code:kLKXPCCopyingFailure userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
			*error = newError;
		}
	}];
	
	return wasSuccessful;
}

- (NSUInteger)installedHelperBuildVersionNumberForLabel:(NSString *)label {
	
	xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
	xpc_dictionary_set_bool(message, "getVersion", (bool)YES);
	
	NSUInteger	__block	buildVersion = 0;
	[self sendSyncXPCMessage:message forLabel:label timeout:2.0 replyHandler:^(xpc_object_t object) {
		buildVersion = (NSUInteger)xpc_dictionary_get_int64(object, "buildVersion");
	}];
	
	return buildVersion;
}

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)error {
    
	BOOL result = NO;
	CFDictionaryRef	jobDict = SMJobCopyDictionary(kSMDomainSystemLaunchd, (CFStringRef)label);
	if (jobDict) {
		
		NSUInteger	buildNumber = [self installedHelperBuildVersionNumberForLabel:label];
		if (buildNumber >= [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] integerValue]) {
			CFRelease(jobDict);
			return YES;
		}
	}
	
	AuthorizationItem	authItem	= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights	authRights	= { 1, &authItem };
	AuthorizationFlags	flags		=	kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
	
	AuthorizationRef authRef = NULL;
	
	/* Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper). */
	OSStatus	status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status != errAuthorizationSuccess) {
		NSString	*errorMessage = [NSString stringWithFormat:@"Failed to create AuthorizationRef. Error code: %d", (int)status];
		NSLog(@"Failed to create AuthorizationRef. Error code: %d", (int)status);
		NSError		*newError = [NSError errorWithDomain:kLKErrorDomain code:kLKAuthenticationNotGiven userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
		*error = newError;
		
	} else {
		/* This does all the work of verifying the helper tool against the application
		 * and vice-versa. Once verification has passed, the embedded launchd.plist
		 * is extracted and placed in /Library/LaunchDaemons and then loaded. The
		 * executable is placed in /Library/PrivilegedHelperTools.
		 */
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)label, authRef, (CFErrorRef *)error);
	}
	
	return result;
}


#pragma mark - Extended Attributes

- (int)removeXAttr:(const char*)name fromFile:(NSString*)file options:(int)options {
	
	typedef int (*removexattr_type)(const char*, const char*, int);
	// Reference removexattr directly, it's in the SDK.
	static removexattr_type removexattr_func = removexattr;
	
	// Make sure that the symbol is present.  This checks the deployment
	// target instead of the SDK so that it's able to catch dlsym failures
	// as well as the null symbol that would result from building with the
	// 10.4 SDK and a lower deployment target, and running on 10.3.
	if (!removexattr_func) {
		errno = ENOSYS;
		return -1;
	}
	
	const char* path = NULL;
	@try {
		path = [file fileSystemRepresentation];
	}
	@catch (id exception) {
		// -[NSString fileSystemRepresentation] throws an exception if it's
		// unable to convert the string to something suitable.  Map that to
		// EDOM, "argument out of domain", which sort of conveys that there
		// was a conversion failure.
		errno = EDOM;
		return -1;
	}
	
	return removexattr_func(path, name, options);
}

@end


