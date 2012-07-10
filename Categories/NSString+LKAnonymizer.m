//
//  NSString+LKAnonymizer.m
//  LKKit
//
//  Created by Scott Little on 26/03/2012.
//  Copyright (c) 2012 Little Known Software. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "NSString+LKAnonymizer.h"

@implementation NSString (LKAnonymizer)


#pragma mark - Anonymizing Data

- (NSString *)md5HexDigest {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
	
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString *)anonymizedMacAddressForInterface:(NSString *)interface {
	return [[self macAddressForInterface:interface separatedBy:@""] md5HexDigest];
}



#pragma mark - Identifiers

+ (NSString *)uuid {
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	return [(NSString *)uuidStringRef autorelease];
}

+ (NSString *)macAddressForInterface:(NSString *)interface {
	return [self macAddressForInterface:interface separatedBy:@":"];
}

+ (NSString *)macAddressForInterface:(NSString *)interface separatedBy:(NSString *)separator {
	
	int                 mgmtInfoBase[6];
	char                *msgBuffer = NULL;
	size_t              length;
	unsigned char       macAddress[6];
	struct if_msghdr    *interfaceMsgStruct;
	struct sockaddr_dl  *socketStruct;
	NSString            *errorFlag = nil;
	BOOL				failed = YES;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
	mgmtInfoBase[2] = 0;              
	mgmtInfoBase[3] = AF_LINK;        // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex([interface cStringUsingEncoding:NSUTF8StringEncoding])) == 0) {
		errorFlag = @"if_nametoindex failure";
	}
	else {
		// Get the size of the data available (store in len)
		if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
			errorFlag = @"sysctl mgmtInfoBase failure";
		}
		else {
			// Alloc memory based on above call
			if ((msgBuffer = malloc(length)) == NULL) {
				errorFlag = @"buffer allocation failure";
			}
			else {
				// Get system information, store in buffer
				if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
					errorFlag = @"sysctl msgBuffer failure";
				}
				else {
					failed = NO;
				}
			}
		}
	}
	
	// Befor going any further...
	if (failed) {
		LKErr(errorFlag);
		if (msgBuffer != NULL) {
			free(msgBuffer);
		}
		return nil;
	}
	
	// Map msgbuffer to interface message structure
	interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
	
	// Map to link-level socket structure
	socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
	
	// Copy link layer address data in socket structure to an array
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	
	// Read from char array into a string object, into traditional Mac address format
	NSString *macAddressString = [NSString stringWithFormat:@"%02X%@%02X%@%02X%@%02X%@%02X%@%02X", 
								  macAddress[0], separator, macAddress[1], separator, macAddress[2], 
								  separator, macAddress[3], separator, macAddress[4], separator, macAddress[5]];
	
	// Release the buffer memory
	free(msgBuffer);
	
	return macAddressString;
}

@end
