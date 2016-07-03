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


//------------------
// Route class
//------------------
@implementation Route


- (id)initWithMKRoute: (MKRoute *) aRoute{
    self = [super init];
    if (self) {
        
        self.route = aRoute;
        //computer the accumulatedDist array
        self.accumulatedDist = new vector<double>;
        
        self.accumulatedDist->assign([aRoute.steps count], 0);
        cout << self.accumulatedDist->size() << endl;

        (*self.accumulatedDist)[0] = aRoute.steps[0].distance;
        for (int i = 1; i < [aRoute.steps count]; i++){
            (*self.accumulatedDist)[i] = (*self.accumulatedDist)[i-1] + aRoute.steps[i].distance;
        }
    }
    return self;
}


-(std::vector<std::pair<float, float>>) calculateVisibleSegments{
    vector<pair<float, float>> output;
    
    return output;
}



-(CLLocationCoordinate2D) convertPercentagePointToLatLon: (float) percentage{
    
    // find out the segment correspond to the percetage
    double totalDist = self.accumulatedDist->back();
    
    std::vector<double>::iterator up;
    up = std::upper_bound(self.accumulatedDist->begin(),
        self.accumulatedDist->end(), totalDist * percentage);
    
    int idx = up - self.accumulatedDist->begin();
    
    MKPolyline *polyline = self.route.steps[idx-1].polyline;
    
    MKMapPoint aMapPoint = polyline.points[polyline.pointCount-1];
    
    return MKCoordinateForMapPoint(aMapPoint);
}

- (void) dealloc{
    // destructor
    delete self.accumulatedDist;
//    NSLog(@"destructor called.");
}
@end
