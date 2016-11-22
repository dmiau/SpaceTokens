//
//  TaskGenerator+Place.m
//  SpaceBar
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TaskGenerator+Place.h"
#import "SnapshotPlace.h"
#import "CustomMKMapView.h"

@implementation TaskGenerator (Place)

//---------------------
// Method to generate tasks for PLACE
//---------------------
- (NSMutableDictionary<NSString*, SnapshotPlace*> * )p_generatePlaceDictionary{
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
        placeSnapshot.name = [NSString stringWithFormat:@"PLACE:%@", aKey];
        placeSnapshot.instructions =
        [NSString stringWithFormat:@"Inspect the area %@ of Grand Central.", aKey];
        outDictionary[placeSnapshot.name] = placeSnapshot;
    }
    
    return outDictionary;
}


@end
