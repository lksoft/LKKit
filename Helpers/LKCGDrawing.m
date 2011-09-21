//
//  LKCGDrawing.m
//  LKKit
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
    if (radius > width/2.0f)
        radius = width/2.0f;
    if (radius > height/2.0f)
        radius = height/2.0f;    
    
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

void	LKDrawGradientRoundedRectPath(CGContextRef context, NSDictionary *values) {
	
	//	Handle two error cases
	NSCAssert(context != nil, @"LKDrawGradientRoundedRectPath() Cannot draw gradient RoundedRect without context");
	if (values == nil) {
		return;
	}
	
	//	Make assertions
	NSCAssert([values valueForKey:kGRRRectValueKey] != nil, @"LKDrawGradientRoundedRectPath() Cannot draw gradient RoundedRect without rect");
	NSCAssert([values valueForKey:kGRRGradientColorListValueKey] != nil, @"LKDrawGradientRoundedRectPath() Cannot draw gradient RoundedRect without the Gradient Color List");
	//	Get values from the dictionary
	CGRect	boundingRect = [[values valueForKey:kGRRRectValueKey] CGRectValue];
	NSArray	*colorList = (NSArray *)[values valueForKey:kGRRGradientColorListValueKey];
	UIColor	*strokeColor = (UIColor *)[values valueForKey:kGRRStrokeColorValueKey];
	CGFloat	lineWidth = [[values valueForKey:kGRRLineWidthValueKey] floatValue];
	CGFloat	cornerRadius = [[values valueForKey:kGRRCornerRadiusValueKey] floatValue];
	//	Set defaults for any of these that are missing
	if ([values valueForKey:kGRRStrokeColorValueKey] == nil) {
		strokeColor = [UIColor blackColor];
	}
	if ([values valueForKey:kGRRLineWidthValueKey] == nil) {
		lineWidth = 1.0f;
	}
	if ([values valueForKey:kGRRCornerRadiusValueKey] == nil) {
		cornerRadius = 4.0f;
	}
	
	//	Create the path for the rounded rect
	CGMutablePathRef	roundedPath = LKCreateRoundedRectPath(boundingRect, cornerRadius, lineWidth);
	
	//	Clip to that path
	CGContextAddPath(context, roundedPath);
	CGContextClosePath(context);
	CGContextClip(context);
	
	//	Define the gradient to draw as background of the rounded rect
	CGColorSpaceRef	myColorspace = CGColorGetColorSpace(((UIColor *)[(NSDictionary *)[colorList objectAtIndex:0] valueForKey:kGRRGradientColorItem]).CGColor);

	//	Allocate our memory
	CGFloat			*locations = NSZoneMalloc(NSDefaultMallocZone(), sizeof(CGFloat) * colorList.count);
	CGFloat			*components = NSZoneMalloc(NSDefaultMallocZone(), sizeof(CGFloat) * colorList.count * CGColorSpaceGetNumberOfComponents(myColorspace));

	//	Pointers to do math with
	CGFloat			*locationPointer = locations;
	CGFloat			*componentPointer = components;
	
	//	Go through the gradient color list and build our arrays
	for (NSDictionary *gradientItem in colorList) {
		
		//	Set the location for this gradient item
		*locationPointer = [[gradientItem valueForKey:kGRRGradientLocationItem] floatValue];locationPointer++;
		
		//	Then set the color info
		CGColorRef		aColor = ((UIColor *)[gradientItem valueForKey:kGRRGradientColorItem]).CGColor;
		const	CGFloat	*rgba = CGColorGetComponents(aColor);
		for (NSUInteger i = 0; i < CGColorGetNumberOfComponents(aColor); i++, componentPointer++) {
			*componentPointer = rgba[i];
		}
	}
	
	//	Create and Draw the gradient from top center to bottom center
	CGGradientRef	myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, colorList.count);
	CGPoint topCenter = CGPointMake(CGRectGetMidX(boundingRect), CGRectGetMinY(boundingRect));
	CGPoint midCenter = CGPointMake(CGRectGetMidX(boundingRect), CGRectGetMaxY(boundingRect));
	CGContextDrawLinearGradient(context, myGradient, topCenter, midCenter, 0);
	
	//	Set the line color
	CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
	
	//	Set the line width to use and draw the stroke after re-adding the path
	CGContextSetLineWidth(context, lineWidth);
	CGContextAddPath(context, roundedPath);
	CGContextDrawPath(context, kCGPathStroke);
	
	//	Release the CG objects created
	CGGradientRelease(myGradient);
	CGPathRelease(roundedPath);
	
	//	Release the arrays that I created
	NSZoneFree(NSDefaultMallocZone(), (void *)locations);
	NSZoneFree(NSDefaultMallocZone(), (void *)components);
	
}

