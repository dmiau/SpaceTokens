//
//  LineEntity.m
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "LineEntity.h"
#import <vector>
#import <iostream>
#import "POI.h"
#import "CustomMKMapView.h"
#include <cmath>
#include "NSValue+MKMapPoint.h"

using namespace std;

template class std::vector<pair<int, int>>;
template class std::vector<double>;


//============================
// Line entity class
//============================
@implementation LineEntity

- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    // Construct an array of mappoints
    MKMapPoint *tempMapPointArray = new MKMapPoint[ [mapPointArray count] ];
    
    for (int i = 0; i < [mapPointArray count]; i++){
        tempMapPointArray[i] = [mapPointArray[i] MKMapPointValue];
    }
    CustomMKPolyline *polyline = [CustomMKPolyline polylineWithPoints:tempMapPointArray count:[mapPointArray count]];
    delete[] tempMapPointArray;
    self = [self initWithMKPolyline:polyline];
    return self;
}

-(id)initWithMKPolyline:(MKPolyline*)polyline{
    self = [super init];
    self.annotation.pointType = path;
    self.polyline = polyline;
    self.name = @"unNamedLine";
    
    return self;
}

//-----------------
// Setters
//-----------------
-(void)setPolyline:(MKPolyline *)polyline{
    _polyline = polyline;
    [self populateInternalRouteProperties];
}


-(void)setIsEnabled:(BOOL)isEnabled{
    [super setIsEnabled:isEnabled];
    
    if (!isEnabled){
        self.isMapAnnotationEnabled = NO;
    }
}


-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (isMapAnnotationEnabled){
        // Add the annotation
        [mapView addOverlay:self.polyline level:MKOverlayLevelAboveRoads];
    }else{
        // Remove the annotation
        [mapView removeOverlay: self.polyline];
    }
}


//-----------------
// Compute accumulatedDist structure
//-----------------
-(void)populateInternalRouteProperties{
    //computer the accumulatedDist array
    self.mapPointX = new vector<double>;
    self.mapPointY = new vector<double>;
    self.accumulatedDist = new vector<double>;
    
    //------------
    // Get the polyline object
    //------------
    int pointNumber = self.polyline.pointCount;

    self.mapPointX->assign(pointNumber, 0);
    self.mapPointY->assign(pointNumber, 0);
    self.accumulatedDist->assign(pointNumber, 0);
    
    //------------------
    // Populate the accumulatedDist structures
    //------------------
    // This chunk could potentially take some time
    int pointIdx = 0;
    float accumulatedDist = 0;
    MKMapPoint previousMapPoint = self.polyline.points[0];
    for (int i = 0; i < pointNumber; ++i){
        (*self.mapPointX)[i] = self.polyline.points[i].x;
        (*self.mapPointY)[i] = self.polyline.points[i].y;
        
        // Calculate the distance from the current point to the previous point
        CLLocationDistance dist = MKMetersBetweenMapPoints
        (previousMapPoint, self.polyline.points[i]);
        accumulatedDist += dist;
        (*self.accumulatedDist)[i] = accumulatedDist;
        
        previousMapPoint = self.polyline.points[i];
    }

    //----------------
    // Populate SpatialEntity properties
    //----------------
    MKMapRect mapRect = [self getBoundingMapRect];
    MKCoordinateRegion coordRegion = MKCoordinateRegionForMapRect(mapRect);
    self.latLon = coordRegion.center;
    self.coordSpan = coordRegion.span;
}

-(MKMapRect)getBoundingMapRect{
    double minMapX, maxMapX, minMapY, maxMapY;
    
    vector<double>::iterator result = min_element(self.mapPointX->begin(), self.mapPointX->end());
    minMapX = *result;
    result = max_element(self.mapPointX->begin(), self.mapPointX->end());
    maxMapX = *result;
    
    result = min_element(self.mapPointY->begin(), self.mapPointY->end());
    minMapY = *result;
    result = max_element(self.mapPointY->begin(), self.mapPointY->end());
    maxMapY = *result;
    
    MKMapRect output = MKMapRectMake(minMapX, minMapY,
                                     maxMapX - minMapX, maxMapY - minMapY);
    return output;
}

