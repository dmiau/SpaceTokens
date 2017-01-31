//
//  POI.m
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POI.h"
#import "CustomMKMapView.h"

@implementation POI

// Custom set methods
- (void)setLatLon:(CLLocationCoordinate2D)latLon{
    [super setLatLon:latLon];
    self.annotation.position = latLon;
}


- (void)setName:(NSString *)name{
    [super setName:name];
    self.annotation.title = name;
}

-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{
    [super setIsMapAnnotationEnabled:isMapAnnotationEnabled];
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (isMapAnnotationEnabled){
        self.annotation.map = mapView;
    }else{
        self.annotation.map = nil;
    }
}

- (void)setMapAnnotationEnabled:(BOOL)flag onMap:(MKMapView*)map{
    if (flag){
        // Add the annotation
        [map addAnnotation:self.annotation];
    }else{
        // Remove the annotation
        [map removeAnnotation:self.annotation];
    }
}

@end
