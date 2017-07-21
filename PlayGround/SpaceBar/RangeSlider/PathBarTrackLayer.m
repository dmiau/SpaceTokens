//
//  PathBarTrackLayer.m
//  PathBar
//
//  Created by Colin Eberhardt on 24/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "PathBarTrackLayer.h"
#import "PathBar.h"

@implementation PathBarTrackLayer

- (void)drawRect:(CGRect)rect
//- (void)drawInContext:(CGContextRef)ctx
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float trackWidth = self.bounds.size.width/2;
    
    // clip
    float cornerRadius = trackWidth * self.slider.curvatiousness / 2.0;
    
    CGRect newBound = CGRectMake(self.bounds.size.width/2, 0,
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
    
}
@end
