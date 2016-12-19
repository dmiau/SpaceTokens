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
#import <vector>
#import <random>
#import "NSMutableArray+Tools.h"

using namespace std;


@implementation TaskGenerator (Anchor)

#define ANCHOR_TASK_NUMBER 10 // Note the anchor task number should always be even
#define RANDOM_SEED 127


//=====================
// Method to generate tasks for Anchor + Place
//=====================
- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )p_generateAnchorPlusDictionary
{
    // The idea of this task:
    // Given a cafe, the user needs to decide whether this cafe is closer to the
    // hotel or the museum.
    
    //
    //         cafe---------------------hotel
    //        /
    // museum/
    //
    // all angles are in degree, 0 is E, CCW
    
    // How the task is generated?
    // The cafe, the anchor, is always at the center. A hotel is then generated.
    // For n tasks, I will generate n+1 distances. The distance in the middle is
    // reserved for the distance from the cafe to the hotel, so half of the tasks
    // will have the museum closer than a hotel, and half of the tasks will have
    // it otherwise. An array of random orientations is generated to rotate the map
    // of each task, so the museum is not always at the 0 degree (east).
    
    
    int anchorTaskNumber = ANCHOR_TASK_NUMBER;
    float baseDistance = 600;
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    //--------------------
    // Generate a list of distances and orientations for points
    //--------------------
    
    // Shuffle a list of distances
    vector<float> distanceVector;
    for (int i=1; i<=anchorTaskNumber+1; ++i) distanceVector.push_back(i*baseDistance);
    // Remove the middle distance
    float hotelDistance = *(distanceVector.begin()+anchorTaskNumber/2);
    distanceVector.erase(distanceVector.begin()+anchorTaskNumber/2);
    
    random_shuffle ( distanceVector.begin(), distanceVector.end() );
    
    
    // Generate a list of orientation
    vector<float> orientationVecotr;
    float degreeStep = 360.f / (anchorTaskNumber + 1);
    for (int i=0; i<anchorTaskNumber; ++i) orientationVecotr.push_back(degreeStep*(i+1));
    
    //--------------------
    // Generate a list of map rotations
    //--------------------
    
    // Generate anchorTaskNumber map rotation
    vector<float> mapRotationInDegree;
    
    std::mt19937 rng(RANDOM_SEED);
    std::uniform_int_distribution<int> gen(0, 359); // uniform, unbiased
    
    for (int i = 0; i < anchorTaskNumber; i++){
        mapRotationInDegree.push_back(gen(rng));
    }

    //--------------------
    // Generate cafe and hotel points
    //--------------------
    
    // Generate a point for the cafe
    CGPoint cafePoint = CGPointMake(mapView.frame.size.width/2,
                                    mapView.frame.size.height/2);
    
    // Generate a point for the hotel
    CGPoint hotelPoint = CGPointMake(cafePoint.x + hotelDistance,
                                     cafePoint.y);
    
    //---------------------
    // Generate n locations
    //---------------------
    vector<CGPoint> cgPointVector;
    cgPointVector.clear();
    
    for (int i = 0; i < anchorTaskNumber; i++){
        
        float degree = orientationVecotr[i];
        float distance = distanceVector[i];
        CGPoint aPoint = CGPointMake(
                                     cafePoint.x + distance * cos(degree/180 * M_PI),
                                     cafePoint.y + distance * sin(degree/180 * M_PI));
        cgPointVector.push_back(aPoint);
    }
    
    //---------------------
    // Generate the output dictionary
    //---------------------
    NSMutableDictionary *outDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < anchorTaskNumber; i++){
        
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
        
        // Rotate the map
        mapView.camera.heading = mapRotationInDegree[i];
        

        //--------------------
        // cafe + hotel
        //--------------------
        POI* cafePOI = [[POI alloc] init];
        cafePOI.name = @"cafe";
        cafePOI.latLon = [mapView
                          convertPoint:cafePoint toCoordinateFromView:mapView];
        cafePOI.coordSpan = initRegion.span;
        
        POI* hotelPOI = [[POI alloc] init];
        hotelPOI.name = @"hotel";
        hotelPOI.latLon = [mapView
                          convertPoint:hotelPoint toCoordinateFromView:mapView];
        hotelPOI.coordSpan = initRegion.span;
        
        //--------------------
        // museum
        //--------------------
        // Generate a point for the museum
        CGPoint museumPoint = cgPointVector[i];
        
        POI* museumPOI = [[POI alloc] init];
        museumPOI.name = @"museum";
        museumPOI.latLon = [mapView
                           convertPoint:museumPoint toCoordinateFromView:mapView];
        museumPOI.coordSpan = initRegion.span;
        
        vector<CGPoint> distractorVector = cgPointVector;
        distractorVector.erase(distractorVector.begin()+i);
        
        //--------------------
        // distractors
        //--------------------
        NSMutableArray *distractorPOIArray = [self createPOIsFromCGPointArray:distractorVector];
        
        //--------------------
        // assemble the snapshot
        //--------------------
        SnapshotAnchorPlus *anchorSnapshot = [[SnapshotAnchorPlus alloc] init];
        
        // Set the initial condition (to cafe)
        anchorSnapshot.latLon = cafePOI.latLon;
        anchorSnapshot.coordSpan = cafePOI.coordSpan;
        
        // Add the anchor POI
        [anchorSnapshot.highlightedPOIs addObject:cafePOI];
        
        // Assemble the POI for the spacetoken
        [anchorSnapshot.poisForSpaceTokens addObject:hotelPOI];
        [anchorSnapshot.poisForSpaceTokens addObject:museumPOI];
        [anchorSnapshot.poisForSpaceTokens addObjectsFromArray:distractorPOIArray];
        
        // shuffle the order?
        [anchorSnapshot.poisForSpaceTokens shuffle];
        
        // Generate the ID and instructions
        anchorSnapshot.name = [NSString stringWithFormat:@"ANCHOR:%g", orientationVecotr[i]];
        anchorSnapshot.instructions =
        [NSString stringWithFormat:@"Is the cafe closer to the hotel or the museum?"];
        
        // Generate the questions and answers
        anchorSnapshot.segmentOptions = @[@"hotel", @"museum"];
        
        // Figure out the correct answer
        float museumDistance = distanceVector[i];
        if (museumDistance < hotelDistance){
            anchorSnapshot.correctAnswers = [[NSSet alloc] initWithObjects:@"Yes", nil];
        }else{
            anchorSnapshot.correctAnswers = [[NSSet alloc] initWithObjects:@"No", nil];
        }
        
        outDictionary[anchorSnapshot.name] = anchorSnapshot;
    }
    
    return outDictionary;
}

-(NSMutableArray*)createPOIsFromCGPointArray:(vector<CGPoint>)cgPointVector{
    NSMutableArray *outArray = [[NSMutableArray alloc] init];
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    for (int i = 0; i < cgPointVector.size(); i++){
        CGPoint aPoint = cgPointVector[i];
        
        POI *aPOI = [[POI alloc] init];
        aPOI.name = [NSString stringWithFormat:@"distractor-%d", i];
        aPOI.latLon = [mapView
                           convertPoint:aPoint toCoordinateFromView:mapView];
        aPOI.coordSpan = mapView.region.span;
        
        [outArray addObject:aPOI];
    }
    return outArray;
}

@end
