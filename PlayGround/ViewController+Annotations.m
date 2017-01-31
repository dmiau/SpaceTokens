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

// REFACTOR
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation*)annotation
//{    
//    // Call the map annotation method
//    return [self.mapView viewForAnnotation:annotation];
//}


-(bool)mapView:(GMSMapView *)mapView didTapMarker:(CustomPointAnnotation *)marker{
    [[AnnotationCollection sharedManager] resetAnnotations];
    marker.isHighlighted = YES;
    marker.isLabelOn = YES;
    [mapView setSelectedMarker: marker];
    return YES;
}

@end
