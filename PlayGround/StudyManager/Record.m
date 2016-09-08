//
//  Record.m
//  SpaceBar
//
//  Created by Daniel on 9/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Record.h"

@implementation Record

- (id)init{
    self = [super init];
    if (self){
        self.elapsedTime = 0;
        self.isAnswered = NO;
        self.name = @"";
    }
    return self;
}

- (void)start{
    self.elapsedTime = 0;
    self.isAnswered = NO;
    self.startDate = [NSDate date];
}


- (void)end{
    self.isAnswered = YES;
    self.elapsedTime = [self.startDate timeIntervalSinceNow];
    self.endDate = [NSDate date];
}

@end
