//
//  ArrayEntity.m
//  SpaceBar
//
//  Created by Daniel on 1/2/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayEntity.h"

@implementation ArrayEntity
// MARK: Initialization
-(id)init{
    self = [super init];
    self.contentArray = [NSMutableArray array];
    return self;
}

// MARK: Save/load
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject: self.contentArray forKey:@"contentArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    // Decode source and destination
    self.contentArray = [coder decodeObjectOfClass:[NSMutableArray class] forKey:@"contentArray"];
    return self;
}

-(id) copyWithZone:(NSZone *) zone
{
    // This is very important, since a child class might call this method too.
    ArrayEntity *object = [[[self class] alloc] init];
    object = [super copy];
    object.contentArray = [self.contentArray mutableCopy];
    return object;
}

@end
