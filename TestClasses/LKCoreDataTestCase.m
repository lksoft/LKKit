//
//  LKCoreDataTestCase.m
//  LKKit
//
//  Created by Scott Little on 08/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import "LKCoreDataTestCase.h"


@implementation LKCoreDataTestCase

@synthesize context;

#pragma mark - Helper Methods

- (NSManagedObject *)objectWithName:(NSString *)nameValue forEntity:(NSString *)entityName {
	return [self objectWithValue:nameValue forKey:@"name" forEntity:entityName inContext:self.context];
}

- (NSManagedObject *)objectWithValue:(NSString *)value forKey:(NSString *)key forEntity:(NSString *)entityName {
	return [self objectWithValue:value forKey:key forEntity:entityName inContext:self.context];
}

- (NSManagedObject *)objectWithName:(NSString *)nameValue forEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)aContext {
	return [self objectWithValue:nameValue forKey:@"name" forEntity:entityName inContext:aContext];
}

- (NSManagedObject *)objectWithValue:(NSString *)value forKey:(NSString *)key forEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)aContext {
	
	NSManagedObject *result = nil;
	NSError			*error = nil;
	NSFetchRequest	*request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:aContext]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", key, value]];
	
	//	Fetch it
	NSArray	*objects = [aContext executeFetchRequest:request error:&error];
	[request release];
	
	//	If there are any object, get the first
	if ([objects count] > 0) {
		result = [objects objectAtIndex:0];
	}
	
	return result;
}

- (BOOL)set:(NSSet *)aSet containsValue:(NSObject *)aValue forKey:(NSString *)aKey {
	NSPredicate	*predicate = [NSPredicate predicateWithFormat:@"%K == %@", aKey, aValue];
	NSSet	*newSet = [aSet filteredSetUsingPredicate:predicate];
	return ([newSet count] == 1);
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
