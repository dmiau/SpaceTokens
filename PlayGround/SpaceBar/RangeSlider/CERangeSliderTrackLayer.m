//
//  CERangeSliderTrackLayer.m
//  CERangeSlider
//
//  Created by Colin Eberhardt on 24/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CERangeSliderTrackLayer.h"
#import "CERangeSlider.h"

@implementation CERangeSliderTrackLayer

- (void)drawInContext:(CGContextRef)ctx
{
    float trackWidth = self.bounds.size.width - self.slider.blankXBias;
    
    // clip
    float cornerRadius = trackWidth * self.slider.curvatiousness / 2.0;
    
    CGRect newBound = CGRectMake(self.slider.blankXBias, 0,
                                 trackWidth, self.bounds.size.height);
    
    UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:newBound
                                                             cornerRadius:cornerRadius];

    UIBezierPath *clipOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                             cornerRadius:cornerRadius];
	CGContextAddPath(ctx, clipOutline.CGPath);
    CGContextClip(ctx);
    
    // fill the track
    CGContextSetFillColorWithColor(ctx, self.slider.trackColour.CGColor);
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextFillPath(ctx);
    
    
    // need to paint touch indicator
    
    // do things differently, depending on the number of touches
    if ((self.slider.upperValue == -1))
    {
        // draw a dot to signify the touch point
        float touchPosition =
        [self.slider positionForValue:self.slider.lowerValue];
        [self drawTouchIndicator:touchPosition inContext:ctx];
        
    }else if ((self.slider.upperValue > -1) && (self.slider.lowerValue > -1))
    {
        // fill the highlighed range
        CGContextSetFillColorWithColor(ctx, self.slider.trackHighlightColour.CGColor);
        float lower = [self.slider positionForValue:self.slider.lowerValue];
        float upper = [self.slider positionForValue:self.slider.upperValue];
        CGContextFillRect(ctx, CGRectMake(self.slider.blankXBias, lower,
                                          self.bounds.size.width, upper - lower));
        
        
        // draw two touch points
        float touchPosition =
        [self.slider positionForValue:self.slider.lowerValue];
        [self drawTouchIndicator:touchPosition inContext:ctx];
        
        touchPosition =
        [self.slider positionForValue:self.slider.upperValue];
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


@end
