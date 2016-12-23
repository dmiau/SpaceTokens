//
//  PlaceTaskGenerator.m
//  SpaceBar
//
//  Created by Daniel on 12/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PlaceTaskGenerator.h"
#import "SnapshotPlace.h"
#import "CustomMKMapView.h"


@implementation PlaceTaskGenerator


- (id)init{
    self = [super init];
    if (self){
        // TODO: The following two parameters are not functional currently
        self.taskNumber = 8;
        self.randomSeed = 127;
        
        self.initRegion =  MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(40.7534, -73.9415),
            MKCoordinateSpanMake(0.0104439, 0.0100001)); // some initial location where the station is invisible
        self.dataSetID = @"normal";
    }
    return self;
}



//---------------------
// Method to generate tasks for PLACE
//---------------------
- (NSMutableDictionary<NSString*, SnapshotPlace*> * )generateSnapshotDictionary{
    
    NSMutableDictionary *outDictionary = [[NSMutableDictionary alloc] init];
    
    //---------------------
    // Initial condition
    //---------------------
    MKCoordinateRegion initRegion = self.initRegion;
    
    //---------------------
    // Create a POI (SpaceToken)
    //---------------------
    
    // Grand Central for now
    POI *tokenPOI = [[POI alloc] init];
    tokenPOI.name = @"station";
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
        
        // Add a random variation to the angle
        NSUInteger noise = arc4random_uniform(11);
        degree = degree + (double)noise - 5;
        
        // Create a snapshot
        SnapshotPlace *placeSnapshot = [[SnapshotPlace alloc] init];
        
        // Set the initial condition
        placeSnapshot.latLon = initRegion.center;
        placeSnapshot.coordSpan = initRegion.span;
        
        // Assemble the POI for SpaceToken
        [placeSnapshot.poisForSpaceTokens addObject:tokenPOI];
        
        // Assemble the POI for the target area
        POI *target = [self p_generateTargetForReferencePOI:tokenPOI withAngle:degree
                                             offSetDistance:20+ mapView.frame.size.width * 0.4];
        
        [placeSnapshot.targetedPOIs addObject:target];
        
        // Generate the ID and instructions
        placeSnapshot.name = [NSString stringWithFormat:@"PLACE:%@:%@:%.0f",
                              self.dataSetID, aKey, degree];
        
        NSString * commonMessage =
        [NSString stringWithFormat:@"Inspect the area %@ of the station.", aKey];
        
        placeSnapshot.controlInstructions = [[commonMessage copy] stringByAppendingString:@"Tap the SpaceToken, and then pan the map."];
        
        placeSnapshot.spaceTokenInstructions = [[commonMessage copy] stringByAppendingString:@"Drag the SpaceToken directly."];
        
        placeSnapshot.instructions = @"empty";
        
        outDictionary[placeSnapshot.name] = placeSnapshot;
    }
    
    return outDictionary;
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
