//
//  CustomGMSPolygon.m
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomGMSPolygon.h"
#import "CustomGMSPolyline.h"

@implementation CustomGMSPolygon
-(id)initWithMKPolygon:(MKPolygon*) mkPolygon{
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i = 0; i < mkPolygon.pointCount; i++){
        [path addCoordinate:MKCoordinateForMapPoint(mkPolygon.points[i])];
    }
    
    self = [CustomGMSPolygon polygonWithPath:path];
    
    self.isHighlighted = NO;
    self.isLabelOn = NO;
    return self;
}

//--------------
// Setters
//--------------
-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    if (isHighlighted){
//        self.strokeWidth = 2;
//        self.strokeColor = [UIColor blueColor];
        self.fillColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.3];
    }else{
//        self.strokeWidth = 1;
//        self.strokeColor = [UIColor grayColor];
        self.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
    }
}

@end
