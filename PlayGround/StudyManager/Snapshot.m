//
//  Snapshot.m
//  SpaceBar
//
//  Created by Daniel on 9/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotProtocol.h"
#import "AppDelegate.h"
#import "../Map/CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"
#import "ViewController.h"

@implementation Snapshot

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
        
        // Initlialize the POI list
        self.highlightedPOIs = [[NSMutableArray alloc] init];
        self.targetedPOIs = [[NSMutableArray alloc] init];
        
        // Initialize the record object
        self.record = [[Record alloc] init];
    }
    return self;
}

#pragma mark --CommonSetup--
- (void) setupMapSpacebar{
    // Position the map to the initial condition
    MKCoordinateRegion region = MKCoordinateRegionMake(self.latLon, self.coordSpan);
    [self.rootViewController.mapView setRegion:region animated:NO];
    
    // Set up the SpaceToken correctly
    SpaceBar *spaceBar = self.rootViewController.spaceBar;
    spaceBar.isYouAreHereEnabled = NO;
    [spaceBar removeAllSpaceTokens];
    [spaceBar addSpaceTokensFromPOIArray:self.poisForSpaceTokens];
    
    
    // Remove all annotations
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeAnnotations:mapView.annotations];
    
    // Add the annotations
    for (POI *aPOI in self.highlightedPOIs){
        aPOI.isMapAnnotationEnabled = YES;
    }
}


#pragma mark --Target Drawing--
- (void)drawOnePointVisualTarget{
    MKMapRect targetRect = [CustomMKMapView MKMapRectForCoordinateRegion:
                            MKCoordinateRegionMake(self.targetedPOIs[0].latLon,
                                                   self.targetedPOIs[0].coordSpan)];
    
    // Compute the distance between two mapPoints
    MKMapPoint rightPoint = MKMapPointMake(targetRect.origin.x + targetRect.size.width,
                                           targetRect.origin.y);
    CLLocationDistance meters = MKMetersBetweenMapPoints(targetRect.origin,
                                                         rightPoint);
    targetCircle = [MKCircle circleWithCenterCoordinate:self.targetedPOIs[0].latLon
                                                 radius:meters/2]; // radius is measured in meters
    [self.rootViewController.mapView addOverlay:targetCircle];
}

#pragma mark --Validator--
- (void)onePointValidator{
    
    // Stop the timer when the goal is achieved
    BOOL passFlag = NO;
    
    // validator should only be called once
    if (self.record.isAnswered){
        return;
    }
    
    CustomMKMapView *mapView = self.rootViewController.mapView;
    
    
    // Make sure the target circle is visible
    MKMapPoint targetMapPoint = MKMapPointForCoordinate(self.targetedPOIs[0].latLon);
    
    
    MKMapRect mapViewRect =  mapView.visibleMapRect;
    MKMapRect targetRect = [CustomMKMapView MKMapRectForCoordinateRegion:
                            MKCoordinateRegionMake(self.targetedPOIs[0].latLon,
                                                   self.targetedPOIs[0].coordSpan)];
    passFlag = MKMapRectContainsRect(mapViewRect, targetRect);
    
    // Need to check the size of the target area
    // Calculate the screen distance between the two points of the circle
    CLLocationCoordinate2D coord0 =
    CLLocationCoordinate2DMake(self.targetedPOIs[0].latLon.latitude,
                               self.targetedPOIs[0].latLon.longitude -
                               self.targetedPOIs[0].coordSpan.longitudeDelta/2);
    CLLocationCoordinate2D coord1 =
    CLLocationCoordinate2DMake(self.targetedPOIs[0].latLon.latitude,
                               self.targetedPOIs[0].latLon.longitude +
                               self.targetedPOIs[0].coordSpan.longitudeDelta/2);
    CGPoint xy0 = [mapView convertCoordinate:coord0 toPointToView:mapView];
    CGPoint xy1 = [mapView convertCoordinate:coord1 toPointToView:mapView];
    
    double dist = sqrt( pow(xy0.x - xy1.x, 2) + pow(xy0.y - xy1.y, 2));
    passFlag = passFlag && (dist > self.rootViewController.mapView.frame.size.width * 0.8);
    
    
    if (passFlag){
        [self.record end];
        
        // Change overlay color
        //        MKOverlayView *anOverlay;  //You need to set this view to the object you are interested in
        //        anOverlay.backgroundColor = [UIColor redColor];
        //        [anOverlay setNeedsDisplay];
        
        
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

#pragma mark --TwoPoints--

- (void)twoPointsValidator{
    
    // Stop the timer when the goal is achieved
    BOOL passFlag = NO;
    
    // validator should only be called once
    if (self.record.isAnswered){
        return;
    }
    
    CustomMKMapView *mapView = self.rootViewController.mapView;
    
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
        
        completionIndicator = [MKCircle circleWithCenterCoordinate:midCoord radius:meters/2]; // radius is measured in meters
        [self.rootViewController.mapView addOverlay:completionIndicator];
        
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

#pragma mark --Clean up--
- (void)cleanup{
    //Reenable user interaction
    self.rootViewController.mapView.userInteractionEnabled = YES;
    
    // Remove the overlays
    [self.rootViewController.mapView removeOverlay: targetCircle];
    [self.rootViewController.mapView removeOverlay: completionIndicator];
}
@end