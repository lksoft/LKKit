/*!
	File:		LKLogHelper.h
 
 */

#import "LKLogHelper.h"

//  define the constants that are universal
NSString *const kLKEmptyString = @"";
NSString *const kLKSingleSpace = @" ";
NSString *const kLKTab = @"\t";
NSString *const kLKNewLine = @"\n";
NSString *const kLKYes = @"Yes";
NSString *const kLKNo = @"No";
NSString *const kLKyes = @"yes";
NSString *const kLKno = @"no";
NSString *const kLKtrue = @"true";
NSString *const kLKfalse = @"false";
NSString *const kLKQuote = @"\"";

static NSMutableDictionary	*lkBundleConfigurations = nil;

@interface LKLogHelper ()
- (NSMutableDictionary *)logDictForID:(NSString *)aBundleID;
@end

@implementation LKLogHelper


- (id)init {
	self = [super init];
	if (self) {
		lkBundleConfigurations = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}




#pragma mark - Log Levels


- (NSInteger)logLevelForBundleID:(NSString *)aBundleID {
	
	NSInteger	workingLevel = kLKNotInited;
	BOOL		debugging = NO;
	
	//	try to get the dictionary and see if it is configured...
	NSMutableDictionary	*logDict = [self logDictForID:aBundleID];
	if (logDict != nil) {
		
		//	get the values from the set
		NSNumber	*areLogsOn = (NSNumber *)[logDict objectForKey:kLKConfiguredDebuggingKey];
		NSNumber	*logLevel = (NSNumber *)[logDict objectForKey:kLKConfiguredLogLevelKey];
		
		//	get any set log level
		if (logLevel != nil) {
			workingLevel = [logLevel integerValue];
		}
		
		//	get any set debugging flag, if it is off, set level to ignore
		if (areLogsOn != nil) {
			debugging = [areLogsOn boolValue];
			if (!debugging) {
				workingLevel = kLKIgnoreLevel;
			}
		}
		
	}
	
	//	return the correct value
	return workingLevel;
}

- (BOOL)debuggingOnForBundleID:(NSString *)aBundleID {
	NSDictionary	*logDict = [self logDictForID:aBundleID];
	return [[logDict objectForKey:kLKConfiguredDebuggingKey] boolValue];
}

#pragma mark - Configuration

//	get the defaultSet for the bundleID
- (NSMutableDictionary *)logDictForID:(NSString *)aBundleID {

	//	if no id is passed then ignore
	if (IsEmpty(aBundleID)) {
		NSLog(@"[LKLogHelper ERROR] no bundleID was passed to logDictForID");
		return nil;
	}
	
	//	get any existing set and create a new one if there isn't any
	NSMutableDictionary	*logDict = (NSMutableDictionary *)[lkBundleConfigurations objectForKey:aBundleID];
	if (logDict == nil) {
		logDict = [[NSMutableDictionary alloc] init];
		[lkBundleConfigurations setObject:[logDict autorelease] forKey:aBundleID];
	}
	
	return logDict;
}

//	this allows the calling bundle to set the default values
- (void)setLogsActive:(BOOL)active andLogLevel:(NSInteger)level forID:(NSString *)aBundleID {

	NSMutableDictionary	*defaultSet = [self logDictForID:aBundleID];
	
	//	if none was found ignore values
	if (defaultSet == nil) return;

	//	set the two values for it
	[defaultSet setObject:[NSNumber numberWithBool:active] forKey:kLKConfiguredDebuggingKey];
	[defaultSet setObject:[NSNumber numberWithInteger:level] forKey:kLKConfiguredLogLevelKey];
	
	NSLog(@"[LKLogHelper]Setting configuration for %@: debugging-%@  logLevel-%d", aBundleID, (active?@"YES":@"NO"), (int)level);
	
}

//	These methods ensure that people calling the methods do not screw up the object
#pragma mark - Singleton

+ (LKLogHelper *)sharedInstance {
	
	static dispatch_once_t	pred;
	static LKLogHelper		*shared = nil;
	
	dispatch_once(&pred, ^{
		shared = [[LKLogHelper alloc] init];
	});
	return shared;

}


@end


void LKLogV(NSString *aBundleID, NSInteger level, BOOL isSecure, NSString *prefix, const char *file, 
			int lineNum, const char *method, NSString *format, va_list argptr) {
	
	NSString	*formattedPrefix = prefix;
	NSString	*adjustedFormat;
	LKLogHelper	*utils = [LKLogHelper sharedInstance];
	NSInteger	logLevel = 0;
	
	//	ensure that the proper bundle is called, unless it is not set
	if ([aBundleID isEqualToString:kLKBundleKeyUndefined]) {
		logLevel = kLKIgnoreLevel;
	}
	else {
		logLevel = [utils logLevelForBundleID:aBundleID];
	}
	
	//	if this is secure output, obscure the format first
	if (isSecure) {
		
		//	using the build type determine if the obscuring should be done
		//		this tends to the conservative side, if the setting is not set 
		//		it will secure the data
#ifndef LK_INSECURE_LOGS
		format = LKSecureFormat(format);
		argptr = nil;
#endif
	}
	
	//	put the file/method information before the format
	NSMutableString	*newFormat = [NSMutableString string];
	NSString		*fileName = nil;
	NSString		*methodName = nil;
	if (file) {
		fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
	}
	if (method) {
		methodName = [NSString stringWithUTF8String:method];
	}
	if (fileName || methodName) {
		if (fileName != NULL) {
			[newFormat appendFormat:@"({%@:%d}:%@) ", fileName, lineNum, methodName];
		}
		else {
			[newFormat appendFormat:@"(%@) ", methodName];
		}
	}
	[newFormat appendString:format];
	if (![format hasSuffix:@"\n"]) {
		[newFormat appendString:@"\n"];
	}
	format = newFormat;
//	NSLog(@"Format value is:%@", format);
	
	if (logLevel == kLKNotInited) {
		NSString	*emptyFormat = [NSString stringWithFormat:@"[No LKLogHelper instance]:%@", format];
		NSLogv(emptyFormat, argptr);
	}
	else if (level <= logLevel) {
		//  if we are not ignoring the level assume that the prefix has a format for it
		if (level != kLKIgnoreLevel) {
			formattedPrefix = [NSString stringWithFormat:prefix, level];
		}
		
		//  then add the prefix to the passed in format
		adjustedFormat = [formattedPrefix stringByAppendingString:format];
		
		NSLogv(adjustedFormat, argptr);
	}
}

#ifndef DEBUG_OUTPUT_OFF
void LKInternalLog(NSString *aBundleID, NSInteger level, BOOL isSecure, const char *file, int lineNum, const char *method, NSString *format, ...) {
	va_list argptr;
	va_start(argptr, format);
	LKLogV(aBundleID, level, isSecure, @"[DEBUG:%d]:", file, lineNum, method, format, argptr);
}
#endif

void LKInternalInformation(NSString *aBundleID, NSString *format, ...) {
	va_list argptr;
	va_start(argptr, format);
	LKLogV(aBundleID, kLKIgnoreLevel, NO, @"[INFO]:", NULL, 0, NULL, format, argptr);
}

void LKInternalWarning(NSString *aBundleID, const char *method, NSString *format, ...) {
#ifndef WARN_OUTPUT_OFF
	va_list argptr;
	va_start(argptr, format);
	LKLogV(aBundleID, kLKIgnoreLevel, YES, @"[WARNING]:", NULL, 0, method, format, argptr);
#endif
}

void LKInternalError(NSString *aBundleID, const char *method, NSString *format, ...) {
#ifndef ERROR_OUTPUT_OFF
	va_list argptr;
	va_start(argptr, format);
	LKLogV(aBundleID, kLKIgnoreLevel, YES, @"[ERROR]:", NULL, 0, method, format, argptr);
#endif
}

NSString	*LKSecureFormat(NSString *format) {
	
	//	the text to replace the hidden output with
	NSString		*replaceWith = @"<****>";
	
	
	//	the string format set, including the %
	NSCharacterSet	*stringFormatSet = [NSCharacterSet characterSetWithCharactersInString:@"@dDiuUxXoOfeEgGcCsSphq"];
	
	//	scan the string for a percent
	//		if the next is '%' ignore
	//		then scan for one of the following:
	//			@ d D i u U x X o O f e E g G c C s S p h q
	//		if found delete from the % to the char inclusive
	//		unless one of the last two then add another character to delete
	NSScanner		*myScan = [NSScanner scannerWithString:format];
	NSMutableString	*newFormat = [NSMutableString string];
	NSString		*holder = nil;
	
	//	ensure that it doesn't skip any whitespace
	[myScan setCharactersToBeSkipped:nil];
	
	//	If the format string starts with a '%', set a flag
	BOOL	startsWithPercent = [format hasPrefix:@"%"];
	//	look for those '%'s
	while ([myScan scanUpToString:@"%" intoString:&holder] || startsWithPercent) {
		//	Immediately switch off that flag
		startsWithPercent = NO;
		
		//	add holder to the newFormat
		if (holder) {
			[newFormat appendString:holder];
		}
		
		//	if we are the end, leave
		if ([myScan isAtEnd]) {
			break;
		}
		
		//	scan for the potentials
		if ([myScan scanUpToCharactersFromSet:stringFormatSet
								   intoString:&holder]) {
			
			//	if current position is '%', reappend '%%' and continue
			if ([format characterAtIndex:[myScan scanLocation]] == '%') {
				[newFormat appendString:@"%%"];
				[myScan setScanLocation:([myScan scanLocation] + 1)];
				continue;
			}
			
			//	and if the last character is either 'h' or 'q', 
			//		advance the pointer one more position to skip that
			unichar	lastChar = [format characterAtIndex:[myScan scanLocation]];
			if ((lastChar == 'h') || (lastChar == 'q')) {
				[myScan setScanLocation:([myScan scanLocation] + 1)];
			}
			
			//	always advance the scan position past the matched character
			[myScan setScanLocation:([myScan scanLocation] + 1)];
			
			//	stick the replace string into the outgoing string
			[newFormat appendString:replaceWith];
		} 
		else {
			//	bad formatting, give warning and reset the format completely to ensure security
			LKError(@"Bad format during Secure Scan Reformat: original format is:%@", format);
			return @"Bad format for Secure Logging";
		}
		
	}
	
	//	return the string
	return [NSString stringWithString:newFormat];
}


