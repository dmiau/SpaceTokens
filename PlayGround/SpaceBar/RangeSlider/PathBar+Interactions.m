//
//  PathBar+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 7/21/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "PathBar+Interactions.h"
#import "PathBarTrackLayer.h"
#import "Elevator.h"

#define BOUND(VALUE, LOWER, UPPER)	MIN(MAX(VALUE, LOWER), UPPER)

@implementation PathBar (Interactions)

//-----------------
// Interactions
//-----------------
// the position is wrt to _trackLayer (with bound check)
- (float) valueForPosition:(float)position{
    
    // Convert from position (in _trackLayer) to value
    float tempValue =  position/self.useableTrackLength *
    (self.maximumValue - self.minimumValue);
    
    // Check if the value is within the bound.
    return BOUND(tempValue, self.minimumValue, self.maximumValue);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    // Exapand the width of the bar
    //    CGRect originalFrame = self.superview.frame;
    //    CGRect newFrame = CGRectMake(originalFrame.origin.x - originalFrame.size.width,
    //                                 originalFrame.origin.y,
    //                                 originalFrame.size.width*2,
    //                                 originalFrame.size.height);
    //    self.superview.frame = newFrame;
    
    // trackTouchingSet keeps tracking of all the touching events
    for (UITouch *aTouch in touches){
        
        if (![self isTouchValid:aTouch]){
            // If the touch is out of bound, do nothing
            NSMutableSet *aSet = [[NSMutableSet alloc] init];
            [aSet addObject:aTouch];
            [self touchesCancelled:aSet withEvent:nil];
            
        }else{
            if (![self.trackTouchingSet containsObject:aTouch])
            {
                [self.trackTouchingSet addObject:aTouch];
            }
        }
    }
    
    if ([self.trackTouchingSet count] == 1){
        // One point touched
        CGPoint touchPoint = [[self.trackTouchingSet anyObject]
                              locationInView:self.trackLayer];
        
        if (touchPoint.y > 0 && touchPoint.y < self.trackLayer.frame.size.height){
            float aValue = [self valueForPosition: touchPoint.y];
            
            if (self.pathBarMode == MAP){
                
                //--------------------
                // Single touch in MAP mode
                //--------------------
                
                [self.elevator touchElevatorPointA:aValue];
                // Update the elevator and the map
                [self updateElevatorThenMap];
            }else{
                
                //--------------------
                // Single touch in StreetView mode
                //--------------------
                [self.elevator touchSingleDot:aValue];
                
                [self.elevator setNeedsDisplay];
                
                if (self.delegateRespondsTo.spaceBarOnePointTouched){
                    
                    double percentage = self.elevator.lowerValue/self.maximumValue;
                    
                    if (!self.smallValueOnTopOfBar){
                        // when the small value is on the bottom
                        percentage = 1 - percentage;
                    }
                    [self.delegate spaceBarOnePointTouched: percentage];
                }
            }
        }
    }else if ([self.trackTouchingSet count] == 2){
        // Two points touched
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:self.trackLayer];
            twoValues[i] = [self valueForPosition: touchPoint.y];
            i++;
        }
        [self.elevator touchElevatorPointA:twoValues[0] pointB:twoValues[1]];
        // Update the elevator and the map
        [self updateElevatorThenMap];
    }
}

- (bool) isTouchValid: (UITouch*) touch{
    CGPoint touchPoint = [touch locationInView:self.trackLayer];
    return (touchPoint.y > 0 && touchPoint.y < self.trackLayer.frame.size.height);
}


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    if ([touches count] == 1 && [self.trackTouchingSet count] == 1){
        //--------------
        // One point is moved and there is only *one* touch point.
        // It is possible that one touch point is stationary and one touch point is moved.
        // (If so the one stationary touch point + one moving touch point casse should be handled as two touch points.)
        //--------------
        UITouch* touch = [touches anyObject];
        CGPoint locationInView = [touch locationInView:self.trackLayer];
        CGPoint previousLoationInView = [touch previousLocationInView:self.trackLayer];
        
        
        if (locationInView.y < 0 || locationInView.y > self.trackLayer.frame.size.height){
            // Touch is out of bound. Do nothing?
        }else{
            // In oneFingerMove mode, the elevator does not accept lowerValue, upperValue updates from map
            self.elevator.isElevatorOneFingerMoved = YES;
            
            // Convert both from positions to values
            float currentValue = [self valueForPosition:locationInView.y];
            float previousValue = [self valueForPosition:previousLoationInView.y];
            
            if (currentValue >= self.minimumValue && currentValue <= self.maximumValue){
                
                [self.elevator translateFromPreviousValue:previousValue toCurrentValue:currentValue];
                
                // Smooth translation--the scale should not change
                [self.elevator setNeedsDisplay];
                
                if (self.delegateRespondsTo.spaceBarElevatorMoved){
                    
                    bool directionFlag = (currentValue > previousValue);
                    
                    double lowerPercentage = self.elevator.lowerValue/self.maximumValue;
                    double upperPercentage = self.elevator.upperValue/self.maximumValue;
                    
                    if (!self.smallValueOnTopOfBar){
                        double templowerPercentage = lowerPercentage;
                        lowerPercentage = 1 - upperPercentage;
                        upperPercentage = 1 - templowerPercentage;
                        directionFlag = !directionFlag;
                    }
                    
                    [self.delegate spaceBarElevatorMovedLow: lowerPercentage
                                                       high: upperPercentage
                                              fromLowToHigh:directionFlag];
                }
            }
        }
        
    }else if ([self.trackTouchingSet count] == 2){
        //--------------
        // Two points are touched
        //--------------
        
        // Two points touched
        
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:self.trackLayer];
            twoValues[i] = [self valueForPosition: touchPoint.y];
            i++;
        }
        [self.elevator touchElevatorPointA:twoValues[0] pointB:twoValues[1]];
        
        // Update the elevator and the map
        [self updateElevatorThenMap];
        
        //        [CATransaction begin];
        //        [CATransaction setDisableActions:YES] ;
        //
        //        [self setLayerFrames];
        //
        //        [CATransaction commit];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *aTouch in touches){
        [self.trackTouchingSet removeObject:aTouch];
    }
    
    // The following is called upon transitioning from two-finger touch to one finger touch
    // Need to fix the offset here
    if ([self.trackTouchingSet count] == 1){
        UITouch *aTouch = [self.trackTouchingSet anyObject];
        CGPoint touchPoint = [aTouch locationInView:self.trackLayer];
        
        float aValue = [self valueForPosition: touchPoint.y];
        [self.elevator touchElevatorPointA:aValue];
    }
    
    
    self.elevator.isElevatorOneFingerMoved = NO;
}


// 1. Update the elevator visualization
// 2. Update the map
- (void) updateElevatorThenMap{
    [self.elevator setNeedsDisplay];
    
    if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
        
        
        double lowerPercentage = self.elevator.lowerValue/self.maximumValue;
        double upperPercentage = self.elevator.upperValue/self.maximumValue;
        
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
        }
        
        [self.delegate spaceBarTwoPointsTouchedLow:
         lowerPercentage high:upperPercentage];
    }
}

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
    
    
    
    // In oneFingerMove mode, the elevator does not accept lowerValue, upperValue updates from map
    if (!self.elevator.isElevatorOneFingerMoved){
        
        if (isnan(low) || isnan(high)){
            self.elevator.lowerValue = nan("");
            self.elevator.upperValue = nan("");
        }else{
            self.elevator.lowerValue = low * self.maximumValue;
            self.elevator.upperValue = high * self.maximumValue;
        }
        
        [self.elevator setNeedsDisplay];
    }
}

@end
