//
//  IGSItemStore.h
//  Shopping List
//
//  Created by Gabe on 2/9/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGSItem;

@interface IGSItemStore : NSObject <NSCoding>

@property (nonatomic) NSMutableDictionary *storesDict;
@property (nonatomic) NSMutableArray *itemsArr;

- (void)saveItem:(NSString *)itemName
		 toStore:(NSString *)storeName;
- (void)removeItem:(IGSItem *)item
		 fromStore:(NSString *)storeName;
- (void)removeAllItems:(BOOL)checkedItemsOnly;
- (void)moveItem:(NSIndexPath *)fromIndexPath
	 toIndexPath:(NSIndexPath *)toIndexPath
fromSectionTitle:(NSString *)fromSectionTitle
  toSectionTitle:(NSString *)toSectionTitle;
- (BOOL)saveStoresDictOnDisk;
- (NSArray *)storeNamesInStoresDict;
- (NSArray *)itemsInStore:(NSString *)storeName;
- (NSUInteger)totalNumberOfItems:(BOOL)nonCompletedOnly;

@end