-(std::vector<std::pair<float, float>>) calculateVisibleSegmentsForMap:(MKMapView*) mapView{
    
    
    // Test point visibility in two stages
    //http://stackoverflow.com/questions/12990148/get-all-positions-of-elements-in-stl-vector-that-are-greater-than-a-value
    
    // construct a rectangle from the four corners of the visible map:
    NSMutableArray* fourCorners = [[NSMutableArray alloc] initWithCapacity:4];
    
    // Get the MKMapPoints of the four corners
    float width = mapView.frame.size.width;
    float height = mapView.frame.size.height;
    
    CLLocationCoordinate2D topLeft =
    [mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:mapView];
    MKMapPoint topLeftMP = MKMapPointForCoordinate(topLeft);
    [fourCorners addObject:[NSValue valueWithCGPoint:CGPointMake(topLeftMP.x, topLeftMP.y)]];
    
    CLLocationCoordinate2D topRight =
    [mapView convertPoint:CGPointMake(width, 0) toCoordinateFromView:mapView];
    MKMapPoint topRightMP = MKMapPointForCoordinate(topRight);
    [fourCorners addObject:[NSValue valueWithCGPoint:CGPointMake(topRightMP.x, topRightMP.y)]];
    
    CLLocationCoordinate2D bottomRight =
    [mapView convertPoint:CGPointMake(width, height) toCoordinateFromView:mapView];
    MKMapPoint bottomRightMP = MKMapPointForCoordinate(bottomRight);
    [fourCorners addObject:[NSValue valueWithCGPoint:CGPointMake(bottomRightMP.x, bottomRightMP.y)]];
    
    CLLocationCoordinate2D bottomLeft =
    [mapView convertPoint:CGPointMake(0, height) toCoordinateFromView:mapView];
    MKMapPoint bottomLeftMP = MKMapPointForCoordinate(bottomLeft);
    [fourCorners addObject:[NSValue valueWithCGPoint:CGPointMake(bottomLeftMP.x, bottomLeftMP.y)]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, topLeftMP.x, topLeftMP.y);
    
    for (int i = 1; i < 4; i++){
        CGPoint p = [[fourCorners objectAtIndex:i] CGPointValue];
        CGPathAddLineToPoint(path, nil, p.x, p.y);
    }
    CGPathAddLineToPoint(path, nil, topLeftMP.x, topLeftMP.y); // close the path
    
    // test each point
    vector<int> insideIndices; insideIndices.clear();
    for (int i = 0; i < self.mapPointX->size(); i++){
        
        
        // This part can be optimized
        CGPoint aPoint = CGPointMake((*self.mapPointX)[i], (*self.mapPointY)[i]);
        if (CGPathContainsPoint (path, nil, aPoint, NO))
        {
            insideIndices.push_back(i);
        }
    }
    
    
    // TODO: the result could be further interpolated
    
    if (insideIndices.size() > 2){
        // check connectivity?
        vector<pair<int, int>> output; output.clear();
        output.push_back(make_pair(insideIndices[0], 0));
        for (int i = 1; i < insideIndices.size(); i++){
            
            if (insideIndices[i]-1 != insideIndices[i-1]){
                // unconsecutive index found
                output.back().second = insideIndices[i-1];
                output.push_back(make_pair(insideIndices[i], 0));
            }
        }
        output.back().second = insideIndices.back();
        
        // convert the result to percentage
        vector<pair<float, float>> percentageOutput; percentageOutput.clear();
        double totalDist = (*self.accumulatedDist).back();
        
        for (int i = 0; i < output.size(); i++){
            pair<float, float> temp_pair;
            int index = output[i].first;
            temp_pair.first = (*self.accumulatedDist)[index] / totalDist;
            index = output[i].second;
            temp_pair.second = (*self.accumulatedDist)[index] / totalDist;
            percentageOutput.push_back(temp_pair);
        }
        
        return percentageOutput;
    }else{
        vector<pair<float, float>> percentageOutput;
        percentageOutput.push_back(make_pair(nanf(""), nanf("")));
        cout << "The route is invisible!" << endl;
        return percentageOutput;
    }
}

double RadiansToDegrees(double radians) {return radians * 180.0/M_PI;};
double computeOrientationFromA2B
(MKMapPoint ref_mappoint, MKMapPoint measured_mappoint)
{
    double radiansBearing = atan2(measured_mappoint.x - ref_mappoint.x,
                                  -(measured_mappoint.y - ref_mappoint.y));
    
    double degree = RadiansToDegrees(radiansBearing);
    
    // This guarantees that the orientaiton is always positive
    if (degree < 0) degree += 360;
    return degree;
}


