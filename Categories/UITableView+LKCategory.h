//
//  UITableView+LKCategory.h
//  LKKit
//
//  Created by Scott Little on 09/03/10.
//  Copyright 2010 Little Known Software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	kLKCellGroupingSingle,
	kLKCellGroupingFirst,
	kLKCellGroupingMiddle,
	kLKCellGroupingLast,
} LKTableViewCellGroupingType;


@interface UITableView (LKCategory)

- (LKTableViewCellGroupingType)cellGroupingForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
