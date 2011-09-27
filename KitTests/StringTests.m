//
//  StringTests.m
//  LKKit
//
//  Created by Scott Little on 11/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "StringTests.h"
#import "NSString+LKHelper.h"

@implementation StringTests

#pragma mark - Ordinal Tests

- (void)test001_Ordinal_All {
	NSLocale	*dummyLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"haw_US"];
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:1] usingLocale:dummyLocale gender:nil case:nil], @"1uni", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:2] usingLocale:dummyLocale gender:nil case:nil], @"2sec", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:3] usingLocale:dummyLocale gender:nil case:nil], @"3rd", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:12] usingLocale:dummyLocale gender:nil case:nil], @"12sec", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:13] usingLocale:dummyLocale gender:nil case:nil], @"13uni2", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:51] usingLocale:dummyLocale gender:nil case:nil], @"51th", nil);
	
	//	Add in some gender
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:4] usingLocale:dummyLocale gender:kLKFemaleGender case:nil], @"4the", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:4] usingLocale:dummyLocale gender:kLKMaleGender case:nil], @"4th", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:4] usingLocale:dummyLocale gender:kLKNeuterGender case:nil], @"4tho", nil);
	
	//	Use case that shouldn't have gender, should return normal ordinal
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:5] usingLocale:dummyLocale gender:kLKNeuterGender case:nil], @"5th", nil);
	
	//	Add Gender and Case
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:8] usingLocale:dummyLocale gender:kLKMaleGender case:@"case1"], @"8oce", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:8] usingLocale:dummyLocale gender:kLKMaleGender case:@"case2"], @"8oc2", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:8] usingLocale:dummyLocale gender:kLKFemaleGender case:@"case1"], @"8ace", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:8] usingLocale:dummyLocale gender:kLKNeuterGender case:@"case3"], @"8ic3", nil);
	//	Fall back to without case
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:8] usingLocale:dummyLocale gender:kLKNeuterGender case:@"case5"], @"8i", nil);
	
}

- (void)test002_Ordinal_English {
	NSLocale	*usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:1] usingLocale:usLocale gender:nil case:nil], @"1st", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:2] usingLocale:usLocale gender:nil case:nil], @"2nd", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:3] usingLocale:usLocale gender:nil case:nil], @"3rd", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:12] usingLocale:usLocale gender:nil case:nil], @"12th", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:547] usingLocale:usLocale gender:nil case:nil], @"547th", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:223] usingLocale:usLocale gender:nil case:nil], @"223rd", nil);
}

- (void)test003_Ordinal_EnglishSimple {
	NSLocale	*usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	STAssertEqualObjects([[NSLocale currentLocale] localeIdentifier], [usLocale localeIdentifier], @"This test is invalid if the current locale is not 'en_US'");
	STAssertEqualObjects([NSString ordinalStringForInteger:1], @"1st", nil);
	STAssertEqualObjects([NSString ordinalStringForInteger:2], @"2nd", nil);
	STAssertEqualObjects([NSString ordinalStringForInteger:3], @"3rd", nil);
	STAssertEqualObjects([NSString ordinalStringForInteger:12], @"12th", nil);
	STAssertEqualObjects([NSString ordinalStringForInteger:547], @"547th", nil);
	STAssertEqualObjects([NSString ordinalStringForInteger:223], @"223rd", nil);
}

- (void)test004_Ordinal_French {
	NSLocale	*franceLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:1] usingLocale:franceLocale gender:nil case:nil], @"1e", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:2] usingLocale:franceLocale gender:nil case:nil], @"2e", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:3] usingLocale:franceLocale gender:nil case:nil], @"3e", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:12] usingLocale:franceLocale gender:nil case:nil], @"12e", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:501] usingLocale:franceLocale gender:nil case:nil], @"501e", nil);
	STAssertEqualObjects([NSString ordinalStringForNumber:[NSNumber numberWithInteger:223] usingLocale:franceLocale gender:nil case:nil], @"223e", nil);
}



