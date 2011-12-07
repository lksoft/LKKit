//
//  NSString+LKHelper.m
//  LKKit
//
//  Created by Scott Little on 11/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "NSString+LKHelper.h"


#define kLKStringHelperResourcesFolderName			@"Resources"
#define kLKStringHelperProjectFolderFormat			@"%@.lproj"
#define kLKStringHelperDefaultLanguageKey			@"default-%@"
#define kLKStringHelperDefaultKey					@"default"

#define kLKStringHelperMappingUsageKey				@"usage"
#define kLKStringHelperMappingOrdinalKey			@"ordinal"

#define kLKStringHelperMappingUsageAll				@"all"
#define kLKStringHelperMappingUsageUnique			@"unique"
#define kLKStringHelperMappingUsageMultiple			@"multiple"


//	External
NSString	*const	kLKFemaleGender = @"F";
NSString	*const	kLKMaleGender = @"M";
NSString	*const	kLKNeuterGender = @"N";

//	Internal
NSString	*const	kLKPlaceholderOpen = @"%";
NSString	*const	kLKPlaceholderNormal = @"%@";
NSString	*const	kLKPlaceholderNormalClose = @"@";
NSString	*const	kLKPlaceholderPositionalClose = @"$@";
NSString	*const	kLKPlaceholderNamedOpen = @"%<";
NSString	*const	kLKPlaceholderNamedClose = @">@";

@implementation NSString (NSString_LKHelper)


#pragma mark - Enhanced Formatting

- (NSArray *)placeholderNames {
	//	Return empty array if there are no placeholders
	if ([self rangeOfString:kLKPlaceholderNamedOpen].location == NSNotFound) {
		return [NSArray array];
	}
	
	//	Then do a scan looking for the matches
	NSMutableArray	*placeholderNames = [NSMutableArray array];
	NSScanner	*scanner = [NSScanner scannerWithString:self];
	NSString	*aPlaceholder = nil;
	[scanner scanUpToString:kLKPlaceholderNamedOpen intoString:NULL];
	while (![scanner isAtEnd]) {
		[scanner scanString:kLKPlaceholderNamedOpen intoString:NULL];
		[scanner scanUpToString:kLKPlaceholderNamedClose intoString:&aPlaceholder];
		//	We shouldn't be at the end (should still be ')@') if it is valid
		if (![scanner isAtEnd]) {
			[placeholderNames addObject:aPlaceholder];
		}
		[scanner scanUpToString:kLKPlaceholderNamedOpen intoString:NULL];
	}
	return [NSArray arrayWithArray:placeholderNames];
}

- (NSArray *)placeholderPositions {
	//	Return empty array if there are no placeholders
	if ([self rangeOfString:kLKPlaceholderOpen].location == NSNotFound) {
		return [NSArray array];
	}
	
	//	Then scan for matches (still might not find any)
	NSMutableArray	*newPositions = [NSMutableArray array];
	NSScanner		*scanner = [NSScanner scannerWithString:self];
	NSString		*aPlaceholder = nil;
	[scanner scanUpToString:kLKPlaceholderOpen intoString:NULL];
	while (![scanner isAtEnd]) {
		[scanner scanString:kLKPlaceholderOpen intoString:NULL];
		//	If this is a normal placeholder skip it
		if ([[[scanner string] substringWithRange:NSMakeRange([scanner scanLocation], 1)] isEqualToString:kLKPlaceholderNormalClose]) {
			[scanner scanUpToString:kLKPlaceholderOpen intoString:NULL];
			continue;
		}
		//	Also skip named placeholders
		if ([[[scanner string] substringWithRange:NSMakeRange([scanner scanLocation]-1, 2)] isEqualToString:kLKPlaceholderNamedOpen]) {
			[scanner scanUpToString:kLKPlaceholderOpen intoString:NULL];
			continue;
		}
		[scanner scanUpToString:kLKPlaceholderPositionalClose intoString:&aPlaceholder];
		//	Try to make that string an integer
		NSInteger	i = [aPlaceholder integerValue];
		if (i > 0) {
			[newPositions addObject:[NSNumber numberWithInteger:i]];
		}
		[scanner scanUpToString:kLKPlaceholderOpen intoString:NULL];
	}
	
	return newPositions;
}


