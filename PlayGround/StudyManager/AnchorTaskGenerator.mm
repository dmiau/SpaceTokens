//
//  AnchorTaskGenerator.m
//  SpaceBar
//
//  Created by dmiau on 12/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AnchorTaskGenerator.h"
#import "SnapshotAnchorPlus.h"
#import "CustomMKMapView.h"
#import <vector>
#import <random>
#import "NSMutableArray+Tools.h"

using namespace std;

@implementation AnchorTaskGenerator

- (id)init{
    self = [super init];
    if (self){
        self.taskNumber = 10;
        self.randomSeed = 127; // This is to generate the random map orientations
        self.baseDistanceInPixel = 600;
        self.initRegion = MKCoordinateRegionMake(
                CLLocationCoordinate2DMake(51.5044, -0.0772236),
                MKCoordinateSpanMake(0.00432843, 0.00504386));
        self.dataSetID = @"normal"; // either normal of mutant
    }
    return self;
}

- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )generateSnapshotDictionary{
    
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
    
    
    int anchorTaskNumber = self.taskNumber;
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    //--------------------
    // Generate a list of distances and orientations for points
    //--------------------
    
    // generate a list of distances
    vector<float> distanceVector;
    for (int i=1; i<=anchorTaskNumber+1; ++i)
        distanceVector.push_back(i* self.baseDistanceInPixel);
    // Remove the middle distance
    float hotelDistance = *(distanceVector.begin()+anchorTaskNumber/2);
    distanceVector.erase(distanceVector.begin()+anchorTaskNumber/2);
    random_shuffle ( distanceVector.begin(), distanceVector.end() );
    
    // Generate a list of museum distance
    // This requires some attention. The distance of museum should lie in two ranges.
    // 0.25-0.5    2-3
    vector<float> museumDistanceVector;
    float closeStart = 0.25 * hotelDistance;
    float closeStep = 0.25 * hotelDistance / (anchorTaskNumber/2 -1);
    float farStart = 2 * hotelDistance;
    float farStep = hotelDistance / (anchorTaskNumber/2 -1);
    for (int i = 0; i< anchorTaskNumber/2; i++){
        museumDistanceVector.push_back(closeStart + i*closeStep);
        museumDistanceVector.push_back(farStart + i* farStep);
    }
    random_shuffle ( museumDistanceVector.begin(), museumDistanceVector.end() );
    
    // Generate a list of orientation
    vector<float> orientationVecotr;
    float degreeStep = 360.f / (anchorTaskNumber + 1);
    for (int i=0; i<anchorTaskNumber; ++i) orientationVecotr.push_back(degreeStep*(i+1));
    
    //--------------------
    // Generate a list of map rotations
    //--------------------
    
    // Generate anchorTaskNumber map rotation
    vector<float> mapRotationInDegree;
    
    std::mt19937 rng(self.randomSeed);
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
        MKCoordinateRegion initRegion = self.initRegion;
        
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
        float degree = orientationVecotr[i];
        float distance = museumDistanceVector[i];
        CGPoint museumPoint = CGPointMake(
                                          cafePoint.x + distance * cos(degree/180 * M_PI),
                                          cafePoint.y + distance * sin(degree/180 * M_PI));
        
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
        anchorSnapshot.name =
        [NSString stringWithFormat:@"ANCHOR:%@:%d", self.dataSetID, i];
        
        anchorSnapshot.controlInstructions = @"Is the cafe closer to the hotel or the museum?\nTap the desired tokens to investigate.";
        anchorSnapshot.spaceTokenInstructions = @"Is the cafe closer to the hotel or the museum?\nAnchor the cafe and tap the desired tokens to investigate.";
        
        anchorSnapshot.instructions = @"Is the cafe closer to the hotel or the museum?";
        
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
    
    // Rotate the map back
    mapView.camera.heading = 0;
    
    
    return outDictionary;
    
}


-(NSMutableArray*)createPOIsFromCGPointArray:(vector<CGPoint>)cgPointVector{
    NSMutableArray *outArray = [[NSMutableArray alloc] init];
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    NSArray *distractorNames =
  @[@"arbor", @"omega", @"bar", @"sigma", @"delta", @"epsilon", @"gamma", @"lamda",
    @"kappa", @"rho", @"tau"];
    
    if (cgPointVector.size() > [distractorNames count]){
        [NSException raise:@"sourcCodeNeedsUpdate" format:@"distractorNames needs to be updated."];
    }
    
    for (int i = 0; i < cgPointVector.size(); i++){
        CGPoint aPoint = cgPointVector[i];
        
        POI *aPOI = [[POI alloc] init];
        aPOI.name = distractorNames[i];
        aPOI.latLon = [mapView
                       convertPoint:aPoint toCoordinateFromView:mapView];
        aPOI.coordSpan = mapView.region.span;
        
        [outArray addObject:aPOI];
    }
    return outArray;
}
@end
