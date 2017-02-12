//
//  DiskGenerator.m
//  SpaceBar
//
//  Created by dmiau on 2/12/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "DiskGenerator.h"

@implementation DiskGenerator

-(id)init{
    self = [super init];
    
    // Initialize parameters
    self.canvasSize = CGSizeMake(50, 50);
    self.diskDiameter = 10;
    self.outlineThinkness = 2;
    self.fillColorArray = [NSMutableArray array];
    
    [self resetDefaultStyle];
    return self;
}

-(void)resetDefaultStyle{
    self.isMarkerOn = NO;
    self.isDotOn = NO;
    self.diskStyle = REDDISK;
}

-(void)setDiskStyle:(DISKSTYLE)diskStyle{
    
    switch (diskStyle) {
        case GRAYDISK:
            [self.fillColorArray removeAllObjects];
            [self.fillColorArray addObject:[UIColor grayColor]];
            break;
        case REDDISK:
            [self.fillColorArray removeAllObjects];
            [self.fillColorArray addObject:[UIColor redColor]];
            break;
    }
}

-(UIImage*)generateIcon{
    UIGraphicsBeginImageContext(self.canvasSize);
    
    [self drawDisk];
    
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
    
    //now get the image from the context
    UIImage *diskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return diskImage;
}

-(void)drawDisk{
    UIColor *color = [self.fillColorArray firstObject];
    
    // Create a custom red dot
    // http://stackoverflow.com/questions/14594782/how-can-i-make-an-uiimage-programatically
    float radius = self.diskDiameter/2;
    CGSize size = CGSizeMake(radius*2, radius*2);
    CGRect rect = CGRectMake(self.canvasSize.width/2 - radius,
                             self.canvasSize.height/2 - radius,
                             size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [path fill];
}
@end
