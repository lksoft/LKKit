/*!
	File:		LKLogHelper.h
 
 */

#import <Cocoa/Cocoa.h>


/*****
 *
 *	Without handling this as a sharedInstance, you wouldn't be able to share the class and use the
 *		simple function calls, which fit better with logging.
 *
 *  Functions to allow for simple management of the logging by the
 *		developer and by the end user if the code is in a beta state
 *		of course these logs should always be set to off for deployment
 *		releases.
 *
 *  Set DEBUG_OUTPUT_OFF to stop all logging when building.
 *	Set LK_INSECURE_LOGS to have potentially personal contents displayed in logs (i.e. should not be set for Release builds)
 *	Set TOOL_ID (as the app/plugin's identifier) in it's pch file before the import for this file.
 *  Set LKCurrentDebugLogLevel in the applications preferences file
 *		to change the level at runtime
 *
 *	Call [[LKLogHelper sharedInstance] setDefaultActive:(BOOL) andLogLevel:(NSInteger) forID:(NSString *)] as soon as possible to init
 *
 *****/
void LKLogV(NSString *aToolID, NSInteger level, BOOL isSecure, NSString *prefix, const char *file, int lineNum, const char *method, NSString *format, va_list argptr);
void LKInternalInformation(NSString *aToolID, NSString *format, ...);
void LKInternalWarning(NSString *aToolID, const char *file, int lineNum, const char *method, NSString *format, ...);
void LKInternalError(NSString *aToolID, const char *file, int lineNum, const char *method, NSString *format, ...);
void LKInternalLog(NSString *aToolID, NSInteger level, BOOL isSecure, const char *file, int lineNum, const char *method, NSString *format, ...);

//	utility function for the loggers
NSString	*LKSecureFormat(NSString *format);

long getOSVersion();

//  default level used when calling from LKLog (will almost always log)
#define kLKDefaultLevel	9
#define kLKIgnoreLevel	-1
#define	kLKNotInited	-2
#define kLKConfiguredLogLevelKey	@"LKCurrentDebugLogLevel"
#define kLKConfiguredDebuggingKey	@"LKDebuggingIsOn"

//	these are for migration purposes
#define kSJLConfiguredLogLevelKey	@"SJLCurrentDebugLogLevel"
#define kSJLConfiguredDebuggingKey	@"SJLDebuggingIsOn"

#define kLKToolKeyUndefined @"not-set"

//	then set the define if it isn't yet defined
#ifndef TOOL_ID
#define TOOL_ID kLKToolKeyUndefined
#endif

//	If another LKLog is defined, undef it
#ifdef	LKLog
#undef	LKLog
#endif

//	these defines hide the actual calls that include the correct local TOOL_ID
//		if the logging is turned off make this more efficient, by doing nothing
#ifndef DEBUG_OUTPUT_OFF
#define kDebugEnabled			YES
#define	LKLLog(i, s, ...)		LKInternalLog(TOOL_ID, i, YES, __FILE__, __LINE__, __PRETTY_FUNCTION__, s, ## __VA_ARGS__)
#define	LKLog(s, ...)			LKInternalLog(TOOL_ID, kLKDefaultLevel, YES, __FILE__, __LINE__, __PRETTY_FUNCTION__, s, ## __VA_ARGS__)
#define	LKLogClear(i, s, ...)	LKInternalLog(TOOL_ID, i, NO, __FILE__, __LINE__, __PRETTY_FUNCTION__, s, ## __VA_ARGS__)
#else
#define kDebugEnabled			NO
#define LKLLog(i, s, ...)
#define LKLog(s, ...)
#define	LKLogClear(i, s, ...)
#endif
#define	LKInfo(s, ...)			LKInternalInformation(TOOL_ID, s, ## __VA_ARGS__)
#define	LKWarn(s, ...)			LKInternalWarning(TOOL_ID, __FILE__, __LINE__, __PRETTY_FUNCTION__, s, ## __VA_ARGS__)
#define	LKError(s, ...)			LKInternalError(TOOL_ID, __FILE__, __LINE__, __PRETTY_FUNCTION__, s, ## __VA_ARGS__)

//  useful strings setup so that they don't have to be reinitialized
extern NSString *const kLKEmptyString;
extern NSString *const kLKSingleSpace;
extern NSString *const kLKTab;
extern NSString *const kLKNewLine;
extern NSString *const kLKYes;
extern NSString *const kLKNo;
extern NSString *const kLKyes;
extern NSString *const kLKno;
extern NSString *const kLKtrue;
extern NSString *const kLKfalse;
extern NSString *const kLKQuote;

@interface LKLogHelper : NSObject {
	NSString			*defaultID;
}
@property (nonatomic, copy)	NSString	*defaultID;

+ (LKLogHelper *)sharedInstance;

- (BOOL)debuggingOn;
- (NSInteger)logLevel;

- (BOOL)debuggingOnForToolID:(NSString *)aToolID;
- (NSInteger)logLevelForToolID:(NSString *)aToolID;

- (NSInteger)currentApplicationLogLevel;
- (NSInteger)logLevelForTool:(NSString *)toolID;
- (void)setDefaultActive:(BOOL)active andLogLevel:(NSInteger)level forID:(NSString *)toolID;


@end
