//
//  Route.h
//  SpaceBar
//
//  Created by dmiau on 6/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#include <vector>
#include <utility>
#include "SpatialEntity.h"
#import "LineEntity.h"

using namespace std;
@class POI;

#pragma mark RouteInterface
@interface Route : LineEntity{
    NSMutableArray *routeSegmentArray; // This is to support the mutli-destination feature
    
}

//------------------
// properties
//------------------
@property MKMapItem *source;
@property MKMapItem *destination;
@property (nonatomic, copy) void (^routeReadyBlock)();

@property BOOL requestCompletionFlag;

//------------------
// methods
//------------------

// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute Source: (MKMapItem*) source
          Destination: (MKMapItem*) destination;


//------------------
// tools
//------------------
+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination;

// Create route with multiple points
-(void)requestRouteFromEntities: (NSArray *)entityArray;

-(void)requestRouteWithSource:(POI*) source Destination:(POI*) destination;
@end
