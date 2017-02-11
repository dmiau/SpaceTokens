//
//  StarIconGenerator.m
//  lab_ImageGeneration
//
//  Created by Daniel on 2/10/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "StarIconGenerator.h"

@implementation StarIconGenerator
-(id)init{
    self = [super init];
    
    // Initialize parameters
    self.canvasSize = CGSizeMake(50, 50);
    self.starDiameter = 20;
    self.outlineThinkness = 2;
    self.dotColor = [UIColor redColor];
    
    [self resetDefaultStyle];
    return self;
}

-(void)resetDefaultStyle{
    self.isMarkerOn = NO;
    self.isDotOn = NO;
    self.starStyle = YELLOWSTAR;
}

-(void)setStarStyle:(STARSTYLE)starStyle{
    
    switch (starStyle) {
        case YELLOWSTAR:
            self.fillColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1];
            self.outlineColor = [UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1];
            break;
        case REDSTAR:
            self.fillColor = [UIColor redColor];
            self.outlineColor = [UIColor redColor];
            break;
    }
}

-(UIImage*)generateIcon{
    UIGraphicsBeginImageContext(self.canvasSize);

    // generate the outline star
    [self drawStarWithColor:self.outlineColor andDiameter:
     self.starDiameter];
    
    // generate the inner star
    [self drawStarWithColor:self.fillColor andDiameter:
     self.starDiameter - self.outlineThinkness * 2];
    
    if (self.isMarkerOn){
        //-------------
        // Add the marker
        //-------------
        UIImage *marker = [UIImage imageNamed:@"default_marker.png"];
        float desiredHeight = self.canvasSize.height/2;
        float desiredWidth = desiredHeight / marker.size.height * marker.size.width;
        float desiredX = (self.canvasSize.width - desiredWidth)/2;
        CGRect markerRect = CGRectMake(desiredX, 0, desiredWidth, desiredHeight);
        [marker drawInRect:markerRect];
    }
    
    if (self.isDotOn){
        [self drawDotWithColor:self.dotColor];
    }
    
    //now get the image from the context
    UIImage *starImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    return starImage;
}

- (void)drawStarWithColor:(UIColor*) color andDiameter: (float)diameter{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    
    CGFloat xCenter = self.canvasSize.width/2;
    CGFloat yCenter = self.canvasSize.height/2;
    //---------------
    // generate the outline first
    CGContextSetFillColorWithColor(context, [color CGColor]);
    float  w = diameter;
    double r = w / 2.0;
    float flip = -1.0;
    double theta = 2.0 * M_PI * (2.0 / 5.0); // 144 degrees
    
    CGContextMoveToPoint(context, xCenter, r*flip+yCenter);
    
    for (NSUInteger k=1; k<5; k++)
    {
        float x = r * sin(k * theta);
        float y = r * cos(k * theta);
        CGContextAddLineToPoint(context, x+xCenter, y*flip+yCenter);
    }
    //    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextClosePath(context);
    //    CGContextStrokePath(context);
    CGContextFillPath(context);
}

-(void)drawDotWithColor:(UIColor*) color{
    // Create a custom red dot
    // http://stackoverflow.com/questions/14594782/how-can-i-make-an-uiimage-programatically
    float radius = self.starDiameter * 0.10;
    CGSize size = CGSizeMake(radius*2, radius*2);
    CGRect rect = CGRectMake(self.canvasSize.width/2 - radius,
                             self.canvasSize.height/2 - radius,
                             size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [path fill];
}

@end
