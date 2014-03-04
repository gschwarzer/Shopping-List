//
//  IGSStores.h
//  Shopping List
//
//  Created by Gabe on 2/15/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGSStores : NSObject <NSCoding>

@property (nonatomic) NSMutableArray *stores;
@property (nonatomic) NSString *genericStoreName;

- (NSArray *)allStores;
- (void)addStore:(NSString *)storeName;
- (void)removeStore:(NSString *)storeName;
- (BOOL)saveStoresOnDisk;

@end
