//
//  DOMNode+LKHelpers.h
//  LKKit
//
//  Created by Scott Little on 09/06/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<WebKit/WebKit.h>


@interface DOMNode (DOMNode_LKHelpers)

- (NSString *)verboseDescription;
- (NSString *)htmlDebugStringPretty:(BOOL)shouldBePretty;

+ (NSString *)descriptionFromNode:(DOMNode *)aNode paddingLevel:(NSUInteger)padCount;
+ (NSString *)htmlFromNode:(DOMNode *)aNode paddingLevel:(NSUInteger)padCount pretty:(BOOL)shouldBePretty;

@end
