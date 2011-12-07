//
//  NSViewController+LKCollectionItemFix.h
//  Mail Bundle Manager
//
//  Created by Scott Little on 29/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSViewController (LKCollectionItemFix)
- (void)configureForCollectionItem:(NSCollectionViewItem *)theItem;
- (void)reprocessBindingsInView:(NSView *)theView forCollectionItem:(NSCollectionViewItem *)collectionItem;
- (NSObject *)lkCVI;
@end
