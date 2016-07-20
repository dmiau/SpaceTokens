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
    UILabel *sourceLabel = [[UILabel alloc] initWithFrame:
    CGRectMake(-30,
               self.sliderContainer.frame.size.height - self.sliderContainer.trackPaddingInPoints
               , 60, 30)];
    sourceLabel.text = @"New York";
    [sourceLabel setTextColor:[UIColor blackColor]];
    [sourceLabel setBackgroundColor:[UIColor clearColor]];
    [sourceLabel setFont: [UIFont fontWithName:@"Trebuchet MS" size:14.0f]];
    [self.sliderContainer addSubview:sourceLabel];

    
    // Add the source label
    UILabel *destinationLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(-30, 0
                                       , 60, 30)];
    destinationLabel.text = @"Boston";
    [destinationLabel setTextColor:[UIColor blackColor]];
    [destinationLabel setBackgroundColor:[UIColor clearColor]];
    [destinationLabel setFont: [UIFont fontWithName:@"Trebuchet MS" size:14.0f]];
    [self.sliderContainer addSubview:destinationLabel];
    
}

@end