//
//  Record.h
//  SpaceBar
//
//  Created by Daniel on 9/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property NSString *name; // store the task key
@property int order; //store the order in the task
@property BOOL isAnswered;
@property BOOL isCorrect;

// Capture the time
@property NSDate *startDate;
@property NSDate *endDate;
@property double elapsedTime;

// Capture the answers from segment controls
@property NSSet *correctSegmentAnswer;
@property NSSet *userAnswer;

- (void)start;
- (void)end;

@end
