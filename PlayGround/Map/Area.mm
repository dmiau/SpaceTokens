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
    self.polygon = [CustomMKPolygon polygonWithPoints:self.polyline.points
                                          count:self.polyline.pointCount];
    
    return self;
}

-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{    
    if (isMapAnnotationEnabled){
        self.annotation.map = [CustomMKMapView sharedManager];
    }else{
        self.annotation.isFilled = NO;
        self.annotation.map = nil;
    }
}

-(void)setPolygon:(CustomMKPolygon *)polygon{
    _polygon = polygon;
    self.annotation.isFilled = NO;
    self.annotation.map = nil;
    self.annotation = nil;
    self.annotation = [[CustomGMSPolyline alloc] initWithMKPolygon:polygon];
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
    self.polygon = [CustomMKPolygon polygonWithPoints:self.polyline.points
                                          count:self.polyline.pointCount];
    return self;
}
@end
