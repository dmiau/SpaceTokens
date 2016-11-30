//
//  SnapshotShow.m
//  SpaceBar
//
//  Created by dmiau on 11/27/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotShow.h"

@implementation SnapshotShow

- (void)setup{
    [self setupMapSpacebar];
    
    //    //Draw the target
    //    [self drawTwoPointsVisualTarget];
    //
    //    // Start the validator
    //    // listen to the map change event
    //    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //    [center addObserver:self
    //               selector:@selector(twoPointsValidator)
    //                   name:MapUpdatedNotification
    //                 object:nil];
    
    // Start the timer
    [self.record start];
    
}

@end
