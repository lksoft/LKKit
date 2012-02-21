//
//  NSFileManager+LKAdditions.m
//  Mail Bundle Manager
//
//  Created by Scott Little on 07/12/2011.
//  Copyright (c) 2011 Little Known Software. All rights reserved.
//

#import "NSFileManager+LKAdditions.h"
#import "NSString+LKHelper.h"

#import <sys/stat.h>


#define AUTH_EXPIRATION_TIME	(60 * 60 * 5)	//	5 minutes


NSInteger	const	kLKAuthenticationFailure = 30001;
NSInteger	const	kLKAuthenticationNotGiven = 30002;

//	Function to authorize
static BOOL AuthorizationExecuteWithPrivilegesAndWait(AuthorizationRef authorization, const char* executablePath, AuthorizationFlags options, const char* const* arguments);

//	Static variable to allow for a period of time that the authorization is valid for
static	AuthorizationRef	MBMAuthorization = NULL;
static	dispatch_queue_t	MBMAuthorizationCreationQueue = NULL;

@interface NSFileManager (LKInternal)
- (void)deauthorize:(NSTimer *)theTimer;
- (BOOL)executeWithForcedAuthenticationFromPath:(NSString *)src toPath:(NSString *)dst move:(BOOL)shouldMove error:(NSError **)error;
- (void)releaseFromQuarantine:(NSString*)root;
@end


@implementation NSFileManager (LKAdditions)

#pragma mark - Authentication External Methods

