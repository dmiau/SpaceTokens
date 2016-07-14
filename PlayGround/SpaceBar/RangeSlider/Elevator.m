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
        float touchPosition =
        [self.slider positionForValue:self.lowerValue];
        [self drawTouchIndicator:touchPosition inContext:ctx];
        
    }else if ((self.upperValue > -1) && (self.lowerValue > -1))
    {
        // fill the highlighed range
        CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColour.CGColor);
        float lower = [self.slider positionForValue:self.lowerValue];
        float upper = [self.slider positionForValue:self.upperValue];
        CGContextFillRect(ctx, CGRectMake(self.slider.blankXBias, lower,
                                          self.bounds.size.width, upper - lower));
        
        
        // draw two touch points
        float touchPosition =
        [self.slider positionForValue:self.lowerValue];
        [self drawTouchIndicator:touchPosition inContext:ctx];
        
        touchPosition =
        [self.slider positionForValue:self.upperValue];
        [self drawTouchIndicator:touchPosition inContext:ctx];
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

- (void) drawTouchIndicator: (float) touchPosition inContext: (CGContextRef)ctx
{
    float radius = 3;
    float xBias = self.slider.blankXBias;
    
    // -radius - xBias
    UIBezierPath *dotPath = [UIBezierPath
                             bezierPathWithOvalInRect:
                             CGRectMake(0,
                                        touchPosition-radius,
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
