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
using namespace std;

template class std::vector<pair<int, int>>;

//------------------
// Route class
//------------------
@implementation Route


- (id)initWithMKRoute: (MKRoute *) aRoute{
    self = [super init];
    if (self) {
        
        self.route = aRoute;

        //computer the accumulatedDist array
        self.mapPointX = new vector<double>;
        self.mapPointY = new vector<double>;
        self.stepNumber = new vector<int>;
        self.indexInStep = new vector<int>;
        self.accumulatedDist = new vector<double>;
        
        // pre-allocate a chunk of memory
        int pointNumber = 0;
        for (int i = 0; i < [aRoute.steps count]; i++){
            pointNumber += aRoute.steps[i].polyline.pointCount;
        }
        
        self.mapPointX->assign(pointNumber, 0);
        self.mapPointY->assign(pointNumber, 0);
        self.stepNumber->assign(pointNumber, 0);
        self.indexInStep->assign(pointNumber, 0);
        self.accumulatedDist->assign(pointNumber, 0);
        
        //------------------
        // Populate the accumulatedDist structures
        //------------------
        // This chunk could potentially take some time
        int pointIdx = 0;
        float accumulatedDist = 0;
        MKMapPoint previousMapPoint = self.route.steps[0].polyline.points[0];
        for (int i = 0; i < [aRoute.steps count]; ++i){
            
            for (int j = 0; j < aRoute.steps[i].polyline.pointCount; ++j){
                
                MKPolyline* aPolyline = aRoute.steps[i].polyline;
                (*self.mapPointX)[pointIdx] = aPolyline.points[j].x;
                (*self.mapPointY)[pointIdx] = aPolyline.points[j].y;
                (*self.stepNumber)[pointIdx] = i;
                (*self.indexInStep)[pointIdx] = j;
                
                // Calculate the distance from the current point to the previous point
                CLLocationDistance dist = MKMetersBetweenMapPoints
                (previousMapPoint, aPolyline.points[j]);
                accumulatedDist += dist;
                (*self.accumulatedDist)[pointIdx] = accumulatedDist;
                
                previousMapPoint = aPolyline.points[j];
                pointIdx++;
            }
        }
    }
    return self;
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
}



-(CLLocationCoordinate2D) convertPercentagePointToLatLon: (float) percentage{
    
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
        mapPointBetween.x = (*self.mapPointX)[0];
        mapPointBetween.y = (*self.mapPointY)[0];
    }else if (idx == (self.accumulatedDist->size() - 1)){
        mapPointBetween.x = (*self.mapPointX)[self.accumulatedDist->size() - 1];
        mapPointBetween.y = (*self.mapPointY)[self.accumulatedDist->size() - 1];
    }else{
        mapPointA.x = (*self.mapPointX)[idx-1];
        mapPointA.y = (*self.mapPointY)[idx-1];
        
        mapPointB.x = (*self.mapPointX)[idx];
        mapPointB.y = (*self.mapPointY)[idx];
        
        double ratio = (distanceOfTouch - (*self.accumulatedDist)[idx-1])/
        ((*self.accumulatedDist)[idx] - (*self.accumulatedDist)[idx-1]);
        
        mapPointBetween.x = mapPointA.x * (1 - ratio) + mapPointB.x * ratio;
        mapPointBetween.y = mapPointA.y * (1 - ratio) + mapPointB.y * ratio;
    }
    
    return MKCoordinateForMapPoint(mapPointBetween);
}

- (void) dealloc{
    // destructor
    delete self.mapPointX;
    delete self.mapPointY;
    delete self.stepNumber;
    delete self.indexInStep;
    delete self.accumulatedDist;
//    NSLog(@"destructor called.");
}
@end