#pragma mark - PlaceHolder Tests
#pragma mark Names

-  (void)test101_PlaceHolder_Names_Just_Normal {
	NSString	*string = @"Here is a %@ that should have %@ and %@ in it.";
	NSArray		*phList = [string placeholderNames];
	STAssertNotNil(phList, nil);
	STAssertTrue([phList count] == 0, nil);
}

-  (void)test102_PlaceHolder_Names {
	NSString	*string = @"Here is a %<name>@ that should have %<value>@ and %<pride>@ in it.";
	NSArray		*phList = [string placeholderNames];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([phList containsObject:@"name"], nil);
	STAssertTrue([phList containsObject:@"value"], nil);
	STAssertTrue([phList containsObject:@"pride"], nil);
}

-  (void)test103_PlaceHolder_Names_With_Normal_1 {
	NSString	*string = @"Here is a %<name>@ that should (%@) have %<value>@ and %<pride>@ in it.";
	NSArray		*phList = [string placeholderNames];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([phList containsObject:@"name"], nil);
	STAssertTrue([phList containsObject:@"value"], nil);
	STAssertTrue([phList containsObject:@"pride"], nil);
}

-  (void)test104_PlaceHolder_Names_With_Positional {
	NSString	*string = @"Here is a %<name>@ that should (%1$@) [%2$@] have %<value>@ and %<pride>@ in it.";
	NSArray		*phList = [string placeholderNames];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([phList containsObject:@"name"], nil);
	STAssertTrue([phList containsObject:@"value"], nil);
	STAssertTrue([phList containsObject:@"pride"], nil);
}

#pragma mark Positions

-  (void)test105_PlaceHolder_Positions_Just_Normal {
	NSString	*string = @"Here is a %@ that should have %@ and %@ in it.";
	NSArray		*phList = [string placeholderPositions];
	STAssertNotNil(phList, nil);
	STAssertTrue([phList count] == 0, nil);
}

-  (void)test106_PlaceHolder_Positions_Normal_With_Named {
	NSString	*string = @"Here is a %<name>@ that should (%@) have %<value>@ and %<pride>@ in it.";
	NSArray		*phList = [string placeholderPositions];
	STAssertNotNil(phList, nil);
	STAssertTrue([phList count] == 0, nil);
}

-  (void)test107_PlaceHolder_Positions {
	NSString	*string = @"Here is a %1$@ that should have %2$@ and %3$@ in it.";
	NSArray		*phList = [string placeholderPositions];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([[phList objectAtIndex:0] integerValue] == 1, nil);
	STAssertTrue([[phList objectAtIndex:1] integerValue] == 2, nil);
	STAssertTrue([[phList objectAtIndex:2] integerValue] == 3, nil);
}

-  (void)test108_PlaceHolder_Positions_Disordered {
	NSString	*string = @"Here is a %2$@ that should have %3$@ and %1$@ in it.";
	NSArray		*phList = [string placeholderPositions];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([[phList objectAtIndex:0] integerValue] == 2, nil);
	STAssertTrue([[phList objectAtIndex:1] integerValue] == 3, nil);
	STAssertTrue([[phList objectAtIndex:2] integerValue] == 1, nil);
}

-  (void)test109_PlaceHolder_Positions_Disordered_With_Named {
	NSString	*string = @"Here is a %2$@ that %<name>@ should have %3$@ and %1$@ in it.";
	NSArray		*phList = [string placeholderPositions];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([[phList objectAtIndex:0] integerValue] == 2, nil);
	STAssertTrue([[phList objectAtIndex:1] integerValue] == 3, nil);
	STAssertTrue([[phList objectAtIndex:2] integerValue] == 1, nil);
}

-  (void)test110_PlaceHolder_Positions_Disordered_With_Named_Normal {
	NSString	*string = @"Here is a %2$@ that %<name>@ should have %3$@ and %1$@ in it %@.";
	NSArray		*phList = [string placeholderPositions];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([[phList objectAtIndex:0] integerValue] == 2, nil);
	STAssertTrue([[phList objectAtIndex:1] integerValue] == 3, nil);
	STAssertTrue([[phList objectAtIndex:2] integerValue] == 1, nil);
}

