//
//  LKError.m
//  Mail Bundle Manager
//
//  Created by Scott Little on 25/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "LKError.h"
#import "NSString+LKHelper.h"


#define RECOVERY_OPTIONS_SELECTOR_NAME			@"recoveryOptionsForError:"
#define RECOVERY_ATTEMPTOR_SELECTOR_NAME		@"recoveryAttemptorForError:"
#define FORMAT_DESC_VALUES_SELECTOR_NAME		@"formatDescriptionValuesForError:"
#define FORMAT_FAILURE_VALUES_SELECTOR_NAME		@"formatFailureValuesForError:"
#define FORMAT_SUGGESTION_VALUES_SELECTOR_NAME	@"formatSuggestionValuesForError:"
#define ERROR_DOMAIN_SELECTOR_NAME				@"overrideErrorDomainForCode:"

#define DESCRIPTION_FORMAT			@"%d-description"
#define FAILURE_REASON_FORMAT		@"%d-failure-reason"
#define RECOVERY_SUGGESTION_FORMAT	@"%d-recovery-suggestion"
#define RECOVERY_OPTIONS_FORMAT		@"%%d-button-%d"

@interface LKError ()
@end

@implementation LKError

+ (LKError *)lkErrorWithCode:(NSInteger)aCode fromSender:(id)sender {
	//	Call the other with a nil dict
	return [self lkErrorWithCode:aCode fromSender:sender userInfo:nil];
}

+ (LKError *)lkErrorWithCode:(NSInteger)aCode fromSender:(id)sender userInfo:(NSDictionary *)userDict {

	//	Setup the dictionary properly
	NSMutableDictionary	*errorInfo = [NSMutableDictionary dictionary];
	//	If we have some values add them to the dict
	if (userDict) {
		[errorInfo addEntriesFromDictionary:userDict];
	}
	//	Then add the sender
	[errorInfo setObject:sender forKey:kLKErrorDelegateKey];
	
	//	Get the domain to use
	//	Set the classes domain name as default
	NSString	*theDomain = [self errorDomainForCode:aCode];
	//	Then see if the sender has an override
	if ([sender respondsToSelector:NSSelectorFromString(ERROR_DOMAIN_SELECTOR_NAME)]) {
		NSMethodSignature	*methodSig = [sender methodSignatureForSelector:NSSelectorFromString(ERROR_DOMAIN_SELECTOR_NAME)];
		NSInvocation		*domainMethod = [NSInvocation invocationWithMethodSignature:methodSig];
		[domainMethod setTarget:sender];
		[domainMethod setSelector:NSSelectorFromString(ERROR_DOMAIN_SELECTOR_NAME)];
		[domainMethod setArgument:&aCode atIndex:2];
		[domainMethod invoke];
		[domainMethod getReturnValue:&theDomain];
	}
	
	//	Create the new error object
	return [[[LKError alloc] initWithDomain:theDomain code:aCode userInfo:[NSDictionary dictionaryWithDictionary:errorInfo]] autorelease];
}

+ (NSString *)errorDomainForCode:(NSInteger)aCode {
	return kLKErrorDomain;
}

