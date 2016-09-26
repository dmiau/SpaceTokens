//
//  TaskGenerator.m
//  SpaceBar
//
//  Created by dmiau on 9/26/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TaskGenerator.h"
#import <MapKit/MapKit.h>
#import "SnapshotPlace.h"
#import "CustomMKMapView.h"

@implementation TaskGenerator

#pragma mark --Initialization--

+(TaskGenerator*)sharedManager{
    static TaskGenerator *sharedTaskGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTaskGenerator = [[TaskGenerator alloc] init];
    });
    return sharedTaskGenerator;
}

#pragma mark --Task Generation--
//---------------------
// Method to generate tasks for PLACE
//---------------------
- (NSMutableArray*)generateTasks{
    NSMutableArray* taskArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *taskDictionary = [self generatePlaceDictionary];

    for (NSString *aKey in taskDictionary){
        SnapshotPlace *snapshot = taskDictionary[aKey];
        [taskArray addObject:snapshot];
    }
    
    return taskArray;
}

//---------------------
// Method to generate tasks for PLACE
//---------------------
- (NSMutableDictionary<NSString*, SnapshotPlace*> * )generatePlaceDictionary{
    NSMutableDictionary *outDictionary = [[NSMutableDictionary alloc] init];
    
    //---------------------
    // Initial condition
    //---------------------
    MKCoordinateRegion initRegion =
    MKCoordinateRegionMake(
                           CLLocationCoordinate2DMake(40.7534, -73.9415),
                           MKCoordinateSpanMake(0.0104439, 0.0100001));
    
    //---------------------
    // Create a POI (SpaceToken)
    //---------------------
    
    // Grand Central for now
    POI *tokenPOI = [[POI alloc] init];
    tokenPOI.latLon = CLLocationCoordinate2DMake(40.7527, -73.9772);
    tokenPOI.coordSpan = MKCoordinateSpanMake(0.0104439, 0.01);

    
    //---------------------
    // Create a target POI (one for each snapshot)
    //---------------------
    NSDictionary *angleDictionary = @{@"east": @0, @"northeast": @45,
                                      @"north": @90, @"northwest": @135,
                                      @"west": @180, @"southwest": @225,
                                      @"south": @270, @"southeast": @315};
    
    // 8 directions
    for (NSString *aKey in [angleDictionary allKeys]){
        
        double degree = [angleDictionary[aKey] doubleValue];
        
        // Create a snapshot
        SnapshotPlace *placeSnapshot = [[SnapshotPlace alloc] init];
        
        // Set the initial condition
        placeSnapshot.latLon = initRegion.center;
        placeSnapshot.coordSpan = initRegion.span;
        
        // Assemble the POI for SpaceToken
        [placeSnapshot.poisForSpaceTokens addObject:tokenPOI];
        
        // Assemble the POI for the target area
        POI *target = [self generateTargetForTokenPOI:tokenPOI withAngle:degree];
        
        [placeSnapshot.targetedPOIs addObject:target];
        
        // Generate the ID and instructions
        placeSnapshot.name = [NSString stringWithFormat:@"PLACE:%@", aKey];
        placeSnapshot.instructions =
        [NSString stringWithFormat:@"Inspect the area %@ of Grand Central.", aKey];
        outDictionary[placeSnapshot.name] = placeSnapshot;
    }
    
    return outDictionary;
}

//----------------
// Generate a target POI
//----------------
- (POI*)generateTargetForTokenPOI: (POI*) tokenPOI withAngle: (double)degree{
    POI* outPOI = [[POI alloc] init];
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    // Use the map to perform the calculation
    [mapView snapOneCoordinate:tokenPOI.latLon
                          toXY:CGPointMake(mapView.frame.size.width/2, mapView.frame.size.height/2) animated:NO];
    
    // Calculate the desired rect, then the desired region
    double diameter = mapView.frame.size.width * 0.8;
    double arm = 20 + diameter/2;
    
    // Calculate the centroid (in CGPoint) of the region
    CGPoint viewCentroid = CGPointMake(mapView.frame.size.width/2, mapView.frame.size.height/2);
    CGPoint targetCentroid;
    targetCentroid.x = viewCentroid.x + arm * cos(degree/180 * M_PI);
    targetCentroid.y = viewCentroid.y - arm * sin(degree/180 * M_PI);
    
    // Calculate the rect
    CGRect targetRect = CGRectMake(targetCentroid.x - diameter/2,
                                   targetCentroid.y - diameter/2,
                                   diameter, diameter);
    // Convert the rect to latlon and latlon span
    MKCoordinateRegion targetRegion =
    [mapView convertRect:targetRect toRegionFromView:mapView];
    
    // Assemble the POI
    outPOI.latLon = targetRegion.center;
    outPOI.coordSpan = targetRegion.span;
    return outPOI;
}

@end
