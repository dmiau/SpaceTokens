//
//  ViewController+Annotations.m
//  SpaceBar
//
//  Created by dmiau on 8/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+Annotations.h"
#import "Map/CustomPointAnnotation.h"
#import <MapKit/MapKit.h>
#import "CustomMKMapView+Annotations.h"

@implementation ViewController (Annotations)

#pragma mark --annotation related methods--

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation*)annotation
{    
    // Call the map annotation method
    return [self.mapView viewForAnnotation:annotation];
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    // Let the mapView to handle annotation selection
    [self.mapView didSelectAnnotationView:view];
}
@end
