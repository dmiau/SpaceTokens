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
- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )p_generateAnchorPlusDictionary
{
    
    //
    //         hotel---------------------museum
    //        /
    //   cafe/
    //
    // all angles are in degree, 0 is E, CCW
    
    NSMutableDictionary *outDictionary = [[NSMutableDictionary alloc] init];

    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    //---------------------
    // Initial condition
    //---------------------
    
    // London City Hall
    MKCoordinateRegion initRegion =
    MKCoordinateRegionMake(
                           CLLocationCoordinate2DMake(51.5044, -0.0772236),
                           MKCoordinateSpanMake(0.00432843, 0.00504386));
    
    // Shift the map to London
    [mapView setRegion:initRegion];
    
    //---------------------
    // Create a hotel
    //---------------------
    CGPoint hotelCGPoint = mapView.center;
    
    
    //---------------------
    // Create a museum
    //---------------------
    double museumDistance = 2400; // in pixels
    double museumAngle = 0; // in degree, 0 is E, CCW
    CGPoint museumCGPoint = CGPointMake(
            mapView.center.x + museumDistance * cos(museumAngle/180 * M_PI),
            mapView.center.y + museumDistance * sin(museumAngle/180 * M_PI));
    
    //---------------------
    // Create a cafe
    //---------------------
    double cafeDistance = 1000;
    NSArray *cafeAngles = @[@0, @30, @150, @210];
    
    for (NSNumber *anAngle in cafeAngles){
        
        double degee = [anAngle doubleValue];
        CGPoint cafeCGPoint = CGPointMake(
            mapView.center.x + cafeDistance * cos(degee/180 * M_PI),
            mapView.center.y + cafeDistance * sin(degee/180 * M_PI));
        
        // Compute all the coordinates and generate snapshot
        
        // Calculate the relative distnaces to the cafe
        
        
        // ===== Museum POI
        POI* museumPOI = [[POI alloc] init];
        museumPOI.name = @"museum";
        museumPOI.latLon = [mapView
                            convertPoint:museumCGPoint toCoordinateFromView:mapView];
        museumPOI.coordSpan = initRegion.span;
        
        // ===== Hotel POI
        POI* hotelPOI = [[POI alloc] init];
        hotelPOI.name = @"hotel";
        hotelPOI.latLon = [mapView
                            convertPoint:hotelCGPoint toCoordinateFromView:mapView];
        hotelPOI.coordSpan = initRegion.span;
    
        // ===== Cafe POI
        POI* cafePOI = [[POI alloc] init];
        cafePOI.name = @"cafe";
        cafePOI.latLon = [mapView
                           convertPoint:cafeCGPoint toCoordinateFromView:mapView];
        cafePOI.coordSpan = initRegion.span;
        
        // Create a SpaceToken
        SnapshotAnchorPlus *anchorSnapshot = [[SnapshotAnchorPlus alloc] init];
        
        // Set the initial condition (to cafe)
        anchorSnapshot.latLon = cafePOI.latLon;
        anchorSnapshot.coordSpan = cafePOI.coordSpan;
        
        // Add the anchor POI
        [anchorSnapshot.highlightedPOIs addObject:cafePOI];
        
        // Assemble the POI for the spacetoken
        [anchorSnapshot.poisForSpaceTokens addObject:hotelPOI];
        [anchorSnapshot.poisForSpaceTokens addObject:museumPOI];
        

        // Generate the ID and instructions
        NSString *aKey = [NSString stringWithFormat:@"%@", anAngle];
        anchorSnapshot.name = [NSString stringWithFormat:@"ANCHOR:%@", aKey];
        anchorSnapshot.instructions =
        [NSString stringWithFormat:@"Is the cafe on the way (from hotel to the museum)?"];
        
        // Generate the questions and answers
        anchorSnapshot.segmentOptions = @[@"Yes", @"No"];
        anchorSnapshot.correctAnswers = [[NSSet alloc] initWithObjects:@"Yes", nil];
        
        outDictionary[anchorSnapshot.name] = anchorSnapshot;
    }
    
    return outDictionary;
}

@end
