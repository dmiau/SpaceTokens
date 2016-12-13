//
//  SpaceBar+Annotations.m
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Annotations.h"
#import "../Map/Route.h"

@implementation SpaceBar (Annotations)
- (void) addAnnotationsFromRoute:(Route *) route{

    // Find the dimensions
    CGPoint sliderContainerOrigin = self.sliderContainer.frame.origin;
    
    // Add the source label
    UILabel *sourceLabel = [self generateAnnotationLabelWithName:route.source.name
                                                    atPercentage:0];
    [sourceLabel sizeToFit];
    //right justified x
    //self.sliderContainer.frame.size.width - sourceLabel.frame.size.width
    sourceLabel.frame =  CGRectMake(
                0,
    self.sliderContainer.frame.size.height - self.sliderContainer.trackPaddingInPoints, sourceLabel.frame.size.width, sourceLabel.frame.size.height);
    [self.annotationView addSubview:sourceLabel];

    
    // Add the destination label
    UILabel *destinationLabel = [self generateAnnotationLabelWithName:route.destination.name
                                                         atPercentage:0];
    [destinationLabel sizeToFit];
    
    // right justified x
    // self.sliderContainer.frame.size.width - destinationLabel.frame.size.width
    destinationLabel.frame = CGRectMake(
            0,
                                        0, destinationLabel.frame.size.width, destinationLabel.frame.size.height);
    [self.annotationView addSubview:destinationLabel];
    
    // Randomly add some annotations in between
    UILabel *aLabel = [self generateAnnotationLabelWithName:@"25%" atPercentage:0.25];
    [self.annotationView addSubview:aLabel];

    UILabel *bLabel = [self generateAnnotationLabelWithName:@"50%" atPercentage:0.50];
    [self.annotationView addSubview:bLabel];
    
    UILabel *cLabel = [self generateAnnotationLabelWithName:@"75%" atPercentage:0.75];
    [self.annotationView addSubview:cLabel];
    
}

// Annotation label factory
- (UILabel*)generateAnnotationLabelWithName: (NSString*) name atPercentage:(float)percentage{
    
    if (!self.smallValueOnTopOfBar){
        percentage = 1-percentage;
    }
    
    float horizontalPosition = percentage * (self.sliderContainer.frame.size.height - 2 * self.sliderContainer.trackPaddingInPoints) + self.sliderContainer.trackPaddingInPoints;
    
    // Add the source label
    UILabel *myLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(0, horizontalPosition - 15
                                            , 60, 30)];
    myLabel.text = name;
    [myLabel setTextColor:[UIColor blackColor]];
    [myLabel setBackgroundColor:[UIColor clearColor]];
    [myLabel setFont: [UIFont fontWithName:@"Trebuchet MS" size:14.0f]];
    return myLabel;
}

- (void) removeRouteAnnotations{
    [[self.annotationView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
@end