-  (void)test111_PlaceHolder_Positions_Disordered_With_Normal {
	NSString	*string = @"Here is a %2$@ that %@ should have %3$@ and %1$@ in it %@.";
	NSArray		*phList = [string placeholderPositions];
	STAssertTrue([phList count] == 3, nil);
	STAssertTrue([[phList objectAtIndex:0] integerValue] == 2, nil);
	STAssertTrue([[phList objectAtIndex:1] integerValue] == 3, nil);
	STAssertTrue([[phList objectAtIndex:2] integerValue] == 1, nil);
}


#pragma mark FormatWithDict

-  (void)test120_Format_Dict_Normal_Only {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", nil];
	NSString		*string = [@"Here is a %@ that %@ should have %@ and %@ in it %@." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is a %@ that %@ should have %@ and %@ in it %@.", nil);
}

-  (void)test121_Format_Dict_Normal_Positional {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", nil];
	NSString		*string = [@"Here is a %@ that %1$@ should have %@ and %3$@ in it %2$@." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is a %@ that %1$@ should have %@ and %3$@ in it %2$@.", nil);
}

-  (void)test122_Format_Dict {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", nil];
	NSString		*string = [@"Here is a simple '%<name>@' with a '%<label>@'." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is a simple 'one' with a 'two'.", nil);
}

-  (void)test123_Format_Dict_With_Normal {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", nil];
	NSString		*string = [@"Here is %@ a simple '%<name>@' with %@ a '%<label>@'." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is %@ a simple 'one' with %@ a 'two'.", nil);
}

-  (void)test124_Format_Dict_With_Positional {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", nil];
	NSString		*string = [@"Here is %1$@ a simple '%<name>@' with %2$@ a '%<label>@'." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is %1$@ a simple 'one' with %2$@ a 'two'.", nil);
}

-  (void)test125_Format_Dict_With_Positional_Normal {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"name", @"two", @"label", @"three", @"thing", nil];
	NSString		*string = [@"Here is %@ a simple '%<name>@' with %1$@ a '%<label>@'." stringFormattedWithDictionary:dict];
	STAssertEqualObjects(string, @"Here is %@ a simple 'one' with %1$@ a 'two'.", nil);
}


#pragma mark FormatWithArray

-  (void)test130_Format_Array_Named_Only {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a %<name>@ that should have %<label>@ in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a %<name>@ that should have %<label>@ in it.", nil);
}

-  (void)test131_Format_Array_Normal_Only {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%@' that should have '%@' in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'one' that should have 'two' in it.", nil);
}

-  (void)test132_Format_Array_Positional_Only {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%1$@' that should have '%2$@' in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'one' that should have 'two' in it.", nil);
}

-  (void)test133_Format_Array_Positional_Only_Disordered {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%2$@' that should have '%1$@' in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'two' that should have 'one' in it.", nil);
}

-  (void)test134_Format_Array_Positional_Only_Discontinuous {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%3$@' that should have '%1$@' in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'thing' that should have 'one' in it.", nil);
}

-  (void)test135_Format_Array_Positional_With_Normal {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%2$@' that should have '%1$@' in it(%@)." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'two' that should have 'one' in it(thing).", nil);
}

-  (void)test136_Format_Array_Positional_With_Normal2 {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%2$@' that should(%@) have '%1$@' in it." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'two' that should(thing) have 'one' in it.", nil);
}

-  (void)test137_Format_Array_Positional_With_Normal_Named {
	NSArray		*array = [NSArray arrayWithObjects:@"one", @"two", @"thing", nil];
	NSString	*string = [@"Here is a '%2$@' that should have '%1$@' (%@) in it%<name>@." stringFormattedWithArray:array];
	STAssertEqualObjects(string, @"Here is a 'two' that should have 'one' (thing) in it%<name>@.", nil);
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
