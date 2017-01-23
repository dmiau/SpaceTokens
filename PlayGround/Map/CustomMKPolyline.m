//
//  CustomMKPolyline.m
//  SpaceBar
//
//  Created by dmiau on 1/15/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomMKPolyline.h"
#import <MapKit/MapKit.h>

@implementation CustomMKPolyline

-(id)init{
    self = [super init];
    self.isLabelOn = NO;
    self.isHighlighted = NO;
    return self;
}

- (MKOverlayRenderer *)generateOverlayRenderer{
    //------------
    // Render a line
    //------------
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:self];
    
    if (self.isHighlighted){
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 5.0;
    }else{
        renderer.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        renderer.lineWidth = 3.0;
    }
    return renderer;
}

@end
