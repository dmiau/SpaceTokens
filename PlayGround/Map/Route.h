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
@interface Route : LineEntity

//------------------
// properties
//------------------
@property MKMapItem *source;
@property MKMapItem *destination;


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

@end