-(void) convertPercentage: (float)percentage
                 toLatLon: (CLLocationCoordinate2D&) latLon
              orientation: (double&) degree
{
    
    // Percentage needs to be between 0 and 1
    if (percentage < 0 || percentage > 1){
        [NSException raise:@"Programming error." format:@"Percentage must be between 0 and 1."];
    }
    
    // find out the segment correspond to the percetage
    double totalDist = self.accumulatedDist->back();
    
    std::vector<double>::iterator up;
    double distanceOfTouch = totalDist * percentage;
    up = std::upper_bound(self.accumulatedDist->begin(),
                          self.accumulatedDist->end(), distanceOfTouch);
    
    int idx = up - self.accumulatedDist->begin();
    
    // interpolate a mapPoint
    MKMapPoint mapPointA, mapPointB, mapPointBetween;
    
    if (idx == 0){
        
        // first point on the route
        mapPointBetween.x = (*self.mapPointX)[0];
        mapPointBetween.y = (*self.mapPointY)[0];
        degree = computeOrientationFromA2B
        (MKMapPointMake((*self.mapPointX)[0],(*self.mapPointY)[0]),
         MKMapPointMake((*self.mapPointX)[1],(*self.mapPointY)[1]));
    }else if (idx == (self.accumulatedDist->size() - 1)){
        
        // last point on the route
        int lastPointIndex = self.accumulatedDist->size() - 1;
        mapPointBetween.x = (*self.mapPointX)[lastPointIndex];
        mapPointBetween.y = (*self.mapPointY)[lastPointIndex];
        degree = computeOrientationFromA2B
        (MKMapPointMake((*self.mapPointX)[lastPointIndex-1],(*self.mapPointY)[lastPointIndex-1]),
         MKMapPointMake((*self.mapPointX)[lastPointIndex],(*self.mapPointY)[lastPointIndex]));
    }else{
        
        // in between two points
        mapPointA.x = (*self.mapPointX)[idx-1];
        mapPointA.y = (*self.mapPointY)[idx-1];
        
        mapPointB.x = (*self.mapPointX)[idx];
        mapPointB.y = (*self.mapPointY)[idx];
        
        double ratio = (distanceOfTouch - (*self.accumulatedDist)[idx-1])/
        ((*self.accumulatedDist)[idx] - (*self.accumulatedDist)[idx-1]);
        
        mapPointBetween.x = mapPointA.x * (1 - ratio) + mapPointB.x * ratio;
        mapPointBetween.y = mapPointA.y * (1 - ratio) + mapPointB.y * ratio;
        degree = computeOrientationFromA2B
        (mapPointA, mapPointBetween);
    }
    
    // prepare the outputs
    latLon = MKCoordinateForMapPoint(mapPointBetween);
}


//----------------
// Saving and loading
//----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    // Save the MKPolyline
    NSMutableArray *polylineArrayX = [[NSMutableArray alloc] init];
    NSMutableArray *polylineArrayY = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.polyline pointCount]; i++){
        [polylineArrayX addObject: [NSNumber numberWithDouble:self.polyline.points[i].x]];
        [polylineArrayY addObject: [NSNumber numberWithDouble:self.polyline.points[i].y]];
    }
    [coder encodeObject: polylineArrayX forKey:@"polylineArrayX"];
    [coder encodeObject: polylineArrayY forKey:@"polylineArrayY"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    // Reconstruct the polyline
    NSMutableArray *polylineArrayX = [coder decodeObjectOfClass:[NSMutableArray class] forKey:@"polylineArrayX"];
    NSMutableArray *polylineArrayY = [coder decodeObjectOfClass:[NSMutableArray class] forKey:@"polylineArrayY"];
    
    // Construct an array of mappoints
    MKMapPoint *tempMapPointArray = new MKMapPoint[ [polylineArrayX count] ];
    
    for (int i = 0; i < [polylineArrayX count]; i++){
        MKMapPoint mapPoint = MKMapPointMake([polylineArrayX[i] doubleValue], [polylineArrayY[i] doubleValue]);
        tempMapPointArray[i] = mapPoint;
    }
    self.annotation.pointType = path;
    self.polyline = [CustomMKPolyline polylineWithPoints:tempMapPointArray count:[polylineArrayX count]];
    delete[] tempMapPointArray;
    return self;
}



- (void) dealloc{
    // destructor
    delete self.mapPointX;
    delete self.mapPointY;
    delete self.accumulatedDist;
    //    NSLog(@"destructor called.");
}
@end
