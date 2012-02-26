//
//  LKCGStructs.h
//  LKKit
//
//  Created by Scott Little on 21/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef USE_NSRECTS

NSRect	LKRectBySettingX(NSRect originalRect, CGFloat newX);
NSRect	LKRectBySettingY(NSRect originalRect, CGFloat newY);
NSRect	LKRectBySettingWidth(NSRect originalRect, CGFloat newWidth);
NSRect	LKRectBySettingHeight(NSRect originalRect, CGFloat newHeight);
NSRect	LKRectBySettingOrigin(NSRect originalRect, CGPoint newOrigin);
NSRect	LKRectBySettingSize(NSRect originalRect, CGSize newSize);

NSRect	LKRectByOffsettingX(NSRect originalRect, CGFloat xOffset);
NSRect	LKRectByOffsettingY(NSRect originalRect, CGFloat yOffset);
NSRect	LKRectByAdjustingWidth(NSRect originalRect, CGFloat width);
NSRect	LKRectByAdjustingHeight(NSRect originalRect, CGFloat height);

#else

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

#endif
