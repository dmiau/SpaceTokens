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


#pragma mark --Clean up--
- (void)cleanup{
    //Reenable user interaction
    self.rootViewController.mapView.userInteractionEnabled = YES;
    
    //Reset SpaceTokens, as a pre-caution
    [self.rootViewController.spaceBar removeAllSpaceTokens];
    
    // Remove the overlays
    [self.rootViewController.mapView removeOverlay: targetCircle];
    [self.rootViewController.mapView removeOverlay: completionIndicator];
}

#pragma mark --Save and Load--

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.latLon.latitude forKey:@"latLon.latitdue"];
    [coder encodeDouble:self.latLon.longitude forKey:@"latLon.longitude"];
    [coder encodeObject:self.name forKey:@"name"];
    
    [coder encodeObject:self.instructions forKey:@"instructions"];
    [coder encodeObject:self.highlightedPOIs forKey:@"highlightedPOIs"];
    [coder encodeObject:self.poisForSpaceTokens forKey:@"poisForSpaceTokens"];
    [coder encodeObject:self.targetedPOIs forKey:@"targetedPOIs"];
}

- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
//    self.latLon = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"latLon.latitdue"], [coder decodeDoubleForKey:@"latLon.longitude"]);
//    self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
    
    self.instructions = [coder decodeObjectOfClass:[NSString class] forKey:@"instructions"];
    self.highlightedPOIs = [coder decodeObjectOfClass:[NSString class] forKey:@"highlightedPOIs"];
    self.poisForSpaceTokens = [coder decodeObjectOfClass:[NSString class] forKey:@"poisForSpaceTokens"];
    self.targetedPOIs = [coder decodeObjectOfClass:[NSString class] forKey:@"targetedPOIs"];
    return self;
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    Snapshot *object = [[Snapshot alloc] init];
    object.latLon = self.latLon;
    object.name = self.name;
    
    
    
    return object;
}


- (NSString*) description{
    return [NSString stringWithFormat:@"latlon: %@",
            [NSString stringWithFormat:@"%g, %g", self.latLon.latitude, self.latLon.longitude]];
}


@end