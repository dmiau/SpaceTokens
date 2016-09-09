//
//  SnapshotPlace.m
//  SpaceBar
//
//  Created by Daniel on 9/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotPlace.h"
#import "ViewController.h"
#import "../Map/CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"

@implementation SnapshotPlace


- (void)setup{
    
    // Position the map to the initial condition
    MKCoordinateRegion region = MKCoordinateRegionMake(self.latLon, self.coordSpan);
    [self.rootViewController.mapView setRegion:region animated:NO];
    
    //Draw the target
    [self drawOnePointVisualTarget];
    
    // Start the validator
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onePointValidator)
                   name:MapUpdatedNotification
                 object:nil];
    
    // Start the timer
    [self.record start];
    
}









@end