- (NSString *)stringFormattedWithArray:(NSArray *)array {
	if ((IsEmpty(array)) || ([self rangeOfString:kLKPlaceholderOpen].location == NSNotFound)) {
		return [[self copy] autorelease];
	}
	
	//	Copy of self to work on
	NSMutableString	*newSelf = [[self mutableCopy] autorelease];
	NSMutableArray	*usedValues = [NSMutableArray arrayWithCapacity:[array count]];
	
	//	Handle positionally marked placeholders first
	NSArray	*placeholderList = [self placeholderPositions];
	for (NSNumber *aPosition in placeholderList) {
		NSUInteger	idx = [aPosition integerValue];
		NSString	*fullPlaceholder = [NSString stringWithFormat:@"%@%d%@", kLKPlaceholderOpen, idx, kLKPlaceholderPositionalClose];
		if ([array count] >= idx) {
			NSRange	aRange = [newSelf rangeOfString:fullPlaceholder];
			[newSelf replaceCharactersInRange:aRange withString:[array objectAtIndex:(idx-1)]];
			[usedValues addObject:[array objectAtIndex:(idx-1)]];
		}
	}
	
	//	Then clean up any non-positional in left-to-right order
	NSMutableArray	*unusedValues = [[array mutableCopy] autorelease];
	[unusedValues removeObjectsInArray:usedValues];
	for (NSUInteger j = 0; j < [unusedValues count]; j++) {
		NSRange	aRange = [newSelf rangeOfString:kLKPlaceholderNormal];
		if (aRange.location != NSNotFound) {
			[newSelf replaceCharactersInRange:aRange withString:[unusedValues objectAtIndex:j]];
		}
	}
	
	return [NSString stringWithString:newSelf];
}

- (NSString *)stringFormattedWithDictionary:(NSDictionary *)dict {
	if ((IsEmpty(dict)) || ([self rangeOfString:kLKPlaceholderNamedOpen].location == NSNotFound)) {
		return [[self copy] autorelease];
	}
	
	NSMutableString	*newSelf = [[self mutableCopy] autorelease];
	
	NSArray	*placeholderList = [self placeholderNames];
	for (NSString *aKey in placeholderList) {
		NSString	*fullPlaceholder = [NSString stringWithFormat:@"%@%@%@", kLKPlaceholderNamedOpen, aKey, kLKPlaceholderNamedClose];
		if ([dict valueForKey:aKey]) {
			NSRange	aRange = [newSelf rangeOfString:fullPlaceholder];
			[newSelf replaceCharactersInRange:aRange withString:[dict valueForKey:aKey]];
		}
	}
	
	return [NSString stringWithString:newSelf];
}

#pragma mark - Ordinal Value Methods

+ (NSString *)ordinalStringForInteger:(NSInteger)number {
	return [self ordinalStringForNumber:[NSNumber numberWithInteger:number] usingLocale:nil gender:nil case:nil];
}

+ (NSString *)ordinalStringForNumber:(NSNumber *)number {
	return [self ordinalStringForNumber:number usingLocale:nil gender:nil case:nil];
}

+ (NSString *)ordinalStringForNumber:(NSNumber *)number gender:(const NSString *)gender {
	return [self ordinalStringForNumber:number usingLocale:nil gender:gender case:nil];
}

