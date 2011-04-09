//
//  NSDate+LKHelpers.h
//  LKKit
//
//  Created by Scott Little on 09/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDate_LKHelpers)
- (BOOL)isEarlierThanDate:(NSDate *)otherDate;
- (BOOL)isLaterThanDate:(NSDate *)otherDate;
@end
