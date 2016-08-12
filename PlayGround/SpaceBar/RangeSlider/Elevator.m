//
//  Elevator.m
//  SpaceBar
//
//  Created by Daniel on 7/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import "CERangeSlider.h"
#import "Elevator.h"

@implementation Elevator{
    float _elevatorWidth;
    float _touchPointOffset;
}

- (id) init{
    self = [super init];
    if (self){
        self.lowerValue = nanf("");
        self.upperValue = nanf("");
        
        // Assign a default elevator width
        _elevatorWidth = 0.5;
        self.isElevatorOneFingerMoved = NO;
    }
    return self;
}

//-----------------
// This method draws the elevator
//-----------------
- (void)drawInContext:(CGContextRef)ctx
{
    //*****************
    // Do not draw anything if one of the value is nan
    //*****************
    if (isnan(self.lowerValue) || isnan(self.upperValue)){
        return;
    }
    
    // do things differently, depending on the number of touches
    if (self.sliderContainer.pathBarMode == STREETVIEW)
    {
        
        //-----------------
        // This is primary for the single touch in StreetView mode
        //-----------------
        
        float value = self.lowerValue;
        // Draw a small touch block
        CGRect elevactorRect = CGRectMake(self.sliderContainer.frame.size.width/2+2, value -0.5,
                                          self.sliderContainer.frame.size.width/2-4, value +0.5);
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:elevactorRect cornerRadius:15.0];
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextFillPath(ctx);
        
        // Draw a dot to signify the touch point
        [self drawTouchIndicator:self.lowerValue inContext:ctx];
        
        
    }else if ((self.upperValue >= 0) && (self.lowerValue >= 0))
    {
        // fill the highlighed range
        CGContextSetFillColorWithColor(ctx, self.sliderContainer.trackHighlightColour.CGColor);
        float lower = (self.lowerValue - self.sliderContainer.minimumValue)
                    / (self.sliderContainer.maximumValue - self.sliderContainer.minimumValue)
                    * self.frame.size.height;
        float upper = (self.upperValue - self.sliderContainer.minimumValue)
                    / (self.sliderContainer.maximumValue - self.sliderContainer.minimumValue)
                    * self.frame.size.height;
        
        CGRect elevactorRect = CGRectMake(self.sliderContainer.frame.size.width/2+2, lower,
                                          self.sliderContainer.frame.size.width/2-4, upper - lower);
        
        //Original drawing code
        //CGContextFillRect(ctx, elevactorRect);
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:elevactorRect cornerRadius:15.0];
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextFillPath(ctx);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
//        [bezierPath stroke];
        
        // draw two touch points
        [self drawTouchIndicator:self.lowerValue inContext:ctx];
        [self drawTouchIndicator:self.upperValue inContext:ctx];
    }
    
    //    // shadow
    //    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2.0), 3.0, [UIColor grayColor].CGColor);
    //    CGContextAddPath(ctx, switchOutline.CGPath);
    //    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    //    CGContextStrokePath(ctx);
    
    //    // outline
    //    CGContextAddPath(ctx, switchOutline.CGPath);
    //    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    //    CGContextSetLineWidth(ctx, 0.5);
    //    CGContextStrokePath(ctx);
    
}

//--------------------
// draw the dot outside of the track
// (otherwise users won't be able to see the touch point)
//--------------------
- (void) drawTouchIndicator: (float) value inContext: (CGContextRef)ctx
{
    float radius = 3;
    float xBias = self.sliderContainer.frame.size.width/2;
    
    // Convert from value to position
    float position = (value - self.sliderContainer.minimumValue)
                    / (self.sliderContainer.maximumValue - self.sliderContainer.minimumValue)
                    * self.frame.size.height;
    
    // -radius - xBias
    UIBezierPath *dotPath = [UIBezierPath
                             bezierPathWithOvalInRect:
                             CGRectMake(0,
                                        position-radius,
                                        2*radius, 2*radius)];
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blueColor] CGColor]);
    CGContextAddPath(ctx, dotPath.CGPath);
    CGContextFillPath(ctx);
}

