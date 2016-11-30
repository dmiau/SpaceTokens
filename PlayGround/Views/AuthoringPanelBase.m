//
//  AuthoringPanelBase.m
//  SpaceBar
//
//  Created by Daniel on 11/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AuthoringPanelBase.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsButton.h"
#import "SnapshotPlace.h"
#import "SnapshotAnchorPlus.h"
#import "CustomMKMapView.h"
#import "EntityDatabase.h"

@implementation AuthoringPanelBase

#pragma mark --View Init--
- (id)init
{
    // your normal initialization here
    
    // Connect to the parent view controller to update its
    // properties directly
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];

    //-------------------
    // Initialize instace variables
    //-------------------
    snapShot = [[Snapshot alloc] init];
    spaceTokenPOIsArray = [[NSMutableArray alloc] init];
    highlightedPOIsArray = [[NSMutableArray alloc] init];
    targetedPOIsArray = [[NSMutableArray alloc] init];
    
    //-------------------
    // Set up the view
    //-------------------
    // set up the color of the view
    [self setBackgroundColor:[UIColor colorWithRed: 0.94 green:0.94 blue:0.94
                                             alpha:1.0]];
    settingsButton = [[SettingsButton alloc] init];
    
    authoringVisualAidLayer = [CAShapeLayer layer];
    return self;
}


//----------------
// Top panel delegate methods
//----------------

- (void)addPanel{
    
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    //    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, 0, mapWidth, panelHeight);
    [self.rootViewController.view addSubview:self];
    

    
    // Calculate targetRectBox
    float diameter = 0.8 * mapWidth;
    targetRectBox = CGRectMake(0.1*mapWidth, (mapHeight - diameter)/2, diameter, diameter);
    
    // Add the preference button
    [self.rootViewController.view addSubview: settingsButton];
    
    self.isAuthoringVisualAidOn = NO;
    
    // Reset the interface
    [self resetInterface];
    
    // Use the temporary POIArray for the POI database
    [[EntityDatabase sharedManager] useGameEntityArray:spaceTokenPOIsArray];
}


- (void)removePanel{
    // Remove the settings button
    [settingsButton removeFromSuperview];
    [self removeFromSuperview];
        
    // Restore the location of the map
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the bottom
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    self.rootViewController.mapView.frame = CGRectMake(0, panelHeight, mapWidth, mapHeight);
    
    self.isAuthoringVisualAidOn = NO;
    
    // Use the original POIArray
    [[EntityDatabase sharedManager] removeGameEntityArray];
}


//----------------
// Common methods
//----------------
- (void)addSnapshot{

}

- (void)captureInitialMap{
    // Draw the visual on the map
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Save the current map parameters
    MKCoordinateRegion coordinateRegion = mapView.region;
    snapShot.latLon = coordinateRegion.center;
    snapShot.coordSpan = coordinateRegion.span;
    
    // Need to get a square out of the rectangle
    MKMapRect mapRect = mapView.visibleMapRect;
    MKMapRect circleRect;
    
    // Assume the map is in portrait mode
    circleRect.origin = MKMapPointMake(mapRect.origin.x,
                                       mapRect.origin.y +
                                       (mapRect.size.height - mapRect.size.width)/2);
    circleRect.size.height = mapRect.size.width;
    circleRect.size.width = mapRect.size.width;
    
    
    MKCircle *circle = [MKCircle circleWithMapRect: circleRect];
    [mapView addOverlay:circle];
}


- (void)captureEndingMap{
    //    self.isAuthoringVisualAidOn = YES;
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [targetedPOIsArray addObject:poi];
    
    // Visualize the end circle
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    MKCircle *circle = [MKCircle circleWithMapRect:
                        [CustomMKMapView MKMapRectForCoordinateRegion:coordinateRegion]];
    [mapView addOverlay:circle];

    textSinkObject = snapShot;
}

-(MKCoordinateRegion)getTargetCoordinatRegion{
    // Get the map object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    MKCoordinateRegion coordinateRegion = [mapView convertRect:targetRectBox
                                              toRegionFromView:mapView];
    return coordinateRegion;
}




//-----------------
// Virtual functions
//-----------------
-(void)resetInterface{
    // This method should be overwritten.
}

@end
