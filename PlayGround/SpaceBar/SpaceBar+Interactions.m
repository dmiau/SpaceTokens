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
        [self.delegate spaceBarOnePointTouched:
         self.rangeSlider.lowerValue/self.rangeSlider.maximumValue
         ];
    }
}

- (void) sliderTwoPOintsTouched{
    if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
        if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
            
            float temp[2];
            temp[0] = self.rangeSlider.lowerValue/self.rangeSlider.maximumValue;
            temp[1] = self.rangeSlider.upperValue/self.rangeSlider.maximumValue;
            [self.delegate spaceBarTwoPointsTouched: temp];
        }
    }
}


- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair{
    
    self.rangeSlider.lowerValue =
                percentagePair[0] * self.rangeSlider.maximumValue;
    self.rangeSlider.upperValue =
                percentagePair[1] * self.rangeSlider.maximumValue;
}
@end