- (NSString *)localizedDescription {
	NSString	*localized = [[self userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey];
	if (localized == nil) {
		localized = [self localizeWithFormat:DESCRIPTION_FORMAT andValuesSelector:NSSelectorFromString(FORMAT_DESC_VALUES_SELECTOR_NAME)];
	}
	return localized;
}

- (NSString *)localizedFailureReason {
	NSString	*localized = [[self userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey];
	if (localized == nil) {
		localized = [self localizeWithFormat:FAILURE_REASON_FORMAT andValuesSelector:NSSelectorFromString(FORMAT_FAILURE_VALUES_SELECTOR_NAME)];
	}
	return localized;
}

- (NSString *)localizedRecoverySuggestion {
	NSString	*localized = [[self userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey];
	if (localized == nil) {
		localized = [self localizeWithFormat:RECOVERY_SUGGESTION_FORMAT andValuesSelector:NSSelectorFromString(FORMAT_SUGGESTION_VALUES_SELECTOR_NAME)];
	}
	return localized;
}

- (NSArray *)localizedRecoveryOptions {
	NSArray	*options = nil;
	id <NSObject>	delegate = (id <NSObject>)[[self userInfo] valueForKey:kLKErrorDelegateKey];
	if ([delegate respondsToSelector:NSSelectorFromString(RECOVERY_OPTIONS_SELECTOR_NAME)]) {
		options = [delegate performSelector:NSSelectorFromString(RECOVERY_OPTIONS_SELECTOR_NAME) withObject:self];
	}
	return options;
}

- (NSArray *)localizedRecoveryOptionList {
	NSMutableArray	*options = [NSMutableArray array];
	
	//	Loop to find all buttons
	for (NSInteger i = 1;; i++) {
		NSString	*format = [NSString stringWithFormat:RECOVERY_OPTIONS_FORMAT, i];
		NSString	*compareValue = [NSString stringWithFormat:format, [self code]];
		NSString	*value = [self localizeWithFormat:format];
		//	If it wasn't found, there are no more options
		if ((value == nil) || [compareValue isEqualToString:value]) {
			break;
		}
		[options addObject:value];
	}
	
	//	If the options are not empty, return them
	return IsEmpty(options)?nil:[NSArray arrayWithArray:options];
}

- (id)recoveryAttempter {
	id	attempter = nil;
	id <NSObject>	delegate = (id <NSObject>)[[self userInfo] valueForKey:kLKErrorDelegateKey];
	if ([delegate respondsToSelector:NSSelectorFromString(RECOVERY_ATTEMPTOR_SELECTOR_NAME)]) {
		attempter = [delegate performSelector:NSSelectorFromString(RECOVERY_ATTEMPTOR_SELECTOR_NAME) withObject:self];
	}
	return attempter;
}

- (NSString *)localizeWithFormat:(NSString *)format {
	return [self localizeWithFormat:format forCode:0 andValuesSelector:NULL];
}

- (NSString *)localizeWithFormat:(NSString *)format andValuesSelector:(SEL)valueSelector {
	return [self localizeWithFormat:format forCode:0 andValuesSelector:valueSelector];
}

- (NSString *)localizeWithFormat:(NSString *)format forCode:(NSInteger)aCode andValuesSelector:(SEL)valueSelector {
	NSInteger	myCode = (aCode == 0)?[self code]:aCode;
	NSString	*keyName = [NSString stringWithFormat:format, myCode];
	NSString	*localized = NSLocalizedStringFromTable(keyName, kLKErrorTableName, @"");

	//	If we didn't get a value, try a grouped value
	if ([localized hasPrefix:[NSString stringWithFormat:@"%d", myCode]]) {
		//	If we didn't find a real value, then try getting a generic value
		NSInteger	floored = [self code] - ([self code] % 100);
		keyName = [NSString stringWithFormat:format, floored];
		localized = NSLocalizedStringFromTable(keyName, kLKErrorTableName, @"");
		//	Again test, though this time return nil, if not found
		if ([localized hasPrefix:[NSString stringWithFormat:@"%d", floored]]) {
			localized = nil;
		}
	}
	else {
		//	First try to replace with dictionary
		localized = [localized stringFormattedWithDictionary:[self userInfo]];
		//	If we have a valueSelector, see if we need to use it
		if (valueSelector != NULL) {
			id <NSObject>	delegate = (id <NSObject>)[[self userInfo] valueForKey:kLKErrorDelegateKey];
			//	If there are some placeholders, get the values to replace
			if (([delegate respondsToSelector:valueSelector]) &&
				(([localized rangeOfString:@"%@"].location != NSNotFound) ||
				 ([localized rangeOfString:@"%1$@"].location != NSNotFound))) {
				NSArray	*values = [delegate performSelector:valueSelector withObject:self];
				localized = [localized stringFormattedWithArray:values];
			}
		}
	}
	return localized;
}

@end

NSString*	const	kLKErrorDomain = @"LKErrorDomain";
NSString*	const	kLKErrorDelegateKey = @"LKErrorDelegate";
NSString*	const	kLKErrorTableName = @"errors";

