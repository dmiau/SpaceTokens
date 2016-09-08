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
#import "../Map/CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"

@implementation SnapshotAnchorPlus{
    CustomMKMapView *mapView;
    MKCircle *circle;
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
        
        // Cache the map view
        mapView = [CustomMKMapView sharedManager];
        
        // Initlialize the POI list
        self.highlightedPOIs = [[NSMutableArray alloc] init];
        self.targetedPOIs = [[NSMutableArray alloc] init];
        
        // Initialize the record object
        self.record = [[Record alloc] init];
    }
    return self;
}


- (void)setup{
    
    // Position the map to the initial condition
    MKCoordinateRegion region = MKCoordinateRegionMake(self.latLon, self.coordSpan);
    [self.rootViewController.mapView setRegion:region animated:NO];
        
    // Start the validator
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(validator)
                   name:MapUpdatedNotification
                 object:nil];
    
    // Start the timer
    [self.record start];
    
}

- (void)validator{

    // Stop the timer when the goal is achieved
    BOOL passFlag = NO;
    
    // validator should only be called once
    if (self.record.isAnswered){
        return;
    }
    
    // Make sure the two points are visible
    CGPoint xy0 = [mapView convertCoordinate:self.targetedPOIs[0].latLon toPointToView:mapView];
    CGPoint xy1 = [mapView convertCoordinate:self.targetedPOIs[1].latLon toPointToView:mapView];
    CGRect mapRect = CGRectMake(0, 0, self.rootViewController.mapView.frame.size.width,
                                self.rootViewController.mapView.frame.size.height);
    passFlag = (CGRectContainsPoint(mapRect, xy0) && CGRectContainsPoint(mapRect, xy1));

    // Calculate the screen distance between the two points
    double dist = sqrt( pow(xy0.x - xy1.x, 2) + pow(xy0.y - xy1.y, 2));
    passFlag = passFlag && (dist > self.rootViewController.mapView.frame.size.width * 0.8);
    
    // if passed, Show the visual indication
    
    if (passFlag){
        [self.record end];
        // Get the map point equivalents to compute the mid point
        MKMapPoint mapPoint0 = MKMapPointForCoordinate(self.targetedPOIs[0].latLon);
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(self.targetedPOIs[1].latLon);
        
        // Compute the distance between two mapPoints
        CLLocationDistance meters = MKMetersBetweenMapPoints(mapPoint0, mapPoint1);
        
        MKMapPoint midPoint = MKMapPointMake((mapPoint0.x + mapPoint1.x)/2, (mapPoint0.y + mapPoint1.y)/2);
        CLLocationCoordinate2D midCoord = MKCoordinateForMapPoint(midPoint);
        
        circle = [MKCircle circleWithCenterCoordinate:midCoord radius:meters/2]; // radius is measured in meters
        [self.rootViewController.mapView addOverlay:circle];
        
        // Disable the map interactions
        self.rootViewController.mapView.userInteractionEnabled = NO;
        
        // Report the result
        GameManager *gameManager = [GameManager sharedManager];
        [gameManager reportCompletionFromSnashot:self];
        
        // Game manager takes care of the following?
        // Clean up
        // Terminate the task
    }
}

- (void)cleanup{
    //Reenable user interaction
    self.rootViewController.mapView.userInteractionEnabled = YES;
    
    // Remove the overlay
    [self.rootViewController.mapView removeOverlay: circle];
}

@end
