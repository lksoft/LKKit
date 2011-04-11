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


NSString	*const	kLKFemaleGender = @"F";
NSString	*const	kLKMaleGender = @"M";
NSString	*const	kLKNeuterGender = @"N";


@implementation NSString (NSString_LKHelper)


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

@end
