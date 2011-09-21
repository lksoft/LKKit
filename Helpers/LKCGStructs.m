//
//  LKCGStructs.m
//  LKKit
//
//  Created by Scott Little on 21/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "LKCGStructs.h"

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

