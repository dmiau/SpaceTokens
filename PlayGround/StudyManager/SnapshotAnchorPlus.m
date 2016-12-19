//
//  SnapshotAnchorPlus.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotAnchorPlus.h"

#import "ViewController.h"
#import "CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"

@implementation SnapshotAnchorPlus


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
    
    [[CustomMKMapView sharedManager] camera].heading = 0;
    // Start the timer
    [self.record start];
    
}


@end
