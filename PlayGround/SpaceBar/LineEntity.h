//
//  LineEntity.h
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#include <vector>
#include <utility>
#import "SpatialEntity.h"
#import "ArrayEntity.h"
#import "CustomMKPolyline.h"

using namespace std;

@interface LineEntity : ArrayEntity

@property CustomMKPolyline *polyline;

// the following vectors are used to look up POI, or ROI or a path
@property vector<double> *mapPointX;
@property vector<double> *mapPointY;
@property vector<double> *accumulatedDist;


//------------------
// methods
//------------------

// Constructor
- (id)initWithMKMapPointArray: (NSArray*) mapPointArray;
-(id)initWithMKPolyline:(CustomMKPolyline*)polyline;


-(std::vector<std::pair<float, float>>) calculateVisibleSegmentsForMap:
(MKMapView*) mapView;
-(void)convertPercentage: (float)percentage
                toLatLon: (CLLocationCoordinate2D&) latLon
             orientation: (double&) degree;

// Get the bounding box of the LineEntity
-(MKMapRect)getBoundingMapRect;
@end
