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

typedef enum {ARRAYMODE, SETMODE, ROUTEMODE} AppeararnceMode;

#pragma mark RouteInterface
@interface Route : LineEntity{
    NSMutableArray *routeSegmentArray; // This is to support the mutli-destination feature
}

//------------------
// properties
//------------------
@property (nonatomic, copy) void (^routeReadyBlock)();
@property (nonatomic, copy) void (^appearanceChangedHandlingBlock)();
@property NSMutableDictionary <NSNumber*, SpatialEntity*> *annotationDictionary;
@property BOOL requestCompletionFlag;
@property AppeararnceMode appearanceMode;

//------------------
// methods
//------------------
// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute Source: (POI*) source
          Destination: (POI*) destination;

//------------------
// tools
//------------------
+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination;

// Create route with multiple points
-(void)requestRouteFromEntities: (NSArray *)entityArray;

-(void)updateRouteForContentArray;
-(void)updateArrayForContentArray;
-(void)updateSetForContentArray;
@end
