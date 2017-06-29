//
//  Record.m
//  NavTools
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
        self.order = 0;
        self.isCorrect = NO;
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
    self.elapsedTime = fabs([self.startDate timeIntervalSinceNow]);
    self.endDate = [NSDate date];
}

#pragma mark --save/load--
//

// saving and loading the object
//- (void)encodeWithCoder:(NSCoder *)coder {
//    [coder encodeObject:self.name forKey:@"name"];
//    [coder encodeObject: [NSNumber numberWithBool: self.isAnswered] forKey:@"isAnswered"];
    
//}

//- (id)initWithCoder:(NSCoder *)coder {
//    self = [self init];
//    self.name = [coder decodeObjectForKey:@"name"];
//    self.poiArray = [[coder decodeObjectForKey:@"poiArray"] mutableCopy];
//    return self;
//}

//- (NSString*)description{
//    return @"";
//}


@end
