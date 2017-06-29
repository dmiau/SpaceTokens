//
//  Route.h
//  NavTools
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

typedef enum {SETMODE, ARRAYMODE, ROUTEMODE, SKETCHEDROUTE} AppeararnceMode;

#pragma mark RouteInterface
@interface Route : LineEntity{
    NSMutableArray <Route*> *routeSegmentArray; // This is to support the mutli-destination feature
}

//------------------
// properties
//------------------
// Route request is an aynchronized call. So a routeReadyBlock is needed,
// so further actions can be performed when the request is received.
@property (nonatomic, copy) void (^routeReadyBlock)();

@property (nonatomic, copy) void (^appearanceChangedHandlingBlock)();


@property NSMutableDictionary <NSNumber*, SpatialEntity*> *annotationDictionary;
@property BOOL requestCompletionFlag;
@property AppeararnceMode appearanceMode;

@property MKDirectionsTransportType transportType;
@property CLLocationDistance distance;
@property NSTimeInterval expectedTravelTime;

//------------------
// methods
//------------------
// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute Source: (POI*) source
          Destination: (POI*) destination;

//------------------
// tools
//------------------
// This requests a route and add it to EntityDatabase
+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination;

@end
