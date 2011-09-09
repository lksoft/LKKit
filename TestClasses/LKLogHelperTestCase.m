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

- (void)testSomething {
	
	//	Init our logger
	[[LKLogHelper sharedInstance] setDefaultActive:YES andLogLevel:9 forID:BUNDLE_ID];
	
	//	Get the standard output and flush it
	NSFileHandle	*stdoutFileHandle = [NSFileHandle fileHandleWithStandardOutput];
	[stdoutFileHandle synchronizeFile];
	
	//	Call one of our log messages
	LKLogClear(2, @"This is our message");
	
	//	Get the results from the stdout file
	NSData	*readData = [stdoutFileHandle readDataToEndOfFile];
	
	//	Print out data
	NSLog(@"%@", readData);
}

@end
