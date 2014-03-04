//
//  IGSItem.m
//  Shopping List
//
//  Created by Gabe on 2/12/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import "IGSItem.h"

@implementation IGSItem

//Override description
- (NSString *)description
{
	return [NSString stringWithFormat:@"Item: %@, completed: %d", self.itemName, self.completed];
}


//Follow NSCoder protocol for decoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_itemName = [aDecoder decodeObjectForKey:@"itemName"];
		_completed = [aDecoder decodeBoolForKey:@"completed"];
	}
	return self;
}


//Follow NSCoder protocol for encoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.itemName forKey:@"itemName"];
	[aCoder encodeBool:self.completed forKey:@"completed"];
}

@end
