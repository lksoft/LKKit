//
//  LKCGDrawing.h
//  LKKit
//
//  Created by Scott Little on 20/03/10.
//  Copyright 2010 Little Known Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import	"LKCGStructs.h"

#define	kGRRRectValueKey				@"boundingRect"
#define	kGRRGradientColorListValueKey	@"gradientColorList"
#define	kGRRStrokeColorValueKey			@"strokeColor"
#define	kGRRLineWidthValueKey			@"lineWidth"
#define	kGRRCornerRadiusValueKey		@"cornerRadius"
#define	kGRRGradientColorItem			@"gradientColorItem"
#define	kGRRGradientLocationItem		@"gradientLocationItem"


CGMutablePathRef	LKCreateRoundedRectPath(CGRect desiredRect, CGFloat cornerRadius, CGFloat lineWidth);
void	LKDrawGradientRoundedRectPath(CGContextRef context, NSDictionary *values);

