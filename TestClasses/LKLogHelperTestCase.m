//
//  LKLogHelperTestCase.m
//  LKKit
//
//  Created by Scott Little on 19/07/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "LKLogHelperTestCase.h"

#define BUNDLE_ID	@"com.littleknownsoftware.tests"
#import "LKLogHelper.h"


@implementation LKLogHelperTestCase

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testUndefinedLogs {
	
	//	Call one of our log messages
	LKLog(@"This is our message 1");
	
}

- (void)testUsingBundleID {
	
	//	Init our logger
	[[LKLogHelper sharedInstance] setLogsActive:YES andLogLevel:3 forID:BUNDLE_ID];
	
	//	Call one of our log messages
	LKZLog(2, @"This is our message 2");
	
	LKLog(@"This has no values");
	LKLog(@"The string you should see is 'blue':%@", @"blue");
	
	LKSecureLog(@"The values here should be hidden:%@", @"Whatever");
	
	LKInfo(@"Info is being shown here:%@", @"some info");
	LKInfoSecure(@"Secure Info is being shown here:%@", @"some info");
	
	LKWarn(@"Something isn't as it should be:%@", @"WARNING");
	LKWarnSecure(@"Something isn't as secure it should be:%@", @"WARNING");

	LKError(@"Something is really screwed up:%@", @"ERROR");
	LKErrorSecure(@"Something is really securely screwed up:%@", @"ERROR");

}

@end
