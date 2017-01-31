//
//  ViewController+Annotations.m
//  SpaceBar
//
//  Created by dmiau on 8/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+Annotations.h"
#import "CustomPointAnnotation.h"
#import <MapKit/MapKit.h>
#import "CustomMKMapView+Annotations.h"
#import "AnnotationCollection.h"

@implementation ViewController (Annotations)

#pragma mark --annotation related methods--


-(bool)mapView:(GMSMapView *)mapView didTapMarker:(CustomPointAnnotation *)marker{
    [[AnnotationCollection sharedManager] resetAnnotations];
    marker.isHighlighted = YES;
    marker.isLabelOn = YES;
    [mapView setSelectedMarker: marker];
    return YES;
}

@end
