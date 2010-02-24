/*!
	File:		NSString+LKStructUtils.h
 
	Project:	LKKit
	Author:		Scott Little
	Date:		24 Feb 2010
 
	@class		NSString+LKStructUtils
 
	@abstract   Quick description....
	@discussion 
		This is file header file defining....
 
 
	Copyright (c) 2010 Little Known Software. All rights reserved.
 
 */

#import <Cocoa/Cocoa.h>


@interface NSString (LKStructUtils) 

//  boolean handling utils
+ (NSString *)stringWithBool:(BOOL)inValue;

//	Structure handling utils
+ (NSString *)stringWithSize:(NSSize)size;
+ (NSString *)stringWithPoint:(NSPoint)point;
+ (NSString *)stringWithRect:(NSRect)rect;
+ (NSString *)stringWithRange:(NSRange)range;

@end
