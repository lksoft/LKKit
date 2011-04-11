//
//  NSLocale+LKHelpers.m
//  LKKit
//
//  Created by Scott Little on 11/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "NSLocale+LKHelpers.h"


@implementation NSLocale (NSLocale_LKHelpers)

- (BOOL)timeIs24HourFormat {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:self];
	[formatter setDateStyle:NSDateFormatterNoStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [formatter stringFromDate:[NSDate date]];
	NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
	NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
	BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
	[formatter release];
	return is24Hour;
}

@end
