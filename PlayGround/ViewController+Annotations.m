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

- (void) mapView:(GMSMapView *) mapView
didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate
{
    [[AnnotationCollection sharedManager] resetAnnotations];
}

//- (void)mapView:(GMSMapView *)mapView
//didTapPOIWithPlaceID:(NSString *)placeID
//           name:(NSString *)name
//       location:(CLLocationCoordinate2D)location
//{
//    NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
//}

GMSMarker *infoMarker;
- (void)mapView:(GMSMapView *)mapView
didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location
{    
    infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.snippet = placeID;
    infoMarker.title = name;
    infoMarker.opacity = 0;
    CGPoint pos = infoMarker.infoWindowAnchor;
    pos.y = 1;
    infoMarker.infoWindowAnchor = pos;
    infoMarker.map = mapView;
    mapView.selectedMarker = infoMarker;
}

@end
