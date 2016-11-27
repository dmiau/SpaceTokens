//
//  Record.h
//  SpaceBar
//
//  Created by Daniel on 9/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property NSString *name;
@property BOOL isAnswered;

// Capture the time
@property NSDate *startDate;
@property NSDate *endDate;
@property double elapsedTime;

// Capture the answers from segment controls
@property NSSet *correctSegmentAnswer;
@property NSSet *userAnswer;
@property BOOL isCorrect;

- (void)start;
- (void)end;

@end
