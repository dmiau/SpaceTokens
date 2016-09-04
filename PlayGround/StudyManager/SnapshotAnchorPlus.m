//
//  SnapshotAnchorPlus.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotAnchorPlus.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "../Map/customMKMapView.h"
#import "Constants.h"

@implementation SnapshotAnchorPlus{
    
}

- (id)init{
    self = [super init];
    if (self){
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    }
    return self;
}


- (void)setup{
    
    // Position the map to the initial condition
    MKCoordinateRegion region = MKCoordinateRegionMake(self.latLon, self.coordSpan);
    [self.rootViewController.mapView setRegion:region animated:NO];
    
    // Add a panel on top of the basePanel
    // Deprecated: [self.rootViewController.mainViewManager showPanelWithType:TASKCHECKING];
    
    // Start the validator
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(validator)
                   name:MapUpdatedNotification
                 object:nil];
    
    // Start the timer
    
    
}

- (void)validator{

    // Stop the timer when the goal is achieved

    
    
    
    
    
    
    
    // Disable the map interactions
    
    // Report the result
    
    // Game manager takes care of the following?
    // Clean up
    // Terminate the task
}

- (void)cleanup{
    
}

@end
