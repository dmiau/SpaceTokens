//
//  CustomMKPolygon.m
//  NavTools
//
//  Created by dmiau on 1/15/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomMKPolygon.h"

@implementation CustomMKPolygon

-(id)init{
    self = [super init];
    self.isLabelOn = NO;
    self.isHighlighted = NO;
    return self;
}

- (MKOverlayRenderer *)generateOverlayRenderer{
    //------------
    // Render a polygon
    //------------
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithOverlay:self];
    //        renderer.strokeColor = [UIColor redColor];
    renderer.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.2];
    return renderer;
}

@end
