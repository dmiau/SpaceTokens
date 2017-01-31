//
//  CustomMKMapView+Annotations.m
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+Annotations.h"
#import "CustomPointAnnotation.h"
#import "CustomMKPolygon.h"
#import "CustomMKPolyline.h"
#import "POI.h"
#import "EntityDatabase.h"

@implementation CustomMKMapView (Annotations)

#pragma mark --Routes--
//------------------
// For route overlay
//------------------
- (MKOverlayRenderer *) rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]){
        
        //------------
        // Render a circle
        //------------
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        //        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return renderer;
    }else if ([overlay isKindOfClass:[MKPolygon class]]){
        
        //------------
        // Render a polygon
        //------------
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        //        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.2];
        return renderer;
        
        
        
        
    }else{
        
        //------------
        // Render a line
        //------------
        CustomMKPolyline *polylineOverlay = overlay;
        return [polylineOverlay generateOverlayRenderer];
    }
}


// MARK: Handles annotation interactions

-(bool) didTapMarker:(CustomPointAnnotation *)marker{
    [[EntityDatabase sharedManager] resetAnnotations];
    
    if ([marker isKindOfClass:[CustomPointAnnotation class]]){
        marker.isHighlighted = YES;
        marker.isLabelOn = YES;
    }
    
    [self setSelectedMarker: marker];
    return YES;
}

- (void) didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate
{
    [[EntityDatabase sharedManager] resetAnnotations];
}

- (void) didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location
{
    // Create a temporary entity
    POI *tempPOI = [[POI alloc] init];
    tempPOI.latLon = location;
    tempPOI.name = name;
    tempPOI.placeID = placeID;
    [[EntityDatabase sharedManager] addTempEntity:tempPOI];
    tempPOI.isMapAnnotationEnabled = YES;
    tempPOI.annotation.isHighlighted = YES;
    [self setSelectedMarker:tempPOI.annotation];
    
//    infoMarker = [GMSMarker markerWithPosition:location];
//    //    infoMarker.snippet = placeID;
//    infoMarker.title = name;
//    infoMarker.opacity = 0;
//    CGPoint pos = infoMarker.infoWindowAnchor;
//    pos.y = 1;
//    infoMarker.infoWindowAnchor = pos;
//    infoMarker.map = mapView;
//    mapView.selectedMarker = infoMarker;
}

@end
