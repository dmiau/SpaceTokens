//
//  CustomMKMapView+Annotations.m
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+Annotations.h"
#import "CustomPointAnnotation.h"

@implementation CustomMKMapView (Annotations)

//------------------
// This function is called to prepare a view for an annotation
//------------------

- (MKAnnotationView *) viewForAnnotation:(CustomPointAnnotation*)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // try to dequeue an existing pin view first
    static NSString *landmarkAnnotationID = @"pointAnnotationID";
    
    MKAnnotationView *pinView =
    (MKAnnotationView *) [self dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
    
    if (pinView == nil)
    {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
    }
    pinView.annotation = annotation;
    
    if (annotation.annotationImage)
        pinView.image = annotation.annotationImage;
    
    // Add a label to the annoation
    if (annotation.isLableOn && annotation.aLabel){
        [annotation.aLabel removeFromSuperview];
        [pinView addSubview: annotation.aLabel];
    }
    
    [pinView setEnabled:NO];
    return pinView;
}

#pragma mark --Routes--
//------------------
// For route overlay
//------------------
- (MKOverlayRenderer *) rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        //        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return renderer;
    }else{
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 5.0;
        return renderer;
    }
}

@end