+ (NSString *)ordinalStringForNumber:(NSNumber *)number usingLocale:(NSLocale *)locale gender:(const NSString *)gender case:(NSString *)caseName {
	//	Ensure that we have a locale
	NSLocale	*aLocale = locale;
	if (locale == nil) {
		aLocale = [NSLocale currentLocale];
		
	}
	
	//	Get the localized dictionary to pull values from
	NSArray			*theLanguages = [NSArray arrayWithObjects:[aLocale localeIdentifier], [aLocale objectForKey:NSLocaleLanguageCode], @"en", @"English", @"", nil];
#ifdef STRING_UNIT_TEST
	NSString		*theResourcesPath = [[NSBundle bundleForClass:NSClassFromString(@"StringTests")] bundlePath];
#else
	NSString		*theResourcesPath = [[NSBundle mainBundle] bundlePath];
#endif
	NSURL			*fileURL = nil;
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	
	//	Find the Content for MacOS X 
	if ([fileManager fileExistsAtPath:[theResourcesPath stringByAppendingPathComponent:@"Contents"]]) {
		theResourcesPath = [theResourcesPath stringByAppendingPathComponent:@"Contents"];
	}
	
	//	Find the correct Resources Path for MacOS X or iOS
	if ([fileManager fileExistsAtPath:[theResourcesPath stringByAppendingPathComponent:kLKStringHelperResourcesFolderName]]) {
		theResourcesPath = [theResourcesPath stringByAppendingPathComponent:kLKStringHelperResourcesFolderName];
	}
	
	//	For each of the language definitions...
	for (NSString *aLang in theLanguages) {
		//	The first with a path...
		NSString *projPath = [theResourcesPath stringByAppendingPathComponent:[NSString stringWithFormat:kLKStringHelperProjectFolderFormat, aLang]];
		if ([fileManager fileExistsAtPath:projPath]) {
			fileURL = [NSURL fileURLWithPath:[projPath stringByAppendingPathComponent:@"OrdinalMappings.plist"]];
			break;
		}
	}
	LKAssert(fileURL, @"There is no OrdinalMappings.plist file anywhere");
	NSDictionary	*ordinalMappings = [NSDictionary dictionaryWithContentsOfURL:fileURL];
	
	//	Get the endings of the string to use for testing
	NSString	*numberString = [number stringValue];
	NSString	*langDefault = [NSString stringWithFormat:kLKStringHelperDefaultLanguageKey, [aLocale objectForKey:NSLocaleLanguageCode]];
    NSString	*lastTwoDigits = @"-";
    NSString	*lastDigit = [numberString substringFromIndex:([numberString length]-1)];
	if ([numberString length] > 1) {
		lastTwoDigits = [numberString substringFromIndex:([numberString length]-2)];
	}
	NSArray	*searchKeys = [NSArray arrayWithObjects:lastTwoDigits, lastDigit, langDefault, kLKStringHelperDefaultKey, nil];
	
	//	Build the ordinal key
	BOOL			isKeyEmbellished = NO;
	NSMutableString	*ordinalKey = [NSMutableString string];
	[ordinalKey appendString:kLKStringHelperMappingOrdinalKey];
	if (gender) {
		[ordinalKey appendString:@"-"];
		[ordinalKey appendString:(NSString *)gender];
		isKeyEmbellished = YES;
	}
	if (caseName) {
		[ordinalKey appendString:@"-"];
		[ordinalKey appendString:caseName];
		isKeyEmbellished = YES;
	}

	//	Find the ordinal in the mappings
	NSString		*ordinalValue = nil;
	for (NSString *aKey in searchKeys) {
		NSDictionary	*ordinalInfo = nil;
		if ((ordinalInfo = [ordinalMappings objectForKey:aKey])) {
			
			NSString	*usage = [ordinalInfo valueForKey:kLKStringHelperMappingUsageKey];
			//	If usage is for all or it's unique and this key is the full number...
			if (([usage isEqualToString:kLKStringHelperMappingUsageAll]) ||
				([usage isEqualToString:kLKStringHelperMappingUsageUnique] && 
				 ([aKey length] == [numberString length]))) {
					
				//	Try to get mapping with full key
				ordinalValue = [ordinalInfo objectForKey:ordinalKey];
				//	If not try basic key
				if (isKeyEmbellished && (ordinalValue == nil)) {
					ordinalValue = [ordinalInfo objectForKey:kLKStringHelperMappingOrdinalKey];
				}
				break;
			}
			else if ([usage isEqualToString:kLKStringHelperMappingUsageMultiple]) {
				
			}
		}
	}
	
	//	Complete the formatting
    return [NSString stringWithFormat:@"%@%@", numberString, ordinalValue?ordinalValue:@""];
}


#pragma mark - Path Utilities

- (BOOL)userHasAccessRights {
	if (0 != access([self fileSystemRepresentation], W_OK) || 0 != access([[self stringByDeletingLastPathComponent] fileSystemRepresentation], W_OK)) {
		return NO;
	}
	return YES;
}

@end