- (bool)hitTestOfValue: (float) value{
    return (value <= _upperValue & value >= _lowerValue);
}

- (void)translateFromPreviousValue: (float) previousValue toCurrentValue: (float) currentValue{
    
    float diff = currentValue - previousValue;
    
    self.lowerValue += diff;
    self.upperValue += diff;
    
//    NSLog(@"Before correction:");
//    NSLog(@"lower: %g, upper: %g", self.lowerValue, self.upperValue);
//    NSLog(@"Diff: %g", self.upperValue - self.lowerValue);
    [self correctElevatorBasedOnBound];
    
//    NSLog(@"After correction:");
//    NSLog(@"lower: %g, upper: %g", self.lowerValue, self.upperValue);
//    NSLog(@"Diff: %g", self.upperValue - self.lowerValue);
    
//    NSLog(@"current: %g, lower: %g", currentValue, self.lowerValue);
    
    // Need this in the two extremes
    // In principle _touchPointOffset is needed when an elevator is translated.
    // However, enabling the following line all translation cases may result
    // touching point goes outside of the elevator. I am not sure why
    if (_lowerValue == 0 || _upperValue == self.sliderContainer.maximumValue){
        _touchPointOffset = currentValue - _lowerValue;
    }
}

// This method makes sure _lowerValue and _upperValue
// do not go out of bound
- (void) correctElevatorBasedOnBound{
    if (_lowerValue < self.sliderContainer.minimumValue){
        float diff = self.sliderContainer.minimumValue - _lowerValue;
        _lowerValue = self.sliderContainer.minimumValue;
        _upperValue += diff;
    }
    
    if (_upperValue > self.sliderContainer.maximumValue){
        float diff =  _upperValue - self.sliderContainer.maximumValue;
        _upperValue = self.sliderContainer.maximumValue;
        _lowerValue -= diff;
    }
}


- (void)restoreElevatorParamsFromTouchPoint: (float) touchPoint{
    _lowerValue = MAX(0, touchPoint - _touchPointOffset);
    _upperValue = MIN(self.sliderContainer.maximumValue, _lowerValue + _elevatorWidth);
}


//-----------------
// Support StreetView use cases
//-----------------
- (void) touchSingleDot: (float) value{
    _elevatorWidth  = 0;
    _touchPointOffset = 0;
    _lowerValue = value;
    _upperValue = -1;
}

//-----------------
// Support the map use cases
//-----------------
- (void) touchElevatorPointA: (float)value {
    
    // Check whether the elevator is touched?
    if ([self hitTestOfValue:value]){
        // The elevator is touched
        
        // Cache the elevator size and current touch off-set
        _elevatorWidth = _upperValue - _lowerValue;
        _touchPointOffset = value - _lowerValue;
        
        // Do not need to update lowerValue and upperValue
    }else{
        // The elevator is NOT touched
        
        // Cache the elevator size and current touch off-set
        if (!isnan(_upperValue) && !isnan(_lowerValue)){
            _elevatorWidth = _upperValue - _lowerValue;
        }
        
        float fullRangeValue = self.sliderContainer.maximumValue - self.sliderContainer.minimumValue;
        
        if (isnan(_upperValue) || isnan(_lowerValue))
        {
            // There is no elevator
            _lowerValue = value - _elevatorWidth/2;
            _upperValue = value + _elevatorWidth/2;
            [self correctElevatorBasedOnBound];
        
        }else{
            // There is an elevator
            
            if (value < _lowerValue){
                
                // The touched value is smaller than _lowerValue
                float diff = _lowerValue - value;
                _lowerValue = value;
                _upperValue -= diff;
            }else{
                // The touched value is bigger than _upperValue
                float diff = value - _upperValue;
                _upperValue = value;
                _lowerValue += diff;
            }
        }
        
        _touchPointOffset = value - _lowerValue;
    }
}



- (void) touchElevatorPointA: (float)valueA pointB: (float) valueB {
    _lowerValue = MIN(valueA, valueB);
    _upperValue = MAX(valueA, valueB);
    _elevatorWidth = _upperValue - _lowerValue;
}

@end
