//
//  LKError.h
//  Mail Bundle Manager
//
//  Created by Scott Little on 25/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKError : NSError
- (NSString *)localizeWithFormat:(NSString *)format;
- (NSString *)localizeWithFormat:(NSString *)format andValuesSelector:(SEL)valueSelector;
- (NSString *)localizeWithFormat:(NSString *)format forCode:(NSInteger)aCode andValuesSelector:(SEL)valueSelector;

+ (LKError *)lkErrorWithCode:(NSInteger)aCode fromSender:(id)sender;
+ (LKError *)lkErrorWithCode:(NSInteger)aCode fromSender:(id)sender userInfo:(NSDictionary *)userDict;
+ (NSString *)errorDomainForCode:(NSInteger)aCode;
@end


extern	NSString	*kLKErrorDomain;
extern	NSString	*kLKErrorDelegateKey;
extern	NSString	*kLKErrorTableName;

//	Convenience Macros
#define	LKPresentErrorCodeUsingDict(theCode, theDict) \
{ \
	LKError	*anLKError = [LKError lkErrorWithCode:theCode fromSender:self userInfo:theDict]; \
	/*	if we are not on the main thread, push it there	*/ \
	if ([NSThread currentThread] != [NSThread mainThread]) { \
		dispatch_queue_t	mainQueue = dispatch_get_main_queue(); \
		dispatch_sync(mainQueue, ^(void) { \
			[self presentError:anLKError]; \
		}); \
	} \
	else {[self presentError:anLKError];} \
}
#define	LKPresentErrorCode(theCode)		LKPresentErrorCodeUsingDict(theCode, nil)


@protocol LKInformalErrorProtocol <NSObject>

/*	Returns an array of localized option strings to use for the dialog buttons	*/
- (NSArray *)recoveryOptionsForError:(LKError *)error;
/*	Returns the object that can handle recovery attempts (must conform to <>)	*/
- (id)recoveryAttemptorForError:(LKError *)error;
/*	Returns an array of values to use for replacement in the Description string	*/
- (NSArray *)formatDescriptionValuesForError:(LKError *)error;
/*	Returns an array of values to use for replacement in the Reason Failure string	*/
- (NSArray *)formatFailureValuesForError:(LKError *)error;
/*	Returns an array of values to use for replacement in the Recovery Suggestion string	*/
- (NSArray *)formatSuggestionValuesForError:(LKError *)error;
/*	Method to allow the "delegate" to set the domain for a code	*/
- (NSString *)overrideErrorDomainForCode:(NSInteger)code;

@end
