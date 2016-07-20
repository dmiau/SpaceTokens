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
        self.isTouched = false;
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

- (void)translateByPoints: (float) points{
    self.lowerValue += points;
    self.upperValue += points;
    [self setNeedsDisplay];
}

- (void)specifyElevatorParamsWithTouchValue: (float) value{
    _elevatorWidth = _upperValue - _lowerValue;
    _touchPointOffset = value - _lowerValue;
}

- (void)loadElevatorParamsFromTouchPoint: (float) touchPoint{
    _lowerValue = MAX(0, touchPoint - _touchPointOffset);
    _upperValue = MIN(self.slider.maximumValue, _lowerValue + _elevatorWidth);
}

@end
