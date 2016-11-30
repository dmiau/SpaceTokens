//
//  SpaceBar+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 6/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Interactions.h"


@implementation SpaceBar (Interactions)

//-----------------------
// delegate methods of CERangeSliderDelegate
- (void) privateSliderOnePointTouched: (double) percentage{
    
    if (self.delegateRespondsTo.spaceBarOnePointTouched){
        // need to take the current upper and lower value into accunt
        if (!self.smallValueOnTopOfBar){
            // when the small value is on the bottom
            percentage = 1 - percentage;
        }
        [self.delegate spaceBarOnePointTouched: percentage];
    }
}

- (void) privateSliderTwoPOintsTouchedLow:(double)lowerPercentage high:(double)upperPercentage
{
    if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
        
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
        }        
        [self.delegate spaceBarTwoPointsTouchedLow:lowerPercentage high:upperPercentage];
    }
}

- (void) privateSliderElevatorMovedLow:(double) lowerPercentage
                                  high:(double)upperPercentage
                                  fromLowToHigh: (bool) directionFlag
{
    if (self.delegateRespondsTo.spaceBarElevatorMoved){
        
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
            directionFlag = !directionFlag;
        }
        [self.delegate spaceBarElevatorMovedLow:lowerPercentage
                                           high:upperPercentage
                                  fromLowToHigh: directionFlag];
    }
}
//-----------------------

- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair{
    
    float low, high;
    if (isnan(percentagePair[0]) || isnan(percentagePair[1])){
        low = nanf(""); high = nanf("");
    }else{
        low = MIN(percentagePair[0], percentagePair[1]);
        high = MAX(percentagePair[0], percentagePair[1]);
        
        if (!self.smallValueOnTopOfBar){
            double tempLow = low;
            low = 1 - high;
            high = 1 -tempLow;
        }
    }

    [self.sliderContainer updateElevatorPercentageLow:low high:high];
}
@end
