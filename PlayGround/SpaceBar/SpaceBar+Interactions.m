//
//  SpaceBar+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 6/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Interactions.h"

@implementation SpaceBar (Interactions)


// delegate methods of CERangeSliderDelegate
- (void) sliderOnePointTouched{
    
    if (self.delegateRespondsTo.spaceBarOnePointTouched){
        
        // need to take the current upper and lower value into accunt
        double percentage = self.rangeSlider.lowerValue/self.rangeSlider.maximumValue;
        if (!self.smallValueOnTopOfBar){
            // when the small value is on the bottom
            percentage = 1 - percentage;
        }
        [self.delegate spaceBarOnePointTouched: percentage];
    }
}

- (void) sliderTwoPOintsTouched{
    if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
        
        double lowerPercentage = self.rangeSlider.lowerValue/self.rangeSlider.maximumValue;
        double upperPercentage = self.rangeSlider.upperValue/self.rangeSlider.maximumValue;
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
        }
        
        float temp[2];
        temp[0] = lowerPercentage;
        temp[1] = upperPercentage;
        [self.delegate spaceBarTwoPointsTouched: temp];        
    }
}

- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair{
    
    float barLowerValue = percentagePair[0] * self.rangeSlider.maximumValue;
    float barUpperValue = percentagePair[1] * self.rangeSlider.maximumValue;
    
    if (!self.smallValueOnTopOfBar){
        barLowerValue = self.rangeSlider.maximumValue - barLowerValue;
        barUpperValue = self.rangeSlider.maximumValue - barUpperValue;
    }
    
    self.rangeSlider.lowerValue = barLowerValue;    
    self.rangeSlider.upperValue = barUpperValue;
}

- (void) addAnchorForCoordinates: (CLLocationCoordinate2D) coord atMapXY:(CGPoint)mapXY{
    if (!self.anchor){
        // create a new POI for anchor if an anchor does not exist
        self.anchor = [[SpaceToken alloc] initForType:ANCHORTOKEN];
    }
    self.anchor.poi.latLon = coord;
    self.anchor.poi.mapViewXY = mapXY;
}

- (void) updateAnchorAtMapXY:(CGPoint)mapXY
{
    if (self.anchor){
        self.anchor.poi.mapViewXY = mapXY;
    }
}

- (void) removeAnchor{
    // remove the anchor from the dragging set
    if (self.anchor){
        [self.draggingSet removeObject:self.anchor];
        self.anchor = nil;
    }
}

@end
