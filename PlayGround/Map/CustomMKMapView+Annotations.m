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


//------------------
// This function is called to prepare a view for an annotation
//------------------

- (MKAnnotationView *) viewForAnnotation:(CustomPointAnnotation*)annotation
{
    return [annotation generateAnnotationView];
}

-(void)didSelectAnnotationView:(MKAnnotationView *)view{    
    id selectedAnnotation = view.annotation;
    if ([view.annotation isKindOfClass:[CustomPointAnnotation class]]){
        CustomPointAnnotation *pointAnnotation = view.annotation;
        pointAnnotation.isHighlighted = YES;
        pointAnnotation.isLableOn = YES;
    }
    
    // Deselect all other annotations
    for (id annotation in [self annotations]){
        if ((annotation != selectedAnnotation) &&
            ([annotation isKindOfClass: [CustomPointAnnotation class]]))
        {
            CustomPointAnnotation *pointAnnotation = annotation;
            pointAnnotation.isHighlighted = NO;
            pointAnnotation.isLableOn = NO;
        }
    }
}

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
