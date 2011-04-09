//
//  NSDate+LKHelpers.m
//  LKKit
//
//  Created by Scott Little on 09/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "NSDate+LKHelpers.h"


@implementation NSDate (NSDate_LKHelpers)


#pragma mark - Comparision Convenience

- (BOOL)isEarlierThanDate:(NSDate *)otherDate {
	return ([self compare:otherDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)otherDate {
	return ([self compare:otherDate] == NSOrderedDescending);
}

@end
