//
//  NSString+LKAnonymizer.h
//  LKKit
//
//  Created by Scott Little on 26/03/2012.
//  Copyright (c) 2012 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LKAnonymizer)

- (NSString *)md5HexDigest;

+ (NSString *)anonymizedMacAddressForInterface:(NSString *)interface;
+ (NSString *)uuid;
+ (NSString *)macAddressForInterface:(NSString *)interface;
+ (NSString *)macAddressForInterface:(NSString *)interface separatedBy:(NSString *)separator;
@end
