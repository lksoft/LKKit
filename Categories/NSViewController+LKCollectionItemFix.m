//
//  NSViewController+LKCollectionItemFix.m
//  Mail Bundle Manager
//
//  Created by Scott Little on 29/09/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "NSViewController+LKCollectionItemFix.h"

#define kLKCollectionViewItemLeaderKey	@"lkCVI."

@implementation NSViewController (LKCollectionItemFix)


- (void)configureForCollectionItem:(NSCollectionViewItem *)theItem {
	
	//	Set the view on the collectionItem
	theItem.view = self.view;
	
	//	Recursively fix the bindings
	[self reprocessBindingsInView:self.view forCollectionItem:theItem];
}

- (void)reprocessBindingsInView:(NSView *)theView forCollectionItem:(NSCollectionViewItem *)collectionItem {
	
	//	Look at every binding...
	for (NSString *aBinding in [theView exposedBindings]) {
		NSDictionary	*bindingInfo = [theView infoForBinding:aBinding];
		//	If there is one, then...
		if (bindingInfo) {
			NSString	*keyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
			//	If it is one of ours, remap it
			if ([keyPath hasPrefix:kLKCollectionViewItemLeaderKey]) {
				NSDictionary	*bindingOptions = [bindingInfo valueForKey:NSOptionsKey];
				keyPath = [keyPath substringFromIndex:[kLKCollectionViewItemLeaderKey length]];
				[theView unbind:aBinding];
				[theView bind:aBinding toObject:collectionItem withKeyPath:keyPath options:bindingOptions];
			}
		}
	}
	
	//	Then process all of the subviews
	for (NSView *subview in [theView subviews]) {
		[self reprocessBindingsInView:subview forCollectionItem:collectionItem];
	}
}

//	Just a placeholder to use as the keypath to change
- (NSObject *)lkCVI {
	return nil;
}

@end
