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
#import "SnapshotAnchorPlus.h"
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
    NSMutableArray* controlArray = [[NSMutableArray alloc] init];
    NSMutableArray* experimentArray = [[NSMutableArray alloc] init];
    
    
    //-------------------
    // Generate tasks for PLACE
    //-------------------
    NSMutableDictionary *placeTaskDictionary = [self generatePlaceDictionary];
    // Need to handle multiple conditions
    for (NSString *aKey in placeTaskDictionary){
        SnapshotPlace *snapshot = placeTaskDictionary[aKey];
        SnapshotPlace *snapshotCopy = [snapshot copy];
        
        snapshot.name = [snapshot.name stringByAppendingString:@":control"];
        snapshot.condition = CONTROL;
        [controlArray addObject:snapshot];
        
        snapshotCopy.name = [snapshotCopy.name stringByAppendingString:@":experiment"];
        snapshotCopy.condition = EXPERIMENT;
        [experimentArray addObject:snapshotCopy];
    }
 
    //-------------------
    // Generate tasks for ANCHOR
    //-------------------
    NSMutableDictionary *anchorTaskDictionary = [self generateAnchorPlusDictionary];
    // Need to handle multiple conditions
    for (NSString *aKey in anchorTaskDictionary){
        SnapshotPlace *snapshot = anchorTaskDictionary[aKey];
        SnapshotPlace *snapshotCopy = [snapshot copy];
        
        snapshot.name = [snapshot.name stringByAppendingString:@":control"];
        snapshot.condition = CONTROL;
        [controlArray addObject:snapshot];
        
        snapshotCopy.name = [snapshotCopy.name stringByAppendingString:@":experiment"];
        snapshotCopy.condition = EXPERIMENT;
        [experimentArray addObject:snapshotCopy];
    }
    

    //-------------------
    // Assemble the task vector
    //-------------------
    NSMutableArray *taskArray = [[NSMutableArray alloc] init];
    [taskArray addObjectsFromArray:controlArray];
    [taskArray addObjectsFromArray:experimentArray];
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
    tokenPOI.name = @"Grand Central";
    tokenPOI.latLon = CLLocationCoordinate2DMake(40.7527, -73.9772);
    tokenPOI.coordSpan = MKCoordinateSpanMake(0.0104439, 0.01);

    
    //---------------------
    // Create a target POI (one for each snapshot)
    //---------------------
    NSDictionary *angleDictionary = @{@"east": @0, @"northeast": @45,
                                      @"north": @90, @"northwest": @135,
                                      @"west": @180, @"southwest": @225,
                                      @"south": @270, @"southeast": @315};
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
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
        POI *target = [self generateTargetForReferencePOI:tokenPOI withAngle:degree
                                           offSetDistance:20+ mapView.frame.size.width * 0.4];
        
        [placeSnapshot.targetedPOIs addObject:target];
        
        // Generate the ID and instructions
        placeSnapshot.name = [NSString stringWithFormat:@"PLACE:%@", aKey];
        placeSnapshot.instructions =
        [NSString stringWithFormat:@"Inspect the area %@ of Grand Central.", aKey];
        outDictionary[placeSnapshot.name] = placeSnapshot;
    }
    
    return outDictionary;
}

//=====================
// Method to generate tasks for Anchor + Place
//=====================
- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )generateAnchorPlusDictionary{
    NSMutableDictionary *outDictionary = [[NSMutableDictionary alloc] init];
    
    //---------------------
    // Initial condition
    //---------------------
    
    // London City Hall
    MKCoordinateRegion initRegion =
    MKCoordinateRegionMake(
                           CLLocationCoordinate2DMake(51.5044, -0.0772236),
                           MKCoordinateSpanMake(0.00432843, 0.00504386));
    
    //---------------------
    // Create an anchor (at centroid)
    //---------------------
    
    // Grand Central for now
    POI *anchorPOI = [[POI alloc] init];
    anchorPOI.name = @"London City Hall";
    anchorPOI.latLon = initRegion.center;
    anchorPOI.coordSpan = initRegion.span;
    
    
    //---------------------
    // Create a target SpaceToken POI (one for each snapshot)
    //---------------------
    NSDictionary *angleDictionary = @{@"east": @0, @"northeast": @45,
                                      @"north": @90, @"northwest": @135,
                                      @"west": @180, @"southwest": @225,
                                      @"south": @270, @"southeast": @315};
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // 8 directions
    for (NSString *aKey in [angleDictionary allKeys]){
        
        double degree = [angleDictionary[aKey] doubleValue];
        
        // Create a snapshot
        SnapshotAnchorPlus *anchorSnapshot = [[SnapshotAnchorPlus alloc] init];
        
        // Set the initial condition
        anchorSnapshot.latLon = initRegion.center;
        anchorSnapshot.coordSpan = initRegion.span;
        
        // Assemble the POI for the anchor
        [anchorSnapshot.highlightedPOIs addObject:anchorPOI];
        
        // Assemble the POI for the spacetoken
        POI *token = [self generateTargetForReferencePOI:anchorPOI withAngle:degree
                                           offSetDistance:mapView.frame.size.height * 2];
        token.name = @"Hotel";
        [anchorSnapshot.poisForSpaceTokens addObject:token];
        
        // Assemble the POI for the targeted area
        [anchorSnapshot.targetedPOIs addObject:anchorPOI];
        [anchorSnapshot.targetedPOIs addObject:token];
        
        // Generate the ID and instructions
        anchorSnapshot.name = [NSString stringWithFormat:@"ANCHOR:%@", aKey];
        anchorSnapshot.instructions =
        [NSString stringWithFormat:@"Inspect the area between the anchor and hotel."];
        outDictionary[anchorSnapshot.name] = anchorSnapshot;
    }
    
    return outDictionary;
}

//----------------
// Generate a target POI
//----------------
- (POI*)generateTargetForReferencePOI: (POI*) tokenPOI withAngle: (double)degree offSetDistance: (double) offset{
    POI* outPOI = [[POI alloc] init];
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    // Use the map to perform the calculation
    [mapView snapOneCoordinate:tokenPOI.latLon
                          toXY:CGPointMake(mapView.frame.size.width/2, mapView.frame.size.height/2) animated:NO];
    
    // Calculate the desired rect, then the desired region
    double diameter = mapView.frame.size.width * 0.8;
    double arm = offset; //20 + diameter/2;
    
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
