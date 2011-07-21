/*!
	File:		NSString+LKStructUtils.m
 
	Project:	LKKit
	Author:		Scott Little
	Date:		24 Feb 2010
 
	Description: 
		This is implementation file for class NSString+LKStructUtils which....
 
 
 
	Copyright (c) 2010 Little Known Software. All rights reserved.
 
 */

#import "NSString+LKStructUtils.h"


@implementation NSString (LKStructUtils)

#pragma mark BOOLEAN

+ (NSString *)stringWithBool:(BOOL)inValue {
	return [NSString stringWithString:(inValue ? @"YES" : @"NO")];
}

#pragma mark Integer

+ (NSString *)stringWithInteger:(NSInteger)inValue {
	return [[NSNumber numberWithInteger:inValue] stringValue];
}


#pragma mark Structures

+ (NSString *)stringWithSize:(CGSize)size {
	return [NSString stringWithFormat:@"[w:%5.2f,h:%5.2f]", size.width, size.height];
}

+ (NSString *)stringWithPoint:(CGPoint)point {
	return [NSString stringWithFormat:@"[x:%5.2f,y:%5.2f]", point.x, point.y];
}

+ (NSString *)stringWithRect:(CGRect)rect {
	return [NSString stringWithFormat:@"(%@,%@)", [NSString stringWithPoint:rect.origin], 
		[NSString stringWithSize:rect.size]];
}

+ (NSString *)stringWithRange:(NSRange)range {
	return [NSString stringWithFormat:@"[loc:%u,len:%u]", range.location, range.length];
}


@end