- (BOOL)moveWithAuthenticationFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error {
	
	//	Ensure that the user has access to both paths
	if ([fromPath userHasAccessRights] && [toPath userHasAccessRights]) {
		//	Remove any existing file at destPath
		if ((shouldOverwrite) && [self fileExistsAtPath:toPath]) {
			if (![self removeItemAtPath:toPath error:error]) {
				return NO;
			}
		}
		//	Just do the move simply
		if (![self moveItemAtPath:fromPath toPath:toPath error:error]) {
			LKErr(@"Error moving bundle (enable/disable):%@", *error);
			return NO;
		}
	}
	else {
		//	Otherwise use the authentication mechanism
		if (![self executeWithForcedAuthenticationFromPath:fromPath toPath:toPath move:YES error:error]) {
			LKErr(@"Error moving bundle (enable/disable):%@", *error);
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)copyWithAuthenticationFromPath:(NSString *)fromPath toPath:(NSString *)toPath overwrite:(BOOL)shouldOverwrite error:(NSError **)error {
	
	//	Ensure that the user has access to both paths
	if ([fromPath userHasAccessRights] && [toPath userHasAccessRights]) {
		//	Remove any existing file at destPath
		if ((shouldOverwrite) && [self fileExistsAtPath:toPath]) {
			if (![self removeItemAtPath:toPath error:error]) {
				return NO;
			}
		}
		//	Just do the copy simply
		if (![self copyItemAtPath:fromPath toPath:toPath error:error]) {
			ALog(@"Error copying bundle (enable/disable):%@", *error);
			return NO;
		}
	}
	else {
		//	Otherwise use the authentication mechanism
		if (![self executeWithForcedAuthenticationFromPath:fromPath toPath:toPath move:NO error:error]) {
			if ([*error code] != kLKAuthenticationNotGiven) {
				ALog(@"Error copying bundle (enable/disable):%@", *error);
			}
			return NO;
		}
	}
	
	return YES;
}


@end



#pragma mark - Extended Attributes

#import <sys/xattr.h>

@implementation NSFileManager (LKInternal)

#pragma mar - Work Methods

- (void)deauthorize:(NSTimer *)theTimer {
	
	LKAssert(MBMAuthorizationCreationQueue != NULL, @"The Authorization queue is not valid inside a deauthorize call");
	
	dispatch_sync(MBMAuthorizationCreationQueue, ^{
		if (MBMAuthorization != NULL) {
			AuthorizationFree(MBMAuthorization, 0);
			MBMAuthorization = NULL;
		}
	});
}

- (BOOL)executeWithForcedAuthenticationFromPath:(NSString *)src toPath:(NSString *)dst move:(BOOL)shouldMove error:(NSError **)error {
	const char* srcPath = [src fileSystemRepresentation];
	const char* dstPath = [dst fileSystemRepresentation];
	
	//	Get the destinations user info in case it is needed
	struct stat dstSB;
	stat(dstPath, &dstSB);
	
	//	Create our queue if it hasn't been done already
	static	dispatch_once_t		once;
	dispatch_once(&once, ^{ MBMAuthorizationCreationQueue = dispatch_queue_create("com.littleknownsoftware.MBMAuthorizationCreation", NULL); });
	
	//	Create our authorization if we don't have one (use a block here)
	__block OSStatus authStat = errAuthorizationDenied;
	dispatch_sync(MBMAuthorizationCreationQueue, ^{
		if (MBMAuthorization == NULL) {
			while (authStat == errAuthorizationDenied) {
				authStat = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &MBMAuthorization);
			}
			
			//	If the auth was successful, set up a timer to deauthorize soon
			if (authStat == errAuthorizationSuccess) {
				//	Then create a timer that will release the Authorization in 5 minutes
				[NSTimer scheduledTimerWithTimeInterval:AUTH_EXPIRATION_TIME target:self selector:@selector(deauthorize:) userInfo:nil repeats:NO];
			}
			else {
				//	Reset the Authorization to NULL to be sure
				MBMAuthorization = NULL;
			}
		}
		else {
			authStat = errAuthorizationSuccess;
		}
	});
	
	BOOL res = NO;
	if (authStat == errAuthorizationSuccess) {
		res = YES;
		
		char uidgid[42];
		snprintf(uidgid, sizeof(uidgid), "%d:%d",
				 dstSB.st_uid, dstSB.st_gid);
		
		//	Test to see if a destination path exists and set command to remove
		char	*removeCommand = NULL;
		char	*chownCommand = NULL;
		if ([self fileExistsAtPath:dst]) {
			removeCommand = "/bin/rm";
			chownCommand = "/usr/sbin/chown";
		}
		//	Then set the command for the copy/move
		char	*executeCommand = "/bin/cp";
		char	*args = "-Rf";
		if (shouldMove) {
			executeCommand = "/bin/mv";
			args = "-f";
		}
		
		const char* executables[] = {
			removeCommand,
			executeCommand,
			NULL,  // pause here and do some housekeeping before
			NULL,
			// continuing
			chownCommand,
			NULL   // stop here for real
		};
		
		// 4 is the maximum number of arguments to any command,
		// including the NULL that signals the end of an argument
		// list.
		const char* const argumentLists[][4] = {
			{ "-rf", dstPath, NULL },  // rm
			{ args, srcPath, dstPath, NULL },  // mv/cp
			{ NULL },  // pause
			{ "-R", uidgid, dstPath, NULL },  // chown
			{ NULL }  // stop
		};
		
		// Process the commands up until the first NULL
		unsigned int commandIndex = 0;
		//	If the removeDest value is NULL, skip the first executable
		if (removeCommand == NULL) {
			commandIndex++;
		}
		for (; executables[commandIndex] != NULL; ++commandIndex) {
			if (res) {
				res = AuthorizationExecuteWithPrivilegesAndWait(MBMAuthorization, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
			}
		}
		
		// If the currently-running application is trusted, the new
		// version should be trusted as well.  Remove it from the
		// quarantine to avoid a delay at launch, and to avoid
		// presenting the user with a confusing trust dialog.
		//
		// This needs to be done after the application is moved to its
		// new home with "mv" in case it's moved across filesystems: if
		// that happens, "mv" actually performs a copy and may result
		// in the application being quarantined.  It also needs to be
		// done before "chown" changes ownership, because the ownership
		// change will almost certainly make it impossible to change
		// attributes to release the files from the quarantine.
		if (res) {
			[self performSelectorOnMainThread:@selector(releaseFromQuarantine:) withObject:dst waitUntilDone:YES];
		}
		
		// Now move past the NULL we found and continue executing
		// commands from the list.
		++commandIndex;
		
		for (; executables[commandIndex] != NULL; ++commandIndex) {
			if (res) {
				res = AuthorizationExecuteWithPrivilegesAndWait(MBMAuthorization, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
			}
		}
		
		if (!res)
		{
			// Something went wrong somewhere along the way, but we're not sure exactly where.
			NSString *errorMessage = [NSString stringWithFormat:@"Authenticated file copy from %@ to %@ failed.", src, dst];
			if (error != nil)
				*error = [NSError errorWithDomain:kLKErrorDomain code:kLKAuthenticationFailure userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
		}
	}
	else
	{
		if (error != nil)
			*error = [NSError errorWithDomain:kLKErrorDomain code:kLKAuthenticationNotGiven userInfo:[NSDictionary dictionaryWithObject:@"Couldn't get permission to authenticate." forKey:NSLocalizedDescriptionKey]];
	}
	return res;
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


#pragma mark - Authentication Helper Function

static BOOL AuthorizationExecuteWithPrivilegesAndWait(AuthorizationRef authorization, const char* executablePath, AuthorizationFlags options, const char* const* arguments) {
	
	sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
	BOOL returnValue = YES;
	
	if (AuthorizationExecuteWithPrivileges(authorization, executablePath, options, (char* const*)arguments, NULL) == errAuthorizationSuccess) {
		int status;
		pid_t pid = wait(&status);
		if (pid == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0)
			returnValue = NO;
	}
	else
		returnValue = NO;
	
	signal(SIGCHLD, oldSigChildHandler);
	return returnValue;
}


