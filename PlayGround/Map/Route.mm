//
//  Route.m
//  SpaceBar
//
//  Created by dmiau on 6/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route.h"
#import <vector>
#import <iostream>
#import "POI.h"
#import "CustomMKMapView.h"
#include <cmath>
#include "NSValue+MKMapPoint.h"
#include "CustomMKPolyline.h"

using namespace std;

template class std::vector<pair<int, int>>;
template class std::vector<double>;

//============================
// Route class
//============================
@implementation Route

-(id)init{
    self = [super init];
    self.annotation.pointType = path;
    return self;
}

// MARK: Initialization
- (id)initWithMKRoute: (MKRoute *) aRoute Source:(POI *)source Destination:(POI *)destination
{
    self = [super initWithMKPolyline:aRoute.polyline];
    self.annotation.pointType = path;
    
    [self setContent: [NSMutableArray arrayWithObjects:source, destination, nil]];
    self.name = [NSString stringWithFormat:@"%@ - %@", source.name, destination.name];
    return self;
}

- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    
    self = [super initWithMKMapPointArray:mapPointArray];
    self.annotation.pointType = path;
    // Construct source and destination
    POI *sourcePOI = [[POI alloc] init];
    sourcePOI.name = @"source";
    sourcePOI.latLon = MKCoordinateForMapPoint([mapPointArray[0] MKMapPointValue]);
    
    
    POI *destinationPOI = [[POI alloc] init];
    sourcePOI.name = @"destination";
    sourcePOI.latLon = MKCoordinateForMapPoint([[mapPointArray lastObject] MKMapPointValue]);
    
    [self setContent: [NSMutableArray arrayWithObjects:sourcePOI, destinationPOI, nil]];
    
    self.name = [NSString stringWithFormat:@"%@ - %@", sourcePOI.name, destinationPOI.name];
    return self;
}


//----------------
// MARK: --Interactions--
//----------------
- (double)getPointDistanceToTouch:(UITouch*)touch{
    
    if (!self.polyline)
        return 1000;
    
    // TODO: need to clean this part (the algorithm is very inefficient)
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint touchPoint = [touch locationInView:mapView];
    CLLocationCoordinate2D coord = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    
    double distanceInMeters = [self distanceOfPoint:mapPoint toPoly:self.polyline];
    double maxMeters = [self metersFromPixel:15 atPoint:touchPoint];
    
    if (distanceInMeters > maxMeters){
        return 1000;
    }else{
        return (distanceInMeters/maxMeters*15);
    }
}


// http://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}

/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt
{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    
    CLLocationCoordinate2D coordA = [mapView convertPoint:pt toCoordinateFromView:mapView];
    CLLocationCoordinate2D coordB = [mapView convertPoint:ptB toCoordinateFromView:mapView];
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB));
}


//----------------
// MARK: -- Save the route --
//----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    // Save the source and destination
    [coder encodeObject: self.annotationDictionary forKey:@"annotationDictionary"];
}

- (id)initWithCoder:(NSCoder *)coder {    
    self = [super initWithCoder:coder];
    
    // Decode source and destination
    self.annotationDictionary = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"annotationDictionary"];
    return self;
}


@end
