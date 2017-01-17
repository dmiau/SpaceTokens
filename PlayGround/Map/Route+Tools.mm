//
//  Route+Tools.m
//  SpaceBar
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route+Tools.h"
#import "POI.h"
#import "EntityDatabase.h"
#import "TokenCollectionView.h"
#import <vector>

using namespace std;

@implementation Route (Tools)

+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
    Route *aRoute = [[Route alloc] init];
    [aRoute setContent: [NSMutableArray arrayWithObjects:source, destination, nil]];
    void(^completionBlock)(void) = ^{
        // Push the newly created route into the entity database
        EntityDatabase *entityDatabase = [EntityDatabase sharedManager];
        [entityDatabase addEntity:aRoute];
        aRoute.isMapAnnotationEnabled = YES;
        NSLog(@"Direction response received!");
        NSLog(@"Rooute: %@ added.", aRoute.name);
        
        // Update the collection view
        [[TokenCollectionView sharedManager] addItemFromBottom:aRoute];
    };
    aRoute.routeReadyBlock = completionBlock;
    [aRoute requestRouteWithSource:source Destination:destination];
}


-(void)requestRouteFromEntities: (NSArray *)entityArray{
    [self setContent: [entityArray mutableCopy]];
    routeSegmentArray = [NSMutableArray array];
    
    // Interate over each pair to get pari-wise routes
    for (int i = 1; i < [entityArray count]; i++){
        SpatialEntity *source = entityArray[i-1];
        SpatialEntity *destination = entityArray[i];
        
        if (![source isKindOfClass:[POI class]]){
            [self notAnPOIAlert:source];
            return;
        }
        if (![destination isKindOfClass:[POI class]]){
            [self notAnPOIAlert:destination];
            return;
        }
        
        Route *aRoute = [[Route alloc] init];
        [routeSegmentArray addObject:aRoute];
        
        void(^complectionAction)(void) = ^(){
            [self assembleMutliSegmentRoute];
        };
        aRoute.routeReadyBlock = complectionAction;
        [aRoute requestRouteWithSource:(POI*)source Destination:(POI*)destination];
    }
}

-(void)assembleMutliSegmentRoute{
    BOOL allCompletionFlag = true;
    
    for (Route *aRoute in routeSegmentArray){
        allCompletionFlag =
        aRoute.requestCompletionFlag && allCompletionFlag;
    }
    
    // Do nothing until all the route requests are completed
    if (!allCompletionFlag)
        return;
    
    // Assemble the route (glue all the polylines into a long polyline)
    // Make a long MKMapPoint array
    vector<NSUInteger> pointCountVector;
    vector<MKMapPoint*>pointsArray;
    
    int accumulatedCount = 0;
    NSMutableDictionary <NSNumber*, SpatialEntity*> *indexEntityDictionary = [NSMutableDictionary dictionary];
    for (Route *aRoute in routeSegmentArray){
        pointCountVector.push_back(aRoute.polyline.pointCount);
        pointsArray.push_back(aRoute.polyline.points);
        
        indexEntityDictionary[@(accumulatedCount)] = [[aRoute getContent] firstObject];
        accumulatedCount += aRoute.polyline.pointCount;
    }
    MKMapPoint *accumulatedMapPoints = new MKMapPoint[accumulatedCount];
    indexEntityDictionary[@(accumulatedCount-1)] =
    [[(Route*)[routeSegmentArray lastObject] getContent] lastObject];
    
    int index = 0;
    for(int i = 0; i < pointCountVector.size(); i++){
        for (int j = 0; j < pointCountVector[i]; j++){
            accumulatedMapPoints[index++] = pointsArray[i][j];
        }
    }
    
    CustomMKPolyline *polyline = [CustomMKPolyline polylineWithPoints:accumulatedMapPoints
                                                count:accumulatedCount];
    delete[] accumulatedMapPoints;
    self.polyline = polyline;
    
    //------------------
    // Populate the annotation information
    //------------------
    
    // Sort the key of self.indexEntityDictionary
    NSArray *indices = [indexEntityDictionary allKeys];
    
    // Find out the corresponding percentage for each entity and store the results to indexEntityDictionary
    double totalDist = self.accumulatedDist->back();
    self.annotationDictionary = [NSMutableDictionary dictionary];
    for (NSNumber *index in indices){
        int i = [index integerValue];
        double percentage;
        if (i == 0){
            // The first one
            self.annotationDictionary[@0] = indexEntityDictionary[index];
        }else if (i == accumulatedCount-1){
            // The last one
            self.annotationDictionary[@1] = indexEntityDictionary[index];
        }else{
            // The ones in the middle
            percentage = (*self.accumulatedDist)[[index integerValue]]/totalDist;
            self.annotationDictionary[@(percentage)] = indexEntityDictionary[index];
        }
    }

    // Execute the route ready block
    if (self.routeReadyBlock){
        self.routeReadyBlock();
    }
}


-(void)notAnPOIAlert: (SpatialEntity*) entity{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Unsupported entity."
                        message:
                          [NSString stringWithFormat:@"%@ is not a POI.", entity.name]
                        delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
