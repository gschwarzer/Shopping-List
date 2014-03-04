//
//  IGSHistoryItem.h
//  Shopping List
//
//  Created by Gabe on 2/17/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGSHistoryItem : NSObject <NSCoding>

@property (nonatomic) NSString *historicalItemName;
@property (nonatomic) NSString *historicalStoreName;

@end
