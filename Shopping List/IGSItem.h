//
//  IGSItem.h
//  Shopping List
//
//  Created by Gabe on 2/12/14.
//  Copyright (c) 2014 Gabe Schwarzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGSItem : NSObject <NSCoding>

@property (nonatomic) NSString *itemName;
@property (nonatomic) BOOL completed;


@end
