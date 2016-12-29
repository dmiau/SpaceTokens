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

using namespace std;
@class POI;

#pragma mark RouteInterface
@interface Route : SpatialEntity

//------------------
// properties
//------------------

@property MKRoute *route;
@property MKPolyline *routePolyline;

@property MKMapItem *source;
@property MKMapItem *destination;

// the following vectors are used to look up POI, or ROI or a path
@property vector<double> *mapPointX;
@property vector<double> *mapPointY;
//@property vector<int> *stepNumber;
//@property vector<int> *indexInStep;
@property vector<double> *accumulatedDist;


//------------------
// methods
//------------------

// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute Source: (MKMapItem*) source
          Destination: (MKMapItem*) destination;

- (id)initWithMKMapPointArray: (NSArray*) mapPointArray;

-(std::vector<std::pair<float, float>>) calculateVisibleSegmentsForMap:
                                (MKMapView*) mapView;
-(void)convertPercentage: (float)percentage
               toLatLon: (CLLocationCoordinate2D&) latLon
            orientation: (double&) degree;

// Get the bounding box of the route in terms of MKMapPoints
-(void)getMinMapX: (double&) minMapX andMaxMapX: (double&) maxMapX
       andMinMapY: (double&) minMapY andMaxMapY: (double&) maxMapY;

//------------------
// tools
//------------------
+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination;

@end
