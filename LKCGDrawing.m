//
//  LKCGDrawing.m
//  CustomControls
//
//  Created by Scott Little on 20/03/10.
//  Copyright 2010 Little Known Software. All rights reserved.
//

#import "LKCGDrawing.h"


CGMutablePathRef	LKCreateRoundedRectPath(CGRect desiredRect, CGFloat cornerRadius, CGFloat lineWidth) {
	
	CGMutablePathRef	path = CGPathCreateMutable();
	
	//	Ensure that all of the drawing fits in the rect, by inseting the rect if the line is wider than 1
	CGRect	rectToDraw = desiredRect;
	if (lineWidth > 1.0) {
		rectToDraw = CGRectInset(rectToDraw, lineWidth/2, lineWidth/2);
	}
	CGFloat radius = cornerRadius;
    CGFloat width = CGRectGetWidth(rectToDraw);
    CGFloat height = CGRectGetHeight(rectToDraw);
	
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rectToDraw);
    CGFloat midx = CGRectGetMidX(rectToDraw);
    CGFloat maxx = CGRectGetMaxX(rectToDraw);
    CGFloat miny = CGRectGetMinY(rectToDraw);
    CGFloat midy = CGRectGetMidY(rectToDraw);
    CGFloat maxy = CGRectGetMaxY(rectToDraw);
    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, radius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, radius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, radius);
    CGPathCloseSubpath(path);
	
	return path;
}


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

