//
//  DateTests.m
//  LKKit
//
//  Created by Scott Little on 09/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "DateTests.h"
#import "NSDate+LKHelpers.h"
#import "NSLocale+LKHelpers.h"

@implementation DateTests

#pragma mark - Date Tests

- (void)test001_EarlierThan {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([earlyDate isEarlierThanDate:lateDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

- (void)test002_LaterThan {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([lateDate isLaterThanDate:earlyDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

- (void)test003_EarlierThan_EXPECTEDFAIL {
	
	NSDate	*earlyDate = [NSDate date];
	NSDate	*lateDate = [NSDate dateWithTimeIntervalSinceNow:600.0f];
	
	STAssertTrue([lateDate isEarlierThanDate:earlyDate], @"Early:%@  Late:%@", earlyDate, lateDate);
}

#pragma mark - Locale Tests

- (void)test004_LocaleHasAMPM_USA {
	NSLocale	*usaLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	STAssertFalse([usaLocale timeIs24HourFormat], @"USA locale doesn't show time as 12 hour");
	[usaLocale release];
}

- (void)test005_LocaleHasAMPM_France {
	NSLocale	*frenchLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	
	STAssertTrue([frenchLocale timeIs24HourFormat], @"French locale doesn't show time as 24 hour");
	[frenchLocale release];
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
