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
#import "HighlightedEntities.h"
#import "TokenCollectionView.h"
#import <vector>

using namespace std;

@implementation Route (Tools)

+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
    Route *aRoute = [[Route alloc] init];
    [aRoute setContent: [NSMutableArray arrayWithObjects:source, destination, nil]];
    void(^completionBlock)(void) = ^{
        
        NSLog(@"Direction response received!");
        NSLog(@"Rooute: %@ added.", aRoute.name);
        
        // Push the newly created route into the entity database
        [[EntityDatabase sharedManager] addEntity:aRoute];
        // Newly created route should be highlighted
        [[HighlightedEntities sharedManager] clearHighlightedSet];
        [[HighlightedEntities sharedManager] addEntity:aRoute];
    };
    aRoute.routeReadyBlock = completionBlock;
    [aRoute requestRouteWithSource:source Destination:destination];
}

// Make an asynchronous request for a route with the specified source and destination`
-(void)requestRouteWithSource:(POI*) source Destination:(POI*) destination{
    self.requestCompletionFlag = NO;
    
    // Get the direction from a start map item to an end map item
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    // Start map item
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:source.latLon addressDictionary:nil];
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    [startMapItem setName:source.name];
    request.source = startMapItem;
    
    // End map item
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination.latLon addressDictionary:nil];
    MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    [endMapItem setName:destination.name];
    request.destination = endMapItem;
    
    
    request.requestsAlternateRoutes = YES;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Direction request error."
                                   message: @"Direction request error."
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         } else {
             
             self.annotation.pointType = path;
             [self setContent: [NSMutableArray arrayWithObjects:source, destination, nil]];
             self.annotationDictionary = [NSMutableDictionary dictionary];
             self.annotationDictionary[@0] = source;
             self.annotationDictionary[@1] = destination;
             
             self.name = [NSString stringWithFormat:@"%@ - %@", source.name, destination.name];
             
             NSLog(@"A direction response for the route %@ is received.",
                   self.name);
             
             // There could be multiple routes
             // For now I will save one only
             for (MKRoute *route in response.routes)
             {
                 // Populate a route
                 self.polyline = [CustomMKPolyline
                                  polylineWithPoints:route.polyline.points
                                  count:route.polyline.pointCount];
                 
                 self.transportType = route.transportType;
                 self.distance = route.distance;
                 self.expectedTravelTime = route.expectedTravelTime;
                 
                 self.requestCompletionFlag = YES;
                 if (self.routeReadyBlock){
                     self.routeReadyBlock();
                     self.routeReadyBlock = nil;
                 }
                 break;
             }
         }
         
     }];
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
    
    NSTimeInterval totalTime = 0;
    CLLocationDistance totalDistance = 0;
    for (Route *aRoute in routeSegmentArray){
        pointCountVector.push_back(aRoute.polyline.pointCount);
        pointsArray.push_back(aRoute.polyline.points);
        
        indexEntityDictionary[@(accumulatedCount)] = [[aRoute getContent] firstObject];
        accumulatedCount += aRoute.polyline.pointCount;
        
        totalTime += aRoute.expectedTravelTime;
        totalDistance += aRoute.distance;
        
        // Show no annotations for temporary route!
        aRoute.isMapAnnotationEnabled = NO;
    }
    self.expectedTravelTime = totalTime;
    self.distance = totalDistance;
    
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
    self.dirtyFlag = @0;
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
