//
//  CustomPointAnnotation.m
//  SpaceBar
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomPointAnnotation.h"
#import "CustomMKMapView.h"

@implementation CustomPointAnnotation{
    UIImage *annotationImage;
    UILabel *aLabel;
}


-(id)init{
    self = [super init];
    
    _isLableOn = NO;
    self.pointType = LANDMARK;
    // Initialize the label
    aLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, -6, 80, 20)];
    return self;
}

-(void)setPointType:(location_enum)pointType{
    _pointType = pointType;
    
    if (pointType == LANDMARK){
        //--------------------------
        // Create a custom gray dot
        //--------------------------
        annotationImage =
        [self generateDotImageWithColor:[UIColor grayColor] andRadius:6];

    }else if(pointType == dropped){
        annotationImage =
        [self generateDotImageWithColor:[UIColor purpleColor] andRadius:6];
        
    }else if(pointType == YouRHere){
        
        //--------------------------
        // YouRHere
        //--------------------------
        UIImage *anImg = [UIImage imageNamed:@"grayYouRHere.png"];        
        annotationImage = [CustomPointAnnotation resizeImage:anImg                                  newSize:CGSizeMake(12, 12)];
        
    }else if(pointType == STAR){

        //--------------------------
        // A star image
        //--------------------------
        UIImage *starImg = [UIImage imageNamed:@"star-128.png"];
        annotationImage = [CustomPointAnnotation resizeImage:starImg
                                newSize:CGSizeMake(12, 12)];
    }else{
        annotationImage = nil;
    }
}


-(UIImage *)generateDotImageWithColor: (UIColor *) color andRadius: (float)radius
{
    // Create a custom red dot
    // http://stackoverflow.com/questions/14594782/how-can-i-make-an-uiimage-programatically
    CGSize size = CGSizeMake(radius*2, radius*2);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [path fill];
    UIImage *dotImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return dotImg;
}

//--------------
// Setters
//--------------
-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    if (isHighlighted){
        if (self.pointType == LANDMARK)
            annotationImage =
            [self generateDotImageWithColor:[UIColor redColor] andRadius:6];
    }else{
        if (self.pointType == LANDMARK)
            annotationImage =
            [self generateDotImageWithColor:[UIColor grayColor] andRadius:6];
    }
    // remove the current annotation from the map and add it back
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeAnnotation:self];
    [mapView addAnnotation: self];
}

-(void)setTitle:(NSString *)title{
    [super setTitle:title];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = [UIColor blackColor];
//    self.aLabel.alpha = 0.5;
    aLabel.text = title;
    aLabel.adjustsFontSizeToFitWidth = NO;
}

-(void)setIsLableOn:(bool)isLableOn{
    _isLableOn = isLableOn;
    
    // remove the current annotation from the map and add it back
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeAnnotation:self];
    [mapView addAnnotation: self];    
}

//--------------
// Helper method
//--------------
+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
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

//--------------
// Generate Annotation View
//--------------
-(MKAnnotationView *)generateAnnotationView{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([self isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    
    // try to dequeue an existing pin view first
    static NSString *landmarkAnnotationID = @"pointAnnotationID";
    
    MKAnnotationView *pinView =
    (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:landmarkAnnotationID];
    
    if (pinView == nil)
    {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:landmarkAnnotationID];
    }else{
        // Need to clear the existing annotations
        for (UIView *aView in pinView.subviews){
            if ([aView isKindOfClass:[UILabel class]]){
                [aView removeFromSuperview];
            }
        }
    }
    pinView.annotation = self;
    
    if (annotationImage)
        pinView.image = annotationImage;
    
    // Add a label to the annoation
    if (self.isLableOn && aLabel){
        [aLabel removeFromSuperview];
        [pinView addSubview: aLabel];
    }
    
    [pinView setEnabled:NO];
    return pinView;
}

@end


