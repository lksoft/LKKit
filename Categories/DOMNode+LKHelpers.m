//
//  DOMNode+LKHelpers.m
//  LKKit
//
//  Created by Scott Little on 09/06/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "DOMNode+LKHelpers.h"


@implementation DOMNode (DOMNode_LKHelpers)


#pragma mark - Debugging Methods

- (NSString *)verboseDescription {
	
	NSString	*description = [[self class] descriptionFromNode:self paddingLevel:0];
	
	return [NSString stringWithFormat:@"\n%@\n", description];
}



- (NSString *)htmlDebugStringPretty:(BOOL)shouldBePretty {
	
	NSMutableString	*htmlString = [NSMutableString string];
	
	
	
	return [NSString stringWithString:htmlString];
}


#pragma mark - Class Methods

+ (NSString *)descriptionFromNode:(DOMNode *)aNode paddingLevel:(NSUInteger)padCount {
	NSMutableString	*newString = [NSMutableString string];
	NSMutableString	*padString = [NSMutableString string];
	NSUInteger		i = 0;
	
	//	Set up the padString
	for (i = 0; i < padCount; i++) {
		[padString appendString:@"  "];
	}
	
	//	Handle this node's info
	NSString	*typeName = @"Element";
	switch ([aNode nodeType]) {
		case 2:
			typeName = @"Attribute";
			break;
			
		case 3:
			typeName = @"Text";
			break;
			
		case 4:
			typeName = @"CDATA";
			break;
			
		case 5:
			typeName = @"Entity Ref";
			break;
			
		case 6:
			typeName = @"Entity";
			break;
			
		case 7:
			typeName = @"Processing Instruction";
			break;
			
		case 8:
			typeName = @"Comment";
			break;
			
		case 9:
			typeName = @"Document";
			break;
			
		case 10:
			typeName = @"Document Type";
			break;
			
		case 11:
			typeName = @"Fragment";
			break;
			
		case 12:
			typeName = @"Notation";
			break;
			
		default:
			break;
	}
	
	[newString appendFormat:@"%@Type:%@\n", padString, typeName];
	[newString appendFormat:@"%@Name:%@\n", padString, [aNode nodeName]];
	[newString appendFormat:@"%@Value:%@\n", padString, [aNode nodeValue]];
	
	//	Handle Attributes
	DOMNamedNodeMap	*attrs = [aNode attributes];
	[newString appendFormat:@"%@*%d Attributes*\n", padString, [attrs length]];
	for (i = 0; i < [attrs length];i++) {
		[newString appendFormat:@"%@Attribute %d:\n%@{\n%@%@}\n", padString, i, padString, [self descriptionFromNode:[attrs item:i] paddingLevel:padCount + 1], padString];
	}
	
	//	Handle children
	DOMNodeList	*children = [aNode childNodes];
	[newString appendFormat:@"%@*%d Children*\n", padString, [children length]];
	for (i = 0; i < [children length];i++) {
		[newString appendFormat:@"%@Child Node %d:\n%@{\n%@%@}\n", padString, i, padString, [self descriptionFromNode:[children item:i] paddingLevel:padCount + 1], padString];
	}
	
	return newString;
}

+ (NSString *)htmlFromNode:(DOMNode *)aNode paddingLevel:(NSUInteger)padCount pretty:(BOOL)shouldBePretty {
	return nil;
}

@end
