//
//  IGSStores.m
//  Shopping List
//
//  Created by Gabe on 2/15/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSStores.h"

@implementation IGSStores

//Init with a generic "Grocery Store" in the list
- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_genericStoreName = @"Grocery Store";
		
		NSString *path = [self archivePath];
		
		_stores = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		
		if (!_stores || [_stores count] == 0) {
			_stores = [[NSMutableArray alloc] initWithObjects:self.genericStoreName, nil];
		}
	}
	
	return self;
}


//Return an array of all the stores on disk
- (NSArray *)allStores
{
	return self.stores;
}


//Add a store to the stores array
- (void)addStore:(NSString *)storeName
{
	if (![self.stores containsObject:storeName]) {
		
		[self.stores addObject:storeName];
		
		//If the stores array has the generic "Store" object still in it, remove it now that we added a real store
		if ([self.stores containsObject:self.genericStoreName]) {
			[self removeStore:self.genericStoreName];
		}
		
		[self saveStoresOnDisk];
	}
}


//Remove a store from the stores array
- (void)removeStore:(NSString *)storeName
{
	[self.stores removeObject:storeName];
	
	//If we just removed the last store, add the generic "Store" object back into the stores array
	if ([self.stores count] == 0) {
		[self.stores addObject:self.genericStoreName];
	}
	
	[self saveStoresOnDisk];
}


//Save stores array on disk
- (BOOL)saveStoresOnDisk
{
	NSString *path = [self archivePath];
	
	return [NSKeyedArchiver archiveRootObject:self.stores toFile:path];
}


//Follow NSCoding protocol to decode stores
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_stores = [aDecoder decodeObjectForKey:@"stores"];
	}
	return self;
}


//Follow NSCoding protocol to encode storesDict
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.stores forKey:@"stores"];
}


//Return the path for the archived dictionary
- (NSString *)archivePath
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentDirectory = [documentDirectories firstObject];
	
	return [documentDirectory stringByAppendingPathComponent:@"stores.archive"];
}


@end
