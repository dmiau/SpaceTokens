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
    NSMutableDictionary *placeTaskDictionary = [self p_generatePlaceDictionary];
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
    NSMutableDictionary *anchorTaskDictionary = [self p_generateAnchorPlusDictionary];
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




//----------------
// Generate a target POI
//----------------
- (POI*)p_generateTargetForReferencePOI: (POI*) tokenPOI withAngle: (double)degree offSetDistance: (double) offset{
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
