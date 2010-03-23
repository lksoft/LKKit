//
//  LKCGDrawing.h
//  CustomControls
//
//  Created by Scott Little on 20/03/10.
//  Copyright 2010 Little Known Software. All rights reserved.
//

#import <UIKit/UIKit.h>

CGMutablePathRef	LKCreateRoundedRectPath(CGRect desiredRect, CGFloat cornerRadius, CGFloat lineWidth);

CGRect	LKRectBySettingX(CGRect originalRect, CGFloat newX);
CGRect	LKRectBySettingY(CGRect originalRect, CGFloat newY);
CGRect	LKRectBySettingWidth(CGRect originalRect, CGFloat newWidth);
CGRect	LKRectBySettingHeight(CGRect originalRect, CGFloat newHeight);
CGRect	LKRectBySettingOrigin(CGRect originalRect, CGPoint newOrigin);
CGRect	LKRectBySettingSize(CGRect originalRect, CGSize newSize);

CGRect	LKRectByOffsettingX(CGRect originalRect, CGFloat xOffset);
CGRect	LKRectByOffsettingY(CGRect originalRect, CGFloat yOffset);
CGRect	LKRectByAdjustingWidth(CGRect originalRect, CGFloat width);
CGRect	LKRectByAdjustingHeight(CGRect originalRect, CGFloat height);
