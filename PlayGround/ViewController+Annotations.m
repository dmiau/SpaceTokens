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
@implementation ViewController (Annotations)

#pragma mark --annotation related methods--

//------------------
// This function is called to prepare a view for an annotation
//------------------

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(CustomPointAnnotation*)annotation
{

    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation pointType] != heading){
        
        // try to dequeue an existing pin view first
        static NSString *landmarkAnnotationID = @"landmarkAnnotationID";
        
        MKAnnotationView *pinView =
        (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:landmarkAnnotationID];
        }else{
            pinView.annotation = annotation;
        }
        
        if (annotation.pointType == landmark){
//            [pinView setAnimatesDrop:NO];
            UIImage *starImg = [UIImage imageNamed:@"star-128.png"];
            
            pinView.image = [self resizeImage:starImg
                                      newSize:CGSizeMake(12, 12)];
        }else{
//            [pinView setAnimatesDrop:YES];
            
            
            
        }
//
//        [pinView setCanShowCallout:YES];
        
        
//        if ([annotation pointType] == dropped){
//            //---------------
//            // User triggered drop pin
//            //---------------
//            pinView = [self configureUserDroppedPinView: pinView];
//        }else if ([annotation pointType] == landmark){
//            //---------------
//            // Landmark pin
//            //---------------
//            pinView = [self configureLandmarkPinView: pinView];
//        }else if ([annotation pointType] == search_result){
//            //---------------
//            // Search pin
//            //---------------
//            pinView = [self configureUserDroppedPinView: pinView];
//        }
        return pinView;
    }else{
        //---------------
        // Heading image
        //---------------
        MKAnnotationView *pinView = [self addYouAreHereFromAnnotation:annotation];
        return pinView;
    }
}


- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}



//------------------
// Add heading annotation
//------------------
- (MKAnnotationView *) addYouAreHereFromAnnotation: (CustomPointAnnotation*)annotation
{
    // try to dequeue an existing pin view first
    static NSString *headingAnnotationID = @"headingAnnotationID";
    
    MKAnnotationView *pinView =
    (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:headingAnnotationID];
    
    if (pinView == nil)
    {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:headingAnnotationID];
    }else{
        pinView.annotation = annotation;
    }
    [pinView setCanShowCallout:NO];
    return pinView;
}

@end
