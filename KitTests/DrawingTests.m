//
//  DrawingTests.m
//  DrawingTests
//
//  Created by Scott Little on 08/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "DrawingTests.h"

#import "LKCGStructs.h"

@implementation DrawingTests

#pragma mark - Tests

- (void)testSetXOfRect {
	
	CGRect	startRect = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
	CGRect	endRect = LKRectBySettingX(startRect, 25.0f);
	
	STAssertEquals(endRect.origin.x, 25.0, nil);
}


#pragma mark - Test Admin

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}


@end
