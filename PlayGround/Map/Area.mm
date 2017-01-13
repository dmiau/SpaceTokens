//
//  Area.m
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Area.h"
#import "CustomMKMapView.h"
#include "NSValue+MKMapPoint.h"

@implementation Area
- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    
    self = [super initWithMKMapPointArray:mapPointArray];
    self.annotation.pointType = AREA;
    self.name = @"UnNamedArea";
    // Create a polygon
    self.polygon = [MKPolygon polygonWithPoints:self.polyline.points
                                          count:self.polyline.pointCount];
    
    return self;
}

-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (isMapAnnotationEnabled){
        // Add the annotation
        [mapView addOverlay:self.polygon level:MKOverlayLevelAboveRoads];
    }else{
        // Remove the annotation
        [mapView removeOverlay: self.polygon];
    }
}


//-----------------
// Save/Load
//-----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.annotation.pointType = AREA;
    // Create a polygon
    self.polygon = [MKPolygon polygonWithPoints:self.polyline.points
                                          count:self.polyline.pointCount];
    return self;
}
@end
