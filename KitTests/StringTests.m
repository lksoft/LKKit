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
