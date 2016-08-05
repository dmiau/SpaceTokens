//
//  circleCheckingPanel.m
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CircleCheckingPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation CircleCheckingPanel{
    CAShapeLayer *circleLayer;
}

-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController{
    self = [super initWithFrame:frame];
    if (self){
        self.rootViewController = viewController;
        
        //-------------------
        // Set up the view
        //-------------------
        //http://stackoverflow.com/questions/28442516/ios-an-easy-way-to-draw-a-circle-using-cashapelayer
        circleLayer = [CAShapeLayer layer];

    }
    return self;
}

// Draw circle
- (void)drawCircle{
    // Get the width and height
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float diameter = 0.8 * width;
    CGRect box = CGRectMake(0.1*width, 0, diameter, diameter);
    
    // Draw a circle
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:box] CGPath]];
    [circleLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self layer] addSublayer:circleLayer];
}

// Remove circle
- (void)removeCircle{
    [circleLayer removeFromSuperlayer];
}


-(void)addPanel{
    self.frame = self.rootViewController.mapView.frame;
    [self.rootViewController.mapView addSubview:self];
    [self drawCircle];
    [self setUserInteractionEnabled:NO];
}


-(void)removePanel{
    [self removeCircle];
    [self removeFromSuperview];
}

@end
