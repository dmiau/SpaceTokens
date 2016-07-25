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
        self.lowerValue = -1;
        self.upperValue = -1;
    }
    return self;
}


- (void)drawInContext:(CGContextRef)ctx
{
    // need to paint touch indicator
    
    // do things differently, depending on the number of touches
    if ((self.upperValue == -1))
    {
        // draw a dot to signify the touch point
        [self drawTouchIndicator:self.lowerValue inContext:ctx];
        
    }else if ((self.upperValue > -1) && (self.lowerValue > -1))
    {
        // fill the highlighed range
        CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColour.CGColor);
        float lower = (self.lowerValue - self.slider.minimumValue)
                    / (self.slider.maximumValue - self.slider.minimumValue)
                    * self.frame.size.height;
        float upper = (self.upperValue - self.slider.minimumValue)
                    / (self.slider.maximumValue - self.slider.minimumValue)
                    * self.frame.size.height;
        
        CGRect elevactorRect = CGRectMake(self.slider.blankXBias+2, lower,
                                          self.slider.blankXBias-4, upper - lower);
        
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

- (void) drawTouchIndicator: (float) value inContext: (CGContextRef)ctx
{
    float radius = 3;
    float xBias = self.slider.blankXBias;
    
    // Convert from value to position
    float position = (value - self.slider.minimumValue)
                    / (self.slider.maximumValue - self.slider.minimumValue)
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
    if (_lowerValue == 0 || _upperValue == self.slider.maximumValue){
        _touchPointOffset = currentValue - _lowerValue;
    }
}

// This method makes sure _lowerValue and _upperValue
// do not go out of bound
- (void) correctElevatorBasedOnBound{
    if (_lowerValue < self.slider.minimumValue){
        float diff = self.slider.minimumValue - _lowerValue;
        _lowerValue = self.slider.minimumValue;
        _upperValue += diff;
    }
    
    if (_upperValue > self.slider.maximumValue){
        float diff =  _upperValue - self.slider.maximumValue;
        _upperValue = self.slider.maximumValue;
        _lowerValue -= diff;
    }
}


- (void)restoreElevatorParamsFromTouchPoint: (float) touchPoint{
    _lowerValue = MAX(0, touchPoint - _touchPointOffset);
    _upperValue = MIN(self.slider.maximumValue, _lowerValue + _elevatorWidth);
}


- (void) touchPointA: (float)value {
    
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
        _elevatorWidth = _upperValue - _lowerValue;
        
        float fullRangeValue = self.slider.maximumValue - self.slider.minimumValue;
        
        // In case the current elevator length is 0
        if (_elevatorWidth <= 0.05 * fullRangeValue){
            // Assign a default elevator width
            _elevatorWidth = 0.05 * fullRangeValue;
        }
        
        if ( _lowerValue < 0 && _upperValue < 0){
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



- (void) touchPointA: (float)valueA pointB: (float) valueB {
    _lowerValue = MIN(valueA, valueB);
    _upperValue = MAX(valueA, valueB);
    _elevatorWidth = _upperValue - _lowerValue;
}

@end
