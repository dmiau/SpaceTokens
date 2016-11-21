//
//  TaskGenerator+Anchor.m
//  SpaceBar
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TaskGenerator+Anchor.h"
#import "SnapshotAnchorPlus.h"
#import "CustomMKMapView.h"

@implementation TaskGenerator (Anchor)

//=====================
// Method to generate tasks for Anchor + Place
//=====================
- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )p_generateAnchorPlusDictionary{
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
        POI *token = [self p_generateTargetForReferencePOI:anchorPOI withAngle:degree
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

@end
