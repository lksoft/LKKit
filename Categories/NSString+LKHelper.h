//
//  NSString+LKHelper.h
//  LKKit
//
//  Created by Scott Little on 11/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern	NSString	*const	kLKFemaleGender;
extern	NSString	*const	kLKMaleGender;
extern	NSString	*const	kLKNeuterGender;
 
@interface NSString (NSString_LKHelper)
- (NSString *)stringFormattedWithArray:(NSArray *)array;

+ (NSString *)ordinalStringForInteger:(NSInteger)number;
+ (NSString *)ordinalStringForNumber:(NSNumber *)number;
+ (NSString *)ordinalStringForNumber:(NSNumber *)number gender:(const NSString *)gender;
+ (NSString *)ordinalStringForNumber:(NSNumber *)number usingLocale:(NSLocale *)locale gender:(const NSString *)gender case:(NSString *)caseName;
@end
