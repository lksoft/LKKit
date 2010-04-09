//
//  UITableView+LKCategory.m
//  LKKit
//
//  Created by Scott Little on 09/03/10.
//  Copyright 2010 Little Known Software. All rights reserved.
//

#import "UITableView+LKCategory.h"


@implementation UITableView (LKCategory)

- (LKTableViewCellGroupingType)cellGroupingForCellAtIndexPath:(NSIndexPath *)indexPath {
	
	LKTableViewCellGroupingType	cellGroupingType = kLKCellGroupingSingle;
	NSUInteger					sectionRows = [self numberOfRowsInSection:indexPath.section];
	
	//	If it is not a single cell...
	if (sectionRows > 1) {
		//	Can't use a switch to test for the last value so just use ifs :-(
		if (indexPath.row == (sectionRows - 1)) {
			cellGroupingType = kLKCellGroupingLast;
		}
		else if (indexPath.row == 0) {
			cellGroupingType = kLKCellGroupingFirst;
		}
		else {
			cellGroupingType = kLKCellGroupingMiddle;
		}
	}
	
	return cellGroupingType;
}


@end
