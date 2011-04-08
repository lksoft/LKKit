//
//  LKCoreDataTestCase.h
//  LKKit
//
//  Created by Scott Little on 08/04/2011.
//  Copyright 2011 Little Known Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface LKCoreDataTestCase : SenTestCase {

	NSManagedObjectContext	*context;
	
}

@property	(nonatomic, retain)	NSManagedObjectContext	*context;

- (NSManagedObject *)objectWithName:(NSString *)nameValue forEntity:(NSString *)entityName;
- (NSManagedObject *)objectWithValue:(NSString *)value forKey:(NSString *)key forEntity:(NSString *)entityName;

- (NSManagedObject *)objectWithName:(NSString *)nameValue forEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)context;
- (NSManagedObject *)objectWithValue:(NSString *)value forKey:(NSString *)key forEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)context;
- (BOOL)set:(NSSet *)aSet containsValue:(NSObject *)aValue forKey:(NSString *)aKey;

@end
