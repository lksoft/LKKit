//
//  NSFileManager+LKAdditions.m
//  Mail Bundle Manager
//
//  Created by Scott Little on 07/12/2011.
//  Copyright (c) 2011 Little Known Software. All rights reserved.
//

#import "NSFileManager+LKAdditions.h"

#import <sys/stat.h>


NSInteger	const	kLKAuthenticationFailure = 30001;

//	Function to authorize
static BOOL AuthorizationExecuteWithPrivilegesAndWait(AuthorizationRef authorization, const char* executablePath, AuthorizationFlags options, const char* const* arguments);

@interface NSFileManager (LKExtendedAttributes)
- (void)releaseFromQuarantine:(NSString*)root;
@end


@implementation NSFileManager (LKAdditions)


- (BOOL)moveWithForcedAuthenticationFromPath:(NSString *)src toPath:(NSString *)dst error:(NSError **)error {
	const char* srcPath = [src fileSystemRepresentation];
	const char* dstPath = [dst fileSystemRepresentation];
	
	struct stat dstSB;
	stat(dstPath, &dstSB);
	
	AuthorizationRef auth = NULL;
	OSStatus authStat = errAuthorizationDenied;
	while (authStat == errAuthorizationDenied) {
		authStat = AuthorizationCreate(NULL,
									   kAuthorizationEmptyEnvironment,
									   kAuthorizationFlagDefaults,
									   &auth);
	}
	
	BOOL res = NO;
	if (authStat == errAuthorizationSuccess) {
		res = YES;
		
		char uidgid[42];
		snprintf(uidgid, sizeof(uidgid), "%d:%d",
				 dstSB.st_uid, dstSB.st_gid);
		
		const char* executables[] = {
			"/bin/mv",
			NULL,  // pause here and do some housekeeping before
			// continuing
			"/usr/sbin/chown",
			NULL   // stop here for real
		};
		
		// 4 is the maximum number of arguments to any command,
		// including the NULL that signals the end of an argument
		// list.
		const char* const argumentLists[][4] = {
			{ "-f", srcPath, dstPath, NULL },  // mv
			{ NULL },  // pause
			{ "-R", uidgid, dstPath, NULL },  // chown
			{ NULL }  // stop
		};
		
		// Process the commands up until the first NULL
		unsigned int commandIndex = 0;
		for (; executables[commandIndex] != NULL; ++commandIndex) {
			if (res) {
				res = AuthorizationExecuteWithPrivilegesAndWait(auth, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
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
				res = AuthorizationExecuteWithPrivilegesAndWait(auth, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
			}
		}
		
		AuthorizationFree(auth, 0);
		
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
			*error = [NSError errorWithDomain:kLKErrorDomain code:kLKAuthenticationFailure userInfo:[NSDictionary dictionaryWithObject:@"Couldn't get permission to authenticate." forKey:NSLocalizedDescriptionKey]];
	}
	return res;
}

@end


//#import <dlfcn.h>
//#import <errno.h>
#import <sys/xattr.h>

@implementation NSFileManager (LKExtendedAttributes)

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


// Authorization code based on generous contribution from Allan Odgaard. Thanks, Allan!

static BOOL AuthorizationExecuteWithPrivilegesAndWait(AuthorizationRef authorization, const char* executablePath, AuthorizationFlags options, const char* const* arguments) {
	
	sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
	BOOL returnValue = YES;
	
	if (AuthorizationExecuteWithPrivileges(authorization, executablePath, options, (char* const*)arguments, NULL) == errAuthorizationSuccess)
	{
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


