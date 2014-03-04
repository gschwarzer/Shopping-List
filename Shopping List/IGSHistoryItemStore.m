//
//  IGSHistoryItemStore.m
//  Shopping List
//
//  Created by Gabe on 2/17/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSHistoryItemStore.h"
#import "IGSHistoryItem.h"

@implementation IGSHistoryItemStore

//Custom init to get itemsHistory from data storage if it already exists, otherwise create a new one
- (instancetype)init
{
	self = [super init];
	if (self) {
		NSString *path = [self archivePath];
		
		_itemsHistory = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		
		if (!_itemsHistory) {
			_itemsHistory = [[NSMutableSet alloc] init];
		}
	}
	
	return self;
}


//Save an item to the set
- (void)saveItem:(NSString *)itemName storeName:(NSString *)storeName
{
	//Add itemName to a new IGSHistoryItem object
	IGSHistoryItem *item = [[IGSHistoryItem alloc] init];
	item.historicalItemName = itemName;
	item.historicalStoreName = storeName;
	
	//Instantiate itemsHistory set
	self.itemsHistory = [[NSMutableSet alloc] initWithSet:self.itemsHistory];
	
	NSSet *itemsHistoryCopy = [self.itemsHistory copy];
	
	//Look through the set for identical item names, remove it if found
	for (IGSHistoryItem *itemInSet in itemsHistoryCopy) {
		if ([itemInSet.historicalItemName isEqualToString:item.historicalItemName]) {
			[self.itemsHistory removeObject:itemInSet];
			break;
		}
	}
	
	//Add item to itemsHistory set
	[self.itemsHistory addObject:item];
	
	//Save dictionary in data storage
	[self saveItemsHistoryOnDisk];
	
	//NSLog(@"itemsHistory: %@", self.itemsHistory);
}


//Remove a history item from the set
- (void)removeItem:(IGSHistoryItem *)item
{
	//Remove the item
	[self.itemsHistory removeObject:item];
	
	//Save modified set in data storage
	[self saveItemsHistoryOnDisk];
}


//Save itemsHistory on disk
- (BOOL)saveItemsHistoryOnDisk
{
	NSString *path = [self archivePath];
	
	return [NSKeyedArchiver archiveRootObject:self.itemsHistory toFile:path];
}


//Follow NSCoding protocol to decode itemsHistory
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_itemsHistory = [aDecoder decodeObjectForKey:@"itemsHistory"];
	}
	return self;
}


//Follow NSCoding protocol to encode storesDict
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.itemsHistory forKey:@"itemsHistory"];
}


//Return the path for the archived dictionary
- (NSString *)archivePath
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentDirectory = [documentDirectories firstObject];
	
	return [documentDirectory stringByAppendingPathComponent:@"itemsHistory.archive"];
}

@end
