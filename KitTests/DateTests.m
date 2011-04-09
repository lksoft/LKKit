//
//  DateTests.m
//  LKKit
//
//  Created by Scott Little on 09/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "DateTests.h"
#import "NSDate+LKHelpers.h"

@implementation DateTests

#pragma mark - Tests

- (void)testEarlierThan {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([earlyDate isEarlierThanDate:lateDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

- (void)testLaterThan {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([lateDate isLaterThanDate:earlyDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

- (void)testEarlierThan_EXPECTEDFAIL {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([lateDate isEarlierThanDate:earlyDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

#pragma mark - Test Admin

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

@end
