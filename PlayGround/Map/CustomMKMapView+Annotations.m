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
    
    if ([annotation pointType] == landmark){
        
        // try to dequeue an existing pin view first
        static NSString *landmarkAnnotationID = @"landmarkAnnotationID";
        
        MKAnnotationView *pinView =
        (MKAnnotationView *) [self dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
        
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
    }else if ([annotation pointType] == YouRHere){
        //---------------
        // Heading image
        //---------------
        static NSString *headingAnnotationID = @"headingAnnotationID";
        
        MKAnnotationView *pinView =
        (MKAnnotationView *) [self dequeueReusableAnnotationViewWithIdentifier:headingAnnotationID];
        
        if (pinView == nil)
        {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:headingAnnotationID];
        }else{
            pinView.annotation = annotation;
        }
        [pinView setCanShowCallout:NO];
        
        UIImage *starImg = [UIImage imageNamed:@"grayYouRHere.png"];
        
        pinView.image = [self resizeImage:starImg
                                  newSize:CGSizeMake(12, 12)];
        return pinView;
    }else{
        MKAnnotationView *pinView = [[MKPinAnnotationView alloc] init];
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
