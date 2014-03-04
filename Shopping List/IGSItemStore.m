//
//  IGSItemStore.m
//  Shopping List
//
//  Created by Gabe on 2/9/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSItemStore.h"
#import "IGSItem.h"

@implementation IGSItemStore

//Custom init to get storesDict from data storage if it already exists, otherwise create a new one
- (instancetype)init
{
	self = [super init];
	if (self) {
		NSString *path = [self archivePath];

		_storesDict = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

		if (!_storesDict) {
			_storesDict = [[NSMutableDictionary alloc] init];
		}
	}

	return self;
}


//Save an item to a store
- (void)saveItem:(NSString *)itemName toStore:(NSString *)storeName
{
	//Add itemName to a new IGSItem object
	IGSItem *item = [[IGSItem alloc] init];
	item.itemName = itemName;
	
	//Instantiate storesDict dictionary
	self.storesDict = [[NSMutableDictionary alloc] initWithDictionary:self.storesDict];
	
	//Add item object to a new itemsArr, made up of the existing itemsArr from the dictionary
	NSArray *itemsArrInDict = [self.storesDict valueForKey:storeName];
	self.itemsArr = [[NSMutableArray alloc] initWithArray:itemsArrInDict];
	[self.itemsArr addObject:item];
	
	//Add storeName key with newItemsArr value to storesDict dictionary
	[self.storesDict setObject:self.itemsArr forKey:storeName];
	
	//Save dictionary in data storage
	[self saveStoresDictOnDisk];
	
	//NSLog(@"storesDict: %@", self.storesDict);
}


//Remove an item from a store
- (void)removeItem:(IGSItem *)item fromStore:(NSString *)storeName
{
	//Get the current array in the dictionary and remove the item
	NSMutableArray *itemsArrInDict = [self.storesDict valueForKey:storeName];
	[itemsArrInDict removeObjectIdenticalTo:item];
	
	//If there are no more items in the array, remove the entire store key from the dictionary
	if ([itemsArrInDict count] == 0) {
		[self.storesDict removeObjectForKey:storeName];
	
	} else {
		//Add modified items array back to the dictionary
		[self.storesDict setObject:itemsArrInDict forKey:storeName];
	}
	
	//Save modified dictionary in data storage
	[self saveStoresDictOnDisk];
}


//Remove all checked/non-checked items from the list
- (void)removeAllItems:(BOOL)checkedItemsOnly
{
	//Only remove the checked items
	if (checkedItemsOnly) {
		
		//Create a new mutable dictionary to hold all items that haven't been crossed off
		NSMutableDictionary *newStoresDict = [[NSMutableDictionary alloc] init];
		
		//Loop through the storesDict
		for (NSString *storeName in self.storesDict) {
			NSMutableArray *itemsArr = [self.storesDict objectForKey:storeName];
			NSArray *itemsArrCopy = [itemsArr copy];
			
			//Loop through a copy of itemsArr and remove any completed items from it
			for (IGSItem *item in itemsArrCopy) {
				if (item.completed) {
					[itemsArr removeObjectIdenticalTo:item];
				}
			}
			
			//Only add modified itemsArr to newStoresDict if it has at least one item in it
			if ([itemsArr count] > 0) {
				[newStoresDict setObject:itemsArr forKey:storeName];
			}
		}
		
		//Replace the existing storesDict with the new one
		[self.storesDict setDictionary:newStoresDict];
		
	} else {
		//Remove all items
		[self.storesDict removeAllObjects];
	}

	//Save modified dictionary in data storage
	[self saveStoresDictOnDisk];
}


//Move an item in the list
- (void)moveItem:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath fromSectionTitle:(NSString *)fromSectionTitle toSectionTitle:(NSString *)toSectionTitle
{
	//If the item wasn't moved to a new location, return
	if (fromIndexPath.section == toIndexPath.section && fromIndexPath.row == toIndexPath.row) {
		return;
	}
	
	//Get the item we're moving
	NSArray *itemsArr = [self.storesDict objectForKey:fromSectionTitle];
	IGSItem *item = itemsArr[fromIndexPath.row];
	
	//If the item was moved to a different row in the same section
	if (fromIndexPath.section == toIndexPath.section) {
		
		//Get the current array in the dictionary and remove the item
		NSMutableArray *itemsArrInDict = [[NSMutableArray alloc] initWithArray:itemsArr];
		[itemsArrInDict removeObjectIdenticalTo:item];
		
		//Reinsert the item at the correct index
		[itemsArrInDict insertObject:item atIndex:toIndexPath.row];
		
		//Add modified items array back to the dictionary
		[self.storesDict setObject:itemsArrInDict forKey:fromSectionTitle];
		
		//NSLog(@"Same section: %@", self.storesDict);
		
	} else {
		
		//Remove the item from the old store
		[self removeItem:item fromStore:fromSectionTitle];
		
		//Get the current array from the dictionary
		NSArray *toItemsArr = [self.storesDict objectForKey:toSectionTitle];
		NSMutableArray *itemsArrInDict = [[NSMutableArray alloc] initWithArray:toItemsArr];
		
		//Add item to the array
		[itemsArrInDict insertObject:item atIndex:toIndexPath.row];
		
		//Add modified items array back to the dictionary
		[self.storesDict setObject:itemsArrInDict forKey:toSectionTitle];
		
		//NSLog(@"Different section: %@", self.storesDict);
	}
	
	//Save modified dictionary in data storage
	[self saveStoresDictOnDisk];
	
}


//Save storesDict on disk
- (BOOL)saveStoresDictOnDisk
{
	NSString *path = [self archivePath];
	
	return [NSKeyedArchiver archiveRootObject:self.storesDict toFile:path];
}


//Return an array of all the store names in storesDict
- (NSArray *)storeNamesInStoresDict
{
	NSMutableArray *storeNamesArr = [[NSMutableArray alloc] init];
	
	for (NSString *storeName in self.storesDict) {
		[storeNamesArr addObject:storeName];
	}
	
	return storeNamesArr;
}


//Return an array of all the items in a given store
- (NSArray *)itemsInStore:(NSString *)storeName
{
	NSArray *itemsArr = [self.storesDict valueForKey:storeName];
	return itemsArr;
}


//Return the total number of items in the shopping list
- (NSUInteger)totalNumberOfItems:(BOOL)nonCompletedOnly
{
	NSUInteger itemCount = 0;
	
	for (NSString *storeName in [self storeNamesInStoresDict]) {
		for (IGSItem *item in [self itemsInStore:storeName]) {
			if (nonCompletedOnly) {
				if (!item.completed) {
					itemCount++;
				}
			} else {
				itemCount++;
			}
			
		}
	}
	
	return itemCount;
}


//Follow NSCoding protocol to decode storesDict
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_storesDict = [aDecoder decodeObjectForKey:@"storesDict"];
	}
	return self;
}


//Follow NSCoding protocol to encode storesDict
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.storesDict forKey:@"storesDict"];
}


//Return the path for the archived dictionary
- (NSString *)archivePath
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString *documentDirectory = [documentDirectories firstObject];

	return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

@end
