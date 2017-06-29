//
//  Route+Tools.h
//  NavTools
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route.h"

@interface Route (Tools)
-(void)assembleMutliSegmentRoute;
-(void)notAnPOIAlert: (SpatialEntity*) entity;
-(void)requestRouteWithSource:(POI*) source Destination:(POI*) destination;
@end
