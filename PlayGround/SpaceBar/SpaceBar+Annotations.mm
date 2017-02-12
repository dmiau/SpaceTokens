//
//  SpaceBar+Annotations.m
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Annotations.h"
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
    
    // Add the source label
    UILabel *myLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(0, horizontalPosition - 15
                                            , 80, 30)];
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
