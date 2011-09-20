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
	LKLLog(2, @"This is our message 2");
	
}

@end
