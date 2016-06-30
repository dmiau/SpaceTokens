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


#pragma mark RouteInterface
@interface Route : NSObject

@property MKRoute *route;
// Constructors
- (id)initWithMKRoute: (MKRoute *) aRoute;

-(std::vector<std::pair<float, float>>) calculateVisibleSegments;
-(CLLocationCoordinate2D) convertPercentagePointToLatLon: (float) percentage;

@end
