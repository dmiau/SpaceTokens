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

@end
