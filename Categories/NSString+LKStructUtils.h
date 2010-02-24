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

#import <CoreFoundation/CoreFoundation.h>


@interface NSString (LKStructUtils) 

//  boolean handling utils
+ (NSString *)stringWithBool:(BOOL)inValue;

//	Structure handling utils
+ (NSString *)stringWithSize:(CGSize)size;
+ (NSString *)stringWithPoint:(CGPoint)point;
+ (NSString *)stringWithRect:(CGRect)rect;
+ (NSString *)stringWithRange:(NSRange)range;

@end
