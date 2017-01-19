//
//  Route+Appearance.m
//  SpaceBar
//
//  Created by Daniel on 1/19/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "Route+Appearance.h"
#import "POI.h"
#import "Route+Tools.h"

@implementation Route (Appearance)
-(void)updateRouteForContentArray{
    
    self.appearanceMode = ROUTEMODE;
        
    if ([contentArray count] < 2){
        self.polyline = nil;
        // Execute the route ready block
        if (self.routeReadyBlock){
            self.routeReadyBlock();
        }
        return;
    }
    
    
    routeSegmentArray = [NSMutableArray array];
    
    // Interate over each pair to get pari-wise routes
    for (int i = 1; i < [contentArray count]; i++){
        SpatialEntity *source = contentArray[i-1];
        SpatialEntity *destination = contentArray[i];
        
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

-(void)updateArrayForContentArray{
    // Remove the current annotation if there is any
    
    self.appearanceMode = ARRAYMODE;
    self.isMapAnnotationEnabled = NO;
    // Generate a polyline of the entities in contentArray
    NSArray *entityArray = [self getContent];
    MKMapPoint *tempMapPointArray = new MKMapPoint[[entityArray count]];
    
    int i = 0;
    for (SpatialEntity *entity in entityArray){
        MKMapPoint mapPoint = MKMapPointForCoordinate(entity.latLon);
        tempMapPointArray[i++] = mapPoint;
    }
    
    CustomMKPolyline *polyline = [CustomMKPolyline polylineWithPoints:tempMapPointArray count:[entityArray count]];
    self.polyline = polyline;

}


-(void)updateSetForContentArray{
    // Remove the current annotation if there is any
    
    self.appearanceMode = SETMODE;
    
    // Generate a polyline of the entities in contentArray
    NSArray *entityArray = [self getContent];
    MKMapPoint *tempMapPointArray = new MKMapPoint[[entityArray count]];
    
    int i = 0;
    for (SpatialEntity *entity in entityArray){
        MKMapPoint mapPoint = MKMapPointForCoordinate(entity.latLon);
        tempMapPointArray[i++] = mapPoint;
    }
    
    CustomMKPolyline *polyline = [CustomMKPolyline polylineWithPoints:tempMapPointArray count:[entityArray count]];
    self.polyline = polyline;
}

@end
