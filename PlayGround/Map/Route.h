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

using namespace std;

#pragma mark RouteInterface
@interface Route : NSObject

//------------------
// properties
//------------------
@property NSString *name;
@property MKRoute *route;

@property MKMapItem *source;
@property MKMapItem *destination;

// the following vectors are used to look up POI, or ROI or a path
@property vector<double> *mapPointX;
@property vector<double> *mapPointY;
@property vector<int> *stepNumber;
@property vector<int> *indexInStep;
@property vector<double> *accumulatedDist;

//------------------
// methods
//------------------

// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute Source: (MKMapItem*) source
          Destination: (MKMapItem*) destination;

-(std::vector<std::pair<float, float>>) calculateVisibleSegmentsForMap:
                                (MKMapView*) mapView;
-(void)convertPercentage: (float)percentage
               toLatLon: (CLLocationCoordinate2D&) latLon
            orientation: (double&) degree;
@end
