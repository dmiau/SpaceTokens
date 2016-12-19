//
//  NSMutableArray+Tools.m
//  SpaceBar
//
//  Created by Daniel on 12/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "NSMutableArray+Tools.h"

//http://stackoverflow.com/questions/56648/whats-the-best-way-to-shuffle-an-nsmutablearray

@implementation NSMutableArray (Tools)
- (void)shuffle
{
    NSUInteger count = [self count];
    if (count < 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
@end
