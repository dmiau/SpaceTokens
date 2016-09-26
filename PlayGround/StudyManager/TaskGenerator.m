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

@implementation TaskGenerator

//---------------------
// Methods to generate tasks for PLACE
//---------------------
- (NSMutableDictionary *)generatePlaceDictionary{
    NSMutableDictionary *outDictionary;
    
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
    POI *tokenPOI;
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
        
        // Create a snapshot
        SnapshotPlace *place = [[SnapshotPlace alloc] init];
        
        // Assemble the POI for SpaceToken
        [place.poisForSpaceTokens addObject:tokenPOI];
        
        // Assemble the POI for the target area
        POI *target;
        target.latLon = CLLocationCoordinate2DMake(40.7527, -73.9772);
        target.coordSpan = MKCoordinateSpanMake(0.0104439, 0.01);
        
        [place.targetedPOIs addObject:target];
        
        outDictionary[@""] = place;
    }
    
    return outDictionary;
}

//----------------
// Generate a target POI
//----------------
- (POI*)generateTargetForTokenPOI: (POI*) poi withAngle: (NSNumber*)degree{
    POI* outPOI;
    
    // Use the hidden map  to perform the calculation
    
    
    
    
//    - (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
//animated: (BOOL) flag;
    
    
    
    
    return outPOI;
}

@end
