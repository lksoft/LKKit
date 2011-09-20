//
//  LKPCHInclude.h
//  LKKit
//
//  Created by Scott Little on 08/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#ifdef DEBUG
#define LKLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define LKLog(...) do { } while (0)
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

//	Assertion that will simply log in Production code
#define LKAssert(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)

//	Simple way to test most objects for emptyness
static inline BOOL IsEmpty(id thing) { return thing == nil || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0); }


#define	kLKSBuildBranchInfoKey	@"LKSBuildBranch"
#define	kLKSBuildSHAInfoKey		@"LKSBuildSHA"

