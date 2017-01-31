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


@implementation ViewController (Annotations)

#pragma mark --annotation related methods--


-(bool)mapView:(GMSMapView *)mapView didTapMarker:(CustomPointAnnotation *)marker{

    return [self.mapView didTapMarker:marker];
}

- (void) mapView:(GMSMapView *) mapView
didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate
{
    [self.mapView didTapAtCoordinate:coordinate];
}


- (void)mapView:(GMSMapView *)mapView
didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location
{
    [self.mapView didTapPOIWithPlaceID:placeID name:name location:location];
}

@end
