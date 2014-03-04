//
//  IGSHistoryItem.m
//  Shopping List
//
//  Created by Gabe on 2/17/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSHistoryItem.h"

@implementation IGSHistoryItem

//Override description method
- (NSString *)description
{
	return [NSString stringWithFormat:@"Historical item: %@, store: %@", self.historicalItemName, self.historicalStoreName];
}


//Override compare method
- (NSComparisonResult)compare:(IGSHistoryItem *)otherObject {
    return [self.historicalItemName compare:otherObject.historicalItemName];
}


//Follow NSCoder protocol for decoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_historicalItemName = [aDecoder decodeObjectForKey:@"historicalItemName"];
		_historicalStoreName = [aDecoder decodeObjectForKey:@"historicalStoreName"];
	}
	return self;
}


//Follow NSCoder protocol for encoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.historicalItemName forKey:@"historicalItemName"];
	[aCoder encodeObject:self.historicalStoreName forKey:@"historicalStoreName"];
}

@end
