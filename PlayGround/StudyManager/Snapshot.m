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
#import "TokenCollectionView.h"

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
        self.poisForSpaceTokens = [[NSMutableArray alloc] init];
        
        // Initialize the record object
        self.record = [[Record alloc] init];
    }
    return self;
}

//---------------------
// setters
//---------------------
-(void)setName:(NSString *)name{
    super.name = name;
    _record.name = name;
}

-(void)setCondition:(Condition)condition{
    _condition = condition;
    
    // Assign the instructions based on the condition
    if (condition == CONTROL){
        self.instructions = self.controlInstructions;
    }else{
        self.instructions = self.spaceTokenInstructions;
    }
}

#pragma mark --CommonSetup--
- (void) setupMapSpacebar{
    // Position the map to the initial condition
    MKCoordinateRegion region = MKCoordinateRegionMake(self.latLon, self.coordSpan);
    [self.rootViewController.mapView setRegion:region animated:NO];
    
    // Set up the SpaceToken correctly
    SpaceBar *spaceBar = self.rootViewController.spaceBar;
    [spaceBar removeAllSpaceTokens];
    TokenCollectionView* tokenCollectionView = [TokenCollectionView sharedManager];
    tokenCollectionView.isVisible = YES;
    [tokenCollectionView reloadData];
    
    // Remove all annotations
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeAnnotations:mapView.annotations];
    
    // Add the needed annotations
    for (POI *aPOI in self.highlightedPOIs){
        aPOI.annotation.pointType = STAR;
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

- (void)drawTwoPointsVisualTarget{
    // Get the map point equivalents to compute the mid point
    MKMapPoint mapPoint0 = MKMapPointForCoordinate(self.targetedPOIs[0].latLon);
    MKMapPoint mapPoint1 = MKMapPointForCoordinate(self.targetedPOIs[1].latLon);
    
    // Compute the distance between two mapPoints
    CLLocationDistance meters = MKMetersBetweenMapPoints(mapPoint0, mapPoint1);
    
    MKMapPoint midPoint = MKMapPointMake((mapPoint0.x + mapPoint1.x)/2, (mapPoint0.y + mapPoint1.y)/2);
    CLLocationCoordinate2D midCoord = MKCoordinateForMapPoint(midPoint);
    
    targetCircle = [MKCircle circleWithCenterCoordinate:midCoord radius:meters/2]; // radius is measured in meters
    [self.rootViewController.mapView addOverlay:targetCircle];
    
    // Change the color of the circle
    MKCircleRenderer *renderer =
    [self.rootViewController.mapView rendererForOverlay:completionIndicator];
    renderer.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0];
}

#pragma mark --Tools--
-(NSString*)firstNComponentsFromCode:(int)n{
    NSArray *components = [self.name componentsSeparatedByString:@":"];
    NSString *key;
    
    if ([components count] < n){
        key = self.name;
    }else{
        key = [[components  subarrayWithRange:NSMakeRange(0, n)] componentsJoinedByString:@":"];
    }
    return key;
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
    [super encodeWithCoder:coder];    
    
    [coder encodeObject:self.instructions forKey:@"instructions"];
    [coder encodeObject:self.controlInstructions forKey:@"controlInstructions"];
    [coder encodeObject:self.spaceTokenInstructions forKey:@"spaceTokenInstructions"];
    [coder encodeObject:self.highlightedPOIs forKey:@"highlightedPOIs"];
    [coder encodeObject:self.poisForSpaceTokens forKey:@"poisForSpaceTokens"];
    [coder encodeObject:self.targetedPOIs forKey:@"targetedPOIs"];
    
    // For multiple selections
    [coder encodeObject:self.segmentOptions forKey:@"segmentOptions"];
    [coder encodeObject:self.correctAnswers forKey:@"correctAnswers"];
    
    [coder encodeObject:[NSNumber numberWithInt:self.condition] forKey:@"condition"];
}

- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];    
    self.instructions = [coder decodeObjectOfClass:[NSString class] forKey:@"instructions"];
    self.controlInstructions = [coder decodeObjectOfClass:[NSString class] forKey:@"controlInstructions"];
    self.spaceTokenInstructions = [coder decodeObjectOfClass:[NSString class] forKey:@"spaceTokenInstructions"];
    self.highlightedPOIs = [[coder decodeObjectOfClass:[NSArray class] forKey:@"highlightedPOIs"] mutableCopy];
    self.poisForSpaceTokens = [[coder decodeObjectOfClass:[NSArray class] forKey:@"poisForSpaceTokens"] mutableCopy];
    self.targetedPOIs = [[coder decodeObjectOfClass:[NSArray class] forKey:@"targetedPOIs"] mutableCopy];
    
    self.segmentOptions = [coder decodeObjectOfClass:[NSArray class] forKey:@"segmentOptions"];
    self.correctAnswers = [coder decodeObjectOfClass:[NSSet class]  forKey:@"correctAnswers"];
    
    // Restore condition
    self.condition = (Condition)
    [[coder decodeObjectOfClass:[NSString class] forKey:@"condition"] integerValue];
    
    return self;
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    
    // Copy important POI data    
    Snapshot *object = [[[self class] allocWithZone:zone] init];
    object.latLon = self.latLon;
    object.name = self.name;
    object.coordSpan = self.coordSpan;
    
    // Copy Snapshot specific data
    object.instructions = [self.instructions copy];
    object.controlInstructions = [self.controlInstructions copy];
    object.spaceTokenInstructions = [self.spaceTokenInstructions copy];
    object.highlightedPOIs = [[NSMutableArray alloc] initWithArray:self.highlightedPOIs copyItems:YES];
    object.poisForSpaceTokens = [[NSMutableArray alloc] initWithArray:self.poisForSpaceTokens copyItems:YES];
    object.targetedPOIs = [[NSMutableArray alloc] initWithArray:self.targetedPOIs copyItems:YES];
    
    object.segmentOptions = [[NSArray alloc] initWithArray:self.segmentOptions copyItems:YES];
    object.correctAnswers = [[NSSet alloc] initWithSet:self.correctAnswers copyItems:YES];    
    
    object.condition = self.condition;    
    return object;
}


- (NSString*) description{
    return [NSString stringWithFormat:@"latlon: %@",
            [NSString stringWithFormat:@"%g, %g", self.latLon.latitude, self.latLon.longitude]];
}


@end
