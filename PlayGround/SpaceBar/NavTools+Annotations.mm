//
//  NavTools+Annotations.m
//  NavTools
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "NavTools+Annotations.h"
#import "Route.h"
#import "POI.h"

@implementation SpaceBar (Annotations)
- (void) addAnnotationsFromRoute:(Route *) route{
    
    // Add all the annotations
    for (NSNumber *aKey in [route.annotationDictionary allKeys]){
        SpatialEntity *anEnity = route.annotationDictionary[aKey];
        
        UILabel *cLabel = [self generateAnnotationLabelWithName:anEnity.name atPercentage:[aKey doubleValue]];
        [self.annotationView addSubview:cLabel];
    }
    
}

// Annotation label factory
- (UILabel*)generateAnnotationLabelWithName: (NSString*) name atPercentage:(float)percentage{
    
    if (!self.smallValueOnTopOfBar){
        percentage = 1-percentage;
    }
    
    float horizontalPosition = percentage * (self.sliderContainer.frame.size.height - 2 * self.sliderContainer.trackPaddingInPoints) + self.sliderContainer.trackPaddingInPoints;
    
    // Padding the two ends
    if (percentage < 0.0001){
        horizontalPosition += 4;
    }else if (percentage > 0.99){
        horizontalPosition -= 8;
    }
    
    // Add a label
    UILabel *myLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(15, horizontalPosition - 15
                                            , 90, 45)];
    myLabel.text = name;
    [myLabel setTextColor:[UIColor blackColor]];
    
    [myLabel setBackgroundColor:[UIColor clearColor]];
    
    [myLabel setFont: [UIFont fontWithName:@"Trebuchet MS" size:16.0f]];
    
    // Make the label two lines if necessary
    myLabel.adjustsFontSizeToFitWidth = YES;
    if ([myLabel.text length] > 8){
        myLabel.numberOfLines = 2;
    }
    
    return myLabel;
}

- (void) removeRouteAnnotations{
    [[self.annotationView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
@end
