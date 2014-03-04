//
//  IGSHistoryItemStore.h
//  Shopping List
//
//  Created by Gabe on 2/17/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGSHistoryItem;

@interface IGSHistoryItemStore : NSObject <NSCoding>

@property (nonatomic) NSMutableSet *itemsHistory;

- (void)saveItem:(NSString *)itemName storeName:(NSString *)storeName;
- (void)removeItem:(IGSHistoryItem *)item;
- (BOOL)saveItemsHistoryOnDisk;

@end
