//
//  LKCGStructs.m
//  LKKit
//
//  Created by Scott Little on 21/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "LKCGStructs.h"

#ifdef USE_NSRECTS

NSRect	LKRectBySettingX(NSRect originalRect, CGFloat newX) {
	return NSMakeRect(newX, originalRect.origin.y, originalRect.size.width, originalRect.size.height);
}

NSRect	LKRectBySettingY(NSRect originalRect, CGFloat newY) {
	return NSMakeRect(originalRect.origin.x, newY, originalRect.size.width, originalRect.size.height);
}

NSRect	LKRectBySettingWidth(NSRect originalRect, CGFloat newWidth) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y, newWidth, originalRect.size.height);
}

NSRect	LKRectBySettingHeight(NSRect originalRect, CGFloat newHeight) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y, originalRect.size.width, newHeight);
}

NSRect	LKRectBySettingOrigin(NSRect originalRect, CGPoint newOrigin) {
	return NSMakeRect(newOrigin.x, newOrigin.y, originalRect.size.width, originalRect.size.height);
}

NSRect	LKRectBySettingSize(NSRect originalRect, CGSize newSize) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y, newSize.width, newSize.height);
}


NSRect	LKRectByOffsettingX(NSRect originalRect, CGFloat xOffset) {
	return NSMakeRect(originalRect.origin.x + xOffset, originalRect.origin.y, originalRect.size.width, originalRect.size.height);
}

NSRect	LKRectByOffsettingY(NSRect originalRect, CGFloat yOffset) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y + yOffset, originalRect.size.width, originalRect.size.height);
}

NSRect	LKRectByAdjustingWidth(NSRect originalRect, CGFloat width) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y, originalRect.size.width + width, originalRect.size.height);
}

NSRect	LKRectByAdjustingHeight(NSRect originalRect, CGFloat height) {
	return NSMakeRect(originalRect.origin.x, originalRect.origin.y, originalRect.size.width, originalRect.size.height + height);
}


#else

CGRect	LKRectBySettingX(CGRect originalRect, CGFloat newX) {
	return CGRectMake(newX, originalRect.origin.y, originalRect.size.width, originalRect.size.height);
}

CGRect	LKRectBySettingY(CGRect originalRect, CGFloat newY) {
	return CGRectMake(originalRect.origin.x, newY, originalRect.size.width, originalRect.size.height);
}

CGRect	LKRectBySettingWidth(CGRect originalRect, CGFloat newWidth) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y, newWidth, originalRect.size.height);
}

CGRect	LKRectBySettingHeight(CGRect originalRect, CGFloat newHeight) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y, originalRect.size.width, newHeight);
}

CGRect	LKRectBySettingOrigin(CGRect originalRect, CGPoint newOrigin) {
	return CGRectMake(newOrigin.x, newOrigin.y, originalRect.size.width, originalRect.size.height);
}

CGRect	LKRectBySettingSize(CGRect originalRect, CGSize newSize) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y, newSize.width, newSize.height);
}


CGRect	LKRectByOffsettingX(CGRect originalRect, CGFloat xOffset) {
	return CGRectMake(originalRect.origin.x + xOffset, originalRect.origin.y, originalRect.size.width, originalRect.size.height);
}

CGRect	LKRectByOffsettingY(CGRect originalRect, CGFloat yOffset) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y + yOffset, originalRect.size.width, originalRect.size.height);
}

CGRect	LKRectByAdjustingWidth(CGRect originalRect, CGFloat width) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y, originalRect.size.width + width, originalRect.size.height);
}

CGRect	LKRectByAdjustingHeight(CGRect originalRect, CGFloat height) {
	return CGRectMake(originalRect.origin.x, originalRect.origin.y, originalRect.size.width, originalRect.size.height + height);
}

#endif
