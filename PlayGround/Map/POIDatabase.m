//
//  POIDatabase.m
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POIDatabase.h"


@implementation POIDatabase

- (id) init{
    self = [super init];
    if (self){
        self.poiArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reloadPOI{
    [self.poiArray removeAllObjects];
    
    POI *poi1 = [[POI alloc] init];
    poi1.latLon = CLLocationCoordinate2DMake(40.712784, -74.005941);
    poi1.name = @"NY Downtown";
    [self.poiArray addObject:poi1];
    
    POI *poi2 = [[POI alloc] init];
    poi2.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
    poi2.name = @"Columbia U.";
    [self.poiArray addObject:poi2];
    
    POI *poi3 = [[POI alloc] init];
    poi3.latLon = CLLocationCoordinate2DMake(37.774929, -122.419416);
    poi3.name = @"San Francisco";
    [self.poiArray addObject:poi3];
    
    POI *poi4 = [[POI alloc] init];
    poi4.latLon = CLLocationCoordinate2DMake(42.360082, -71.058880);
    poi4.name = @"Boston";
    [self.poiArray addObject:poi4];
    
    POI *poi5 = [[POI alloc] init];
    poi5.latLon = CLLocationCoordinate2DMake(35.689487, 139.691706);
    poi5.name = @"35.689487, 139.691706";
    [self.poiArray addObject:poi5];
}
@end
