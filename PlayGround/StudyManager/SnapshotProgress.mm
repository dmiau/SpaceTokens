//
//  SnapshotProgress.m
//  SpaceBar
//
//  Created by dmiau on 8/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotProgress.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "../Map/Route.h"

//----------------------
// PROGRESS
//----------------------
@implementation SnapshotProgress

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
    // REFACTOR
//    [self.rootViewController.mapView setRegion:region animated:NO];
    
    

//    [self.rootViewController.mainViewManager showPanelWithType:TASKCHECKING];
    
    // Start the timer
}

- (void)cleanup{
    
}

@end
